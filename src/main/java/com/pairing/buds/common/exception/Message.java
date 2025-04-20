package com.pairing.buds.common.exception;

public enum Message {

    USER_NOT_FOUND("User not found"),
    USER_ALREADY_EXISTS("User already exists"),
    SERVER_ERROR("서버 오류가 발생했습니다");

    private final String text;
    Message(String text) { this.text = text; }
    public String getText() { return text; }

}
