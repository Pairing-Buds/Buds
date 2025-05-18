package com.pairing.buds.common.response;

import lombok.Getter;

@Getter
public enum Message {

    USER_NOT_FOUND("해당 사용자를 찾을 수 없습니다."),
    ADMIN_NOT_FOUND("해당 관리자를 찾을 수 없습니다."),
    ANSWER_NOT_FOUND("해당 관리자를 찾을 수 없습니다."),
    LETTER_FAVORITE_NOT_FOUND("해당 스크랩을 찾을 수 없습니다."),
    LETTER_NOT_FOUND("해당 편지를 찾을 수 없습니다."),
    QUOTE_NOT_FOUND("명언을 찾을 수 없습니다."),
    USER_ALREADY_EXISTS("이미 존재하는 사용자입니다."),
    SLEEP_NOT_FOUND("존재하지 않는 기상 입니다"),
    SERVER_ERROR("서버 오류가 발생했습니다"),
    DIARY_NOT_FOUND("해당 일기를 찾을 수 없습니다."),
    USER_NOT_EQUAL("다른 유저의 데이터에 접근할 수 없습니다."),
    QUESTION_NOT_FOUND("해당 문의를 찾을 수 없습니다."),
    ARGUMENT_NOT_PROPER("적절하지 않은 인자입니다."),
    ALREADY_VERIFIED("이미 인증된 사용자입니다."),
    TYPE_NOT_FOUND("해당 타입은 존재하지 않습니다."),
    DUPLICATE_EMAIL_EXCEPTION("이미 사용 중인 이메일입니다."),
    FAIL_TO_SEND_EMAIL("이메일 발송에 실패했습니다."),
    TOKEN_NOT_FOUND("유효하지 않거나 만료된 인증 토큰입니다."),
    ALREADY_COMPLETED("이미 완료된 요청입니다."),
    RECEIVER_NOT_FOUND("수신자를 찾을 수 없습니다."),
    TAGS_NOT_SELECTED("저장된 태그가 없습니다."),
    PASSWORD_NOT_MATCHED("비밀번호가 일치하지 않습니다."),
    DATE_IS_NOT_NULL("날짜는 필수 입력 항목입니다."),
    INVALID_USER_CHARACTER("허용되지 않은 캐릭터 값입니다"),
    USER_ALREADY_DELETED("이미 탈퇴한 계정입니다."),
    OUT_OF_LETTER_TOKEN("편지 토큰이 모두 사용되어 요청을 처리할 수 없습니다."),
    TAGS_NOT_FOUND("유효하지 않은 태그가 포함되어 있습니다."),
    RANDOM_NAME_ALREADY_EXIST("이미 존재하는 닉네임입니다."),
    ANSWER_LETTER_ERROR("스스로에게 답장 할 수 없습니다."),
    TAG_CNT_OUT_OF_BOUND("태그는 최대 3개까지 선택 가능합니다."),
    LETTER_HAVE_SENT_ALREADY("이미 대화를 한 적이 있는 대상입니다."),
    LETTER_HAVE_ANSWERED_ALREADY("이미 답장을 한 적이 있는 편지입니다."),
    EMAIL_NOT_FOUND("존재하지 않는 이메일 입니다."),
    LETTER_HISTORY_NOT_FOUND("편지 내역이 없습니다."),
    LAST_LETTER_IS_NOT_ANSWERED_YET("마지막 편지에 대한 답장이 아직 오지 않았습니다."),

    OK("성공"),
    CREATED("성공")
    ;

    private final String text;
    Message(String text) { this.text = text; }

}
