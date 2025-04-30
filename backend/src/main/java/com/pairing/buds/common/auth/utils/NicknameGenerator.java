package com.pairing.buds.common.auth.utils;

import com.pairing.buds.common.auth.dto.response.RandomNameResDto;
import org.springframework.stereotype.Component;

import java.security.SecureRandom;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

@Component
public class NicknameGenerator {

    private static final List<String> ADJECTIVES = Arrays.asList(
            "귀여운", "멋진", "용감한", "부드러운", "활발한",
            "우아한", "조용한", "따뜻한", "시원한", "강력한",
            "행복한", "슬기로운", "친절한", "화려한", "깨끗한",
            "빛나는", "차분한", "영리한", "부지런한", "상쾌한",
            "절제된", "든든한", "생동감있는", "풍부한", "매력적인",
            "차가운", "밝은", "어두운", "정직한", "성실한",
            "순수한", "진실한", "겸손한", "대담한", "신비로운",
            "탐험적인", "창의적인", "고요한", "환한", "날카로운",
            "단단한", "섬세한", "거친", "풍성한", "달콤한",
            "향기로운", "자유로운", "소중한"
    );

    private static final List<String> MAMMALS = Arrays.asList(
            "토끼", "사자", "호랑이", "여우", "고양이",
            "강아지", "원숭이", "코끼리", "기린", "판다",
            "늑대", "곰", "사슴", "수달", "너구리",
            "밍크", "코알라", "캥거루", "코뿔소", "하마",
            "오소리", "영양", "두더지", "친칠라", "고릴라",
            "침팬지", "너트리아", "기니피그", "족제비", "돌고래",
            "고래", "바다표범", "바다사자", "반달가슴곰", "흰곰",
            "하이에나", "퓨마", "재규어", "표범", "치타",
            "여우원숭이", "코요테", "오랑우탄", "크레스티드게코", "들소",
            "물개", "비버", "스컹크", "레오파드게코", "또야지"
    );

    private final Random rnd = new SecureRandom();

    /** 형용사 + 동물명 조합 랜덤 닉네임 반환 **/
    public RandomNameResDto generateName() {
        String adj = ADJECTIVES.get(rnd.nextInt(ADJECTIVES.size()));
        String mammal = MAMMALS.get(rnd.nextInt(MAMMALS.size()));
        return new RandomNameResDto(adj + " " + mammal);
    }

}
