package com.pairing.buds.common.exception;

import lombok.Getter;

@Getter
public class ApiException extends RuntimeException {

    private final StatusCode code;
    private final Message messageEnum;

    public ApiException(StatusCode code, Message messageEnum) {
        super(Common.toString(code, messageEnum));
        this.code = code;
        this.messageEnum = messageEnum;
    }

}
