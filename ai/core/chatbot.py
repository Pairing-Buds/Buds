from langchain_openai import ChatOpenAI
from langchain.schema import HumanMessage, SystemMessage, AIMessage
import logging
import os
import tempfile
import openai
from db.mysql import mysql_db
from db.chroma import chroma_db
from core.prompts import generate_system_prompt
import base64
import re
import subprocess
import sys
import asyncio
from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timedelta, timezone
from PyAnimalese.pyanimalese_cli import convert_text_to_animalese
from pydub import AudioSegment
from jamo import h2j, j2hcj

KST = timezone(timedelta(hours=9))

# 전역 스레드 풀 생성 (병렬 처리용)
thread_pool = ThreadPoolExecutor(max_workers=4)


class Chatbot:
    def __init__(self):
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OPENAI_API_KEY 환경 변수가 설정되지 않았습니다.")

        self.chat = ChatOpenAI(
            model="gpt-4o",
            temperature=0.1
        )

        # OpenAI 직접 API 키 설정
        openai.api_key = api_key

        self.daily_message_count = {}
        self._check_pyanimalese_setup()
        self.char_sounds = {}
        self._preload_animalese_sounds()

        logging.info("Chatbot 인스턴스가 초기화되었습니다.")

    def _check_pyanimalese_setup(self):
        """PyAnimalese 설치 및 필요한 의존성을 확인합니다."""
        try:
            # ffmpeg 설치 확인
            result = subprocess.run(["ffmpeg", "-version"], capture_output=True, text=True)
            if result.returncode != 0:
                logging.warning("ffmpeg가 설치되지 않았습니다. TTS 기능이 작동하지 않을 수 있습니다.")
            else:
                logging.info("ffmpeg 확인 완료")

            # PyAnimalese CLI 스크립트 확인
            # 수정된 부분: 현재 프로젝트 구조에 맞게 경로 수정
            pyanimalese_cli_path = os.path.join("PyAnimalese", "pyanimalese_cli.py")
            if not os.path.exists(pyanimalese_cli_path):
                logging.warning(f"PyAnimalese CLI 스크립트를 찾을 수 없습니다: {pyanimalese_cli_path}")
                logging.warning("TTS 기능이 작동하지 않을 수 있습니다.")
            else:
                logging.info(f"PyAnimalese CLI 스크립트 확인 완료: {pyanimalese_cli_path}")
        except Exception as e:
            logging.error(f"PyAnimalese 설정 확인 중 오류: {str(e)}")
            logging.warning("TTS 기능이 제한될 수 있습니다.")

    def _preload_animalese_sounds(self):
        """
        자주 사용되는 소리 파일을 미리 로드하여 성능 향상
        """
        try:
            # 초성 목록 (가장 많이 사용되는 초성 우선)
            common_chars = ['ㄱ', 'ㄴ', 'ㄷ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅎ']

            # 모듈 디렉토리 경로
            MODULE_DIR = os.path.dirname(os.path.abspath(os.path.join(__file__, "..", "PyAnimalese")))

            # 소리 파일 로드
            for idx, item in enumerate(common_chars):
                char_idx = ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ', 'ㄲ', 'ㄸ', 'ㅃ', 'ㅆ',
                            'ㅉ'].index(item) + 1
                str_idx = str(char_idx).zfill(2)

                # 파일 경로
                source_path = os.path.join(MODULE_DIR, 'sources', f'{str_idx}.padata')
                mp3_path = os.path.join(MODULE_DIR, 'sources', f'{str_idx}.mp3')

                # 파일 로드 시도
                try:
                    if os.path.exists(source_path):
                        self.char_sounds[item] = AudioSegment.from_file(source_path)
                    elif os.path.exists(mp3_path):
                        self.char_sounds[item] = AudioSegment.from_mp3(mp3_path)
                except Exception as e:
                    logging.warning(f"소리 파일 로드 실패: {item} - {e}")

            logging.info(f"Animalese 소리 파일 {len(self.char_sounds)}/{len(common_chars)}개 프리로딩 완료")
        except Exception as e:
            logging.error(f"소리 파일 프리로딩 오류: {str(e)}")

    def _sanitize_input(self, text):
        """
        입력 텍스트를 정제하여 불필요한 공백과 특수문자를 처리합니다.
        """
        if not text or not isinstance(text, str):
            return ""

        # 앞뒤 공백 제거
        text = text.strip()

        # 연속된 공백을 하나로 치환
        text = re.sub(r'\s+', ' ', text)

        # 불필요한 특수문자 제거 (필요에 따라 조정)
        text = re.sub(r'[^\w\s가-힣ㄱ-ㅎㅏ-ㅣ.,!?;:()\-\'\"]+', '', text)

        return text

    def _check_daily_limit(self, user_id):
        """
        사용자의 일일 메시지 수를 확인하고 제한을 초과했는지 검사합니다.
        """
        today = datetime.now(KST).date().strftime('%Y-%m-%d')
        user_key = f"{user_id}_{today}"

        # 오늘 첫 메시지인 경우 초기화
        if user_key not in self.daily_message_count:
            self.daily_message_count[user_key] = 0

            # 이전 날짜의 카운트는 정리 (메모리 관리)
            yesterday = (datetime.now() - timedelta(days=1)).strftime('%Y-%m-%d')
            old_key = f"{user_id}_{yesterday}"
            if old_key in self.daily_message_count:
                del self.daily_message_count[old_key]

        # 현재 카운트 확인
        current_count = self.daily_message_count[user_key]

        # 제한 초과 확인
        if current_count >= 100:
            return False

        # 카운트 증가
        self.daily_message_count[user_key] += 1
        return True

    async def get_response(self, user_id, message, message_count=0, is_voice=False):
        """
        사용자 메시지에 대한 응답을 생성합니다.
        is_voice가 True인 경우 음성 응답도 생성합니다.
        비동기 처리로 최적화되었습니다.
        """
        try:
            # 0. 메시지 정제
            sanitized_message = self._sanitize_input(message)
            if not sanitized_message:
                return "메시지가 비어있거나 유효하지 않습니다."

            # 0-1. 일일 메시지 제한 확인
            if not self._check_daily_limit(user_id):
                return "죄송합니다. 오늘의 대화 제한(100회)에 도달했습니다. 내일 다시 대화해주세요."

            # 1-4. 모든 컨텍스트 정보 비동기 수집
            user_profile, recent_history, conversation_summary, similar_context = await asyncio.gather(
                self._get_user_profile_async(user_id),
                self._get_recent_history_async(user_id),
                self._get_conversation_summary_async(user_id),
                self._get_similar_context_async(user_id, sanitized_message)
            )

            # 5. 시스템 프롬프트 생성
            context_combined = f"""
            대화 요약:
            {conversation_summary if conversation_summary else "이전 대화 요약 없음"}

            최근 대화:
            {self._format_messages(recent_history) if recent_history else "최근 대화 없음"}

            관련 대화:
            {similar_context if similar_context else "관련 대화 없음"}
            """

            system_prompt = generate_system_prompt(user_profile, context_combined)

            # 활동 추천 시점 확인
            if message_count > 0 and message_count % 6 == 0:
                system_prompt += "\n[중요] 활동을 추천해주세요!"

            # 6. 대화 이력을 포함한 메시지 목록 구성
            messages = [SystemMessage(content=system_prompt)]

            # 최근 몇 개의 대화만 실제 메시지로 포함 (너무 많으면 토큰 제한에 걸림)
            for entry in recent_history[-6:]:  # 최근 3턴(6개 메시지)만 포함
                if entry["is_user"]:
                    messages.append(HumanMessage(content=entry["message"]))
                else:
                    messages.append(AIMessage(content=entry["message"]))

            # 현재 사용자 메시지 추가
            messages.append(HumanMessage(content=sanitized_message))

            # 7. LLM을 사용하여 응답 생성
            response = await self.chat.ainvoke(messages)
            text_response = response.content

            # 8. 새로운 대화가 20개 이상 쌓였을 때 자동 요약 생성 및 저장 (백그라운드로 처리)
            message_total = await self._get_message_count_async(user_id)
            if message_total % 20 == 0:  # 20개 메시지마다 요약 생성
                # 백그라운드로 요약 처리 (응답 지연 방지)
                asyncio.create_task(self._update_conversation_summary(user_id))

            # 9. 음성 응답이 필요한 경우 TTS 생성 (병렬 처리)
            if is_voice:
                # 음성 변환에 최적화된 텍스트 준비 (길이 제한)
                voice_text = self._prepare_text_for_voice(text_response)

                # 스레드 풀에서 음성 생성 (병렬 처리)
                loop = asyncio.get_event_loop()
                audio_path_future = loop.run_in_executor(
                    thread_pool,
                    self.generate_animalese_tts_optimized,
                    voice_text,
                    user_id
                )

                # 음성 생성 완료 대기
                audio_path = await audio_path_future

                return {
                    "text": text_response,
                    "audio_path": audio_path
                }

            return text_response

        except ValueError as e:
            # 사용자 프로필 조회 실패 (로그인되지 않은 사용자 등)
            logging.error(f"사용자 정보 오류: {str(e)}")
            raise ValueError(f"사용자 인증 오류: {str(e)}")

        except Exception as e:
            logging.error(f"챗봇 응답 생성 중 오류: {str(e)}")
            raise ValueError(f"서비스 오류: {str(e)}")

    # 비동기 헬퍼 메서드들
    async def _get_user_profile_async(self, user_id):
        """사용자 프로필 비동기 조회"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, mysql_db.get_user_profile, user_id)

    async def _get_recent_history_async(self, user_id):
        """최근 대화 이력 비동기 조회"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, chroma_db.get_recent_conversation_history, user_id, 15)

    async def _get_conversation_summary_async(self, user_id):
        """대화 요약 비동기 조회"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, chroma_db.get_conversation_summary, user_id)

    async def _get_similar_context_async(self, user_id, message):
        """유사 컨텍스트 비동기 조회"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, chroma_db.get_similar_conversations, user_id, message)

    async def _get_message_count_async(self, user_id):
        """메시지 수 비동기 조회"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(None, chroma_db.get_message_count, user_id)

    def _format_messages(self, messages):
        """메시지 리스트를 텍스트 포맷으로 변환합니다."""
        if not messages:
            return ""

        formatted = []
        for msg in messages:
            speaker = "User" if msg["is_user"] else "AI"
            formatted.append(f"{speaker}: {msg['message']}")

        return "\n".join(formatted)

    async def _update_conversation_summary(self, user_id):
        """최근 대화를 요약하여 저장합니다."""
        try:
            # 최근 20개 대화 가져오기
            recent_messages = await self._get_recent_history_async(user_id, 20)

            if not recent_messages:
                return

            formatted_messages = self._format_messages(recent_messages)

            # 요약 프롬프트
            summary_prompt = f"""
            다음은 사용자와의 최근 대화입니다:

            {formatted_messages}

            이 대화의 핵심 내용을 200자 이내로 요약해주세요. 중요한 주제, 감정, 논의 사항을 포함하세요.
            """

            # 요약 생성
            response = await self.chat.ainvoke([
                SystemMessage(content="당신은 대화 내용을 간결하게 요약하는 전문가입니다."),
                HumanMessage(content=summary_prompt)
            ])

            # 요약본 저장 (비동기적으로)
            loop = asyncio.get_event_loop()
            await loop.run_in_executor(
                None,
                chroma_db.save_conversation_summary,
                user_id,
                response.content
            )

            return response.content

        except Exception as e:
            logging.error(f"대화 요약 생성 오류: {str(e)}")
            return None

    def _prepare_text_for_voice(self, text):
        """
        음성 변환에 적합하도록 텍스트 준비
        (너무 긴 텍스트는 처리 시간이 오래 걸리므로 적절히 축소)
        """
        # 최대 150자로 제한 (필요에 따라 조정)
        if len(text) <= 150:
            return text

        # 문장 단위로 분리하여 적절한 지점까지만 사용
        sentences = re.split(r'(?<=[.!?])\s+', text)
        result = ""

        for sentence in sentences:
            if len(result) + len(sentence) <= 150:
                result += sentence + " "
            else:
                break

        return result.strip()

    def generate_animalese_tts_optimized(self, text, user_id=None):
        """
        최적화된 동물의 숲 스타일 TTS 생성 함수
        강화된 오류 처리 추가
        """
        try:
            # 입력 텍스트 확인 및 로깅
            if not text or not isinstance(text, str) or len(text) == 0:
                logging.error(f"유효하지 않은 TTS 입력 텍스트: '{text}'")
                # 기본 무음 파일 생성
                return self._generate_fallback_audio(user_id)

            # 타임스탬프 생성 (파일명용)
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            user_part = f"_{user_id}" if user_id else ""
            output_filename = f"animalese{user_part}_{timestamp}.wav"
            output_path = os.path.join(tempfile.gettempdir(), output_filename)

            # 디버그 정보 로깅
            logging.debug(f"TTS 변환 시작: 텍스트 길이={len(text)}, 출력 경로={output_path}")

            # 원본 변환 함수 호출 (최적화 없이)
            MODULE_DIR = os.path.dirname(os.path.abspath(os.path.join(__file__, "..", "PyAnimalese")))
            success = convert_text_to_animalese(text, output_path, debug=False)

            # 성공 여부 확인
            if success and os.path.exists(output_path) and os.path.getsize(output_path) > 0:
                logging.info(f"TTS 파일 생성 성공: {output_path}")
                return output_path
            else:
                logging.error(f"TTS 파일 생성 실패: {output_path}")
                # 기본 무음 파일 생성
                return self._generate_fallback_audio(user_id)

        except Exception as e:
            logging.error(f"TTS 생성 중 예외 발생: {str(e)}")
            return self._generate_fallback_audio(user_id)

    def _generate_fallback_audio(self, user_id=None):
        """
        TTS 생성 실패 시 폴백 오디오 생성
        """
        try:
            timestamp = datetime.now().strftime('%Y%m%d%H%M%S')
            user_part = f"_{user_id}" if user_id else ""
            output_filename = f"fallback{user_part}_{timestamp}.wav"
            output_path = os.path.join(tempfile.gettempdir(), output_filename)

            # 기본 오디오 생성 (무음 + 비프음)
            silence = AudioSegment.silent(duration=300)
            beep = AudioSegment.sine(frequency=440, duration=200)
            audio = silence + beep + silence

            # 파일 저장
            output_dir = os.path.dirname(output_path)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir, exist_ok=True)

            audio.export(output_path, format="wav")
            logging.info(f"폴백 오디오 파일 생성: {output_path}")
            return output_path
        except Exception as e:
            logging.error(f"폴백 오디오 생성 실패: {str(e)}")
            return None

    def generate_animalese_tts(self, text, user_id=None):
        """
        원래 동물의 숲 TTS 함수 (하위 호환성 유지)
        이제 최적화된 버전을 사용합니다.
        """
        return self.generate_animalese_tts_optimized(text, user_id)

    def generate_emotion_diary(self, chat_history):
        """
        채팅 기록을 바탕으로 감정을 어루만지는 감정 일기 생성
        """
        sanitized_history = self._sanitize_input(chat_history)

        prompt = f"""
        다음은 사용자와의 오늘 채팅 기록입니다:

        {sanitized_history}

        이 채팅 기록을 바탕으로 사용자의 감정을 이해하고 어루만져줄 수 있는 사용자 입장에서의 감정 일기를 작성해주세요.
        감정적인 표현을 활용하고, 사용자의 기분과 심리상태를 공감하는 내용이어야 합니다.
        1인칭 시점으로 작성하며, 200자 이내로 요약해주세요.
        """

        response = self.generate_response(prompt)
        return response

    def generate_active_diary(self, chat_history):
        """
        채팅 기록을 바탕으로 객관적인 행동 일기 생성
        """
        sanitized_history = self._sanitize_input(chat_history)

        prompt = f"""
        다음은 사용자와의 오늘 채팅 기록입니다:

        {sanitized_history}

        이 채팅 기록을 바탕으로 사용자의 행동과 활동을 객관적으로 분석하는 행동 일기를 작성해주세요.
        사실적이고 객관적인 표현을 사용하고, 사용자의 행동과 결정에 대해 분석하는 내용이어야 합니다.
        1인칭 시점으로 작성하며, 200자 이내로 요약해주세요.
        """

        response = self.generate_response(prompt)
        return response

    def generate_response(self, prompt):
        """
        주어진 프롬프트에 대한 응답을 생성합니다.
        """
        try:
            response = self.chat.invoke([
                SystemMessage(content="당신은 공감 능력이 뛰어난 일기 작성 전문가입니다."),
                HumanMessage(content=prompt)
            ])
            return response.content
        except Exception as e:
            logging.error(f"응답 생성 중 오류: {str(e)}")
            return "일기 생성 중 오류가 발생했습니다."


# 전역 Chatbot 인스턴스
chatbot = Chatbot()