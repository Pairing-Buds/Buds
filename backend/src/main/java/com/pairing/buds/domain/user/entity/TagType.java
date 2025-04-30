package com.pairing.buds.domain.user.entity;

public enum TagType {
    KPOP("KPOP"),
    UNDONG("운동"),
    MOVIE("영화"),
    READING("독서"),
    JOB("취업"),
    CERTIFICATION("자격증"),
    FASHION("패션"),
    MUSIC("음악"),
    COOKING("요리"),
    GAME("게임"),
    COMIC("만화");

    private final String displayName;

    TagType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
