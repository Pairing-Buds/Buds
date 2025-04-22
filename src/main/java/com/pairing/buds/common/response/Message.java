package com.pairing.buds.common.response;

import lombok.Getter;

@Getter
public enum Message {

    USER_NOT_FOUND("User not found"),
    SLEEP_NOT_FOUND("Sleep not found"),
    USER_ALREADY_EXISTS("User already exists"),
    SERVER_ERROR("서버 오류가 발생했습니다"),
    OK("OK"),
    AUGUMENT_NOT_PROPER("Argument Not Proper"),
    ;

    private final String text;
    Message(String text) { this.text = text; }

}
