#!/usr/bin/env python3
import random
import argparse
import sys
import os
import tempfile
import logging
from pydub import AudioSegment
from jamo import h2j, j2hcj

# 현재 스크립트의 디렉토리 경로를 얻기
MODULE_DIR = os.path.dirname(os.path.abspath(__file__))


def convert_text_to_animalese(text, output_file, debug=False):
    """텍스트를 동물의 숲 스타일 음성으로 변환하고 파일로 저장"""
    if not text or not output_file:
        print("오류: 텍스트와 출력 파일 경로가 필요합니다.")
        return False

    # 디버깅 로깅 추가
    if debug:
        print(f"텍스트: '{text}'")
        print(f"출력 파일: {output_file}")
        print(f"모듈 디렉토리: {MODULE_DIR}")

    # 텍스트 유효성 확인 추가
    if not any(c.isalpha() or c.isspace() for c in text):
        print(f"오류: 유효한 문자가 포함되지 않은 텍스트입니다: '{text}'")
        return False

    # 초성 목록 정의 (공백 포함)
    char_list = ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ', 'ㄲ', 'ㄸ', 'ㅃ', 'ㅆ', 'ㅉ', ' ']
    char_sounds = {}

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
                    if debug:
                        print(f"경고: {item}({str_idx})의 소리 파일을 찾을 수 없습니다.")
        except Exception as e:
            if debug:
                print(f"경고: {item}({str_idx})의 소리 파일을 로드할 수 없습니다: {str(e)}")
            missing_files.append(f"{item}({str_idx})")

    if missing_files:
        all_files_missing = len(missing_files) == len([c for c in char_list if c != ' '])
        if all_files_missing:
            print("모든 소리 파일이 누락되었습니다. sources 폴더에 소리 파일을 추가하세요.")
            return False
        elif debug:
            print(f"일부 소리 파일({', '.join(missing_files)})이 누락되었습니다. 진행합니다.")

    result_sound = None
    processed_chars = 0  # 처리된 문자 수 추적

    # 텍스트 각 문자의 초성을 추출하여 음성 생성
    for ch in text:
        try:
            if ch.isspace():  # 공백 처리
                # 공백은 짧은 무음으로 처리
                if result_sound is not None:
                    silence = AudioSegment.silent(duration=100)  # 100ms 무음
                    result_sound += silence
                    processed_chars += 1
                continue

            # 한글 자모 분리
            try:
                jamo_ch = j2hcj(h2j(ch))
            except Exception as je:
                if debug:
                    print(f"자모 분리 오류 ('{ch}'): {str(je)}")
                continue

            if not jamo_ch or not jamo_ch[0] or jamo_ch[0] not in char_sounds:
                if debug:
                    print(f"문자 '{ch}'에서 추출한 초성 '{jamo_ch[0] if jamo_ch and jamo_ch[0] else '없음'}'에 해당하는 소리 파일이 없습니다.")
                continue

            char_sound = char_sounds[jamo_ch[0]]

            # 피치 랜덤 조절
            octaves = 2 * random.uniform(0.96, 1.15)
            new_sample_rate = int(char_sound.frame_rate * (2.0 ** octaves))

            # 음성 변환 및 합치기
            pitch_char_sound = char_sound._spawn(char_sound.raw_data, overrides={'frame_rate': new_sample_rate})
            result_sound = pitch_char_sound if result_sound is None else result_sound + pitch_char_sound
            processed_chars += 1
        except Exception as e:
            if debug:
                print(f"경고: 문자 '{ch}' 처리 중 오류 발생: {str(e)}")

    # 처리된 문자 수 확인
    if debug:
        print(f"처리된 문자 수: {processed_chars}/{len(text)}")

    # 처리된 문자가 없는 경우 기본 소리 생성
    if result_sound is None:
        if debug:
            print("처리된 문자가 없어 기본 알림음을 생성합니다.")
        # 기본 알림음 생성
        try:
            result_sound = AudioSegment.silent(duration=500)  # 500ms 무음
            beep = AudioSegment.sine(frequency=440, duration=200)  # 간단한 비프음
            result_sound = result_sound + beep
        except Exception as default_sound_err:
            if debug:
                print(f"기본 알림음 생성 오류: {str(default_sound_err)}")
            return False

    # 결과 파일 저장
    if result_sound:
        try:
            # 출력 디렉토리가 존재하지 않으면 생성
            output_dir = os.path.dirname(output_file)
            if output_dir and not os.path.exists(output_dir):
                os.makedirs(output_dir, exist_ok=True)

            # 파일 저장 시도
            result_sound.export(output_file, format="wav")
            if debug:
                print(f"성공: 음성 파일이 저장되었습니다 - {output_file}")
            return True
        except Exception as e:
            if debug:
                print(f"오류: 파일 저장 실패: {str(e)}")
    else:
        print("오류: 변환할 소리가 없습니다.")

    return False

# 나머지 코드는 그대로 유지