package com.pairing.buds.common.response;

import lombok.Getter;

@Getter
public enum Message {

    USER_NOT_FOUND("해당 사용자를 찾을 수 없습니다."),
    ADMIN_NOT_FOUND("해당 관리자를 찾을 수 없습니다."),
    ANSWER_NOT_FOUND("해당 관리자를 찾을 수 없습니다."),
    USER_ALREADY_EXISTS("이미 존재하는 사용자입니다."),
    SLEEP_NOT_FOUND("존재하지 않는 기상 입니다"),
    SERVER_ERROR("서버 오류가 발생했습니다"),
    DIARY_NOT_FOUND("해당 일기를 찾을 수 없습니다."),
    USER_NOT_EQUAL("다른 유저의 데이터에 접근할 수 없습니다."),
    QUESTION_NOT_FOUND("해당 문의를 찾을 수 없습니다."),
    ARGUMENT_NOT_PROPER("적절하지 않은 인자입니다."),
    TYPE_NOT_FOUND("해당 타입은 존재하지 않습니다."),

    OK("성공"),
    CREATED("성공")
    ;

    private final String text;
    Message(String text) { this.text = text; }

}
