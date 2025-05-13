#!/usr/bin/env python3
import random
import argparse
import sys
import os
from pydub import AudioSegment
from jamo import h2j, j2hcj


def convert_text_to_animalese(text, output_file):
    """텍스트를 동물의 숲 스타일 음성으로 변환하고 파일로 저장"""
    if not text or not output_file:
        print("오류: 텍스트와 출력 파일 경로가 필요합니다.")
        return False

    # 초성 목록 정의 (공백 포함)
    char_list = ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ', 'ㄲ', 'ㄸ', 'ㅃ', 'ㅆ', 'ㅉ', ' ']
    char_sounds = {}

    # 소리 파일 로드
    for idx, item in enumerate(char_list):
        if item == ' ':  # 공백은 건너뜀
            continue

        str_idx = str(idx + 1).zfill(2)
        try:
            char_sounds[item] = AudioSegment.from_mp3(f'./sources/{str_idx}.padata')
        except Exception as e:
            print(f"경고: {item}({str_idx})의 소리 파일을 로드할 수 없습니다: {str(e)}")

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

            result_sound.export(output_file, format="wav")
            print(f"성공: 음성 파일이 저장되었습니다 - {output_file}")
            return True
        except Exception as e:
            print(f"오류: 파일 저장 실패: {str(e)}")
    else:
        print("오류: 변환할 소리가 없습니다.")

    return False


# 명령줄 인자 파서 설정
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='동물의 숲 NPC 목소리 생성기')
    parser.add_argument('-t', '--text', help='변환할 텍스트')
    parser.add_argument('-o', '--output', help='출력 파일 경로')
    args = parser.parse_args()

    if args.text and args.output:
        convert_text_to_animalese(args.text, args.output)
    else:
        print("사용법: python pyanimalese_cli.py -t '텍스트' -o '출력파일.wav'")
        sys.exit(1)