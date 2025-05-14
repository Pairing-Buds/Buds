#!/usr/bin/env python3
import random
import argparse
import sys
import os
from pydub import AudioSegment
from jamo import h2j, j2hcj

# 현재 스크립트의 디렉토리 경로를 얻기
MODULE_DIR = os.path.dirname(os.path.abspath(__file__))


def convert_text_to_animalese(text, output_file, debug=False):
    """텍스트를 동물의 숲 스타일 음성으로 변환하고 파일로 저장"""
    if not text or not output_file:
        print("오류: 텍스트와 출력 파일 경로가 필요합니다.")
        return False

    # 초성 목록 정의 (공백 포함)
    char_list = ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ', 'ㄲ', 'ㄸ', 'ㅃ', 'ㅆ', 'ㅉ', ' ']
    char_sounds = {}

    # 디버깅을 위한 정보 출력
    if debug:
        print(f"현재 작업 디렉토리: {os.getcwd()}")
        print(f"모듈 디렉토리: {MODULE_DIR}")
        sources_dir = os.path.join(MODULE_DIR, 'sources')
        print(f"sources 디렉토리 경로: {sources_dir}")
        print(f"sources 디렉토리 존재 여부: {os.path.exists(sources_dir)}")
        print(f"출력 파일 경로: {output_file}")

    # 소리 파일 로드
    missing_files = []
    for idx, item in enumerate(char_list):
        if item == ' ':  # 공백은 건너뜀
            continue

        str_idx = str(idx + 1).zfill(2)
        source_path = os.path.join(MODULE_DIR, 'sources', f'{str_idx}.padata')

        if debug:
            print(f"파일 경로: {source_path}")
            print(f"파일 존재 여부: {os.path.exists(source_path)}")

        try:
            # 파일 로드 시도 - 다양한 형식 시도
            if os.path.exists(source_path):
                try:
                    char_sounds[item] = AudioSegment.from_mp3(source_path)
                except:
                    try:
                        char_sounds[item] = AudioSegment.from_wav(source_path)
                    except:
                        char_sounds[item] = AudioSegment.from_file(source_path)
            else:
                # .mp3 확장자로 시도
                mp3_path = os.path.join(MODULE_DIR, 'sources', f'{str_idx}.mp3')
                if os.path.exists(mp3_path):
                    try:
                        char_sounds[item] = AudioSegment.from_mp3(mp3_path)
                    except:
                        char_sounds[item] = AudioSegment.from_file(mp3_path)
                else:
                    missing_files.append(f"{item}({str_idx})")
                    print(f"경고: {item}({str_idx})의 소리 파일을 찾을 수 없습니다.")
        except Exception as e:
            print(f"경고: {item}({str_idx})의 소리 파일을 로드할 수 없습니다: {str(e)}")
            missing_files.append(f"{item}({str_idx})")

    if missing_files:
        all_files_missing = len(missing_files) == len([c for c in char_list if c != ' '])
        if all_files_missing:
            print("모든 소리 파일이 누락되었습니다. sources 폴더에 소리 파일을 추가하세요.")
            return False
        else:
            print(f"일부 소리 파일({', '.join(missing_files)})이 누락되었습니다. 진행합니다.")

    result_sound = None

    # 텍스트 각 문자의 초성을 추출하여 음성 생성
    for ch in text:
        try:
            if ch.isspace():  # 공백 처리
                # 공백은 짧은 무음으로 처리
                if result_sound is not None:
                    silence = AudioSegment.silent(duration=100)  # 100ms 무음
                    result_sound += silence
                continue

            jamo_ch = j2hcj(h2j(ch))
            if not jamo_ch or jamo_ch[0] not in char_sounds:
                if debug:
                    print(f"문자 '{ch}'에서 추출한 초성 '{jamo_ch[0] if jamo_ch else '없음'}'에 해당하는 소리 파일이 없습니다.")
                continue

            char_sound = char_sounds[jamo_ch[0]]

            # 피치 랜덤 조절
            octaves = 2 * random.uniform(0.96, 1.15)
            new_sample_rate = int(char_sound.frame_rate * (2.0 ** octaves))

            # 음성 변환 및 합치기
            pitch_char_sound = char_sound._spawn(char_sound.raw_data, overrides={'frame_rate': new_sample_rate})
            result_sound = pitch_char_sound if result_sound is None else result_sound + pitch_char_sound
        except Exception as e:
            print(f"경고: 문자 '{ch}' 처리 중 오류 발생: {str(e)}")

    # 결과 파일 저장
    if result_sound:
        try:
            # 출력 디렉토리가 존재하지 않으면 생성
            output_dir = os.path.dirname(output_file)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir, exist_ok=True)

            # 파일 저장 시도
            result_sound.export(output_file, format="wav")
            print(f"성공: 음성 파일이 저장되었습니다 - {output_file}")
            return True
        except Exception as e:
            print(f"오류: 파일 저장 실패: {str(e)}")
    else:
        print("오류: 변환할 소리가 없습니다.")

    return False


# FFmpeg 설정 확인 및 경로 설정 시도
def check_ffmpeg():
    """FFmpeg 설치 여부 확인 및 경로 설정"""
    try:
        # FFmpeg 버전 확인
        import subprocess
        result = subprocess.run(["ffmpeg", "-version"], capture_output=True, text=True)
        if result.returncode == 0:
            print("FFmpeg 확인 완료:", result.stdout.split('\n')[0])
            return True
        else:
            print("FFmpeg 확인 실패:", result.stderr)
            return False
    except Exception as e:
        print(f"FFmpeg 확인 중 오류: {str(e)}")

        # 일반적인 FFmpeg 경로 시도
        paths = [
            "/usr/bin/ffmpeg",
            "/usr/local/bin/ffmpeg",
            "C:/Program Files/ffmpeg/bin/ffmpeg.exe",
            "C:/ffmpeg/bin/ffmpeg.exe"
        ]

        for path in paths:
            if os.path.exists(path):
                print(f"FFmpeg 발견: {path}")
                from pydub import AudioSegment
                AudioSegment.converter = path
                return True

        print("FFmpeg를 찾을 수 없습니다. 설치하거나 경로를 수동으로 설정하세요.")
        return False


# 명령줄 인자 파서 설정
if __name__ == "__main__":
    # FFmpeg 확인
    check_ffmpeg()

    parser = argparse.ArgumentParser(description='동물의 숲 NPC 목소리 생성기')
    parser.add_argument('-t', '--text', help='변환할 텍스트')
    parser.add_argument('-o', '--output', help='출력 파일 경로')
    parser.add_argument('-d', '--debug', action='store_true', help='디버깅 정보 표시')
    args = parser.parse_args()

    if args.text and args.output:
        convert_text_to_animalese(args.text, args.output, debug=args.debug)
    else:
        print("사용법: python pyanimalese_cli.py -t '텍스트' -o '출력파일.wav' [-d]")
        sys.exit(1)