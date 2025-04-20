package com.pairing.buds.common.exception;

public class ApiException extends RuntimeException {

    private final StatusCode code;
    private final Message messageEnum;

    public ApiException(StatusCode code, Message messageEnum) {
        super(Common.toString(code, messageEnum));
        this.code = code;
        this.messageEnum = messageEnum;
    }

    public StatusCode getCode() { return code; }
    public Message getMessageEnum() { return messageEnum; }

}
