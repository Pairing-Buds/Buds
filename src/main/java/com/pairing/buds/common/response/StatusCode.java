package com.pairing.buds.common.response;

import lombok.Getter;

@Getter
public enum StatusCode {

    OK(200),
    CREATED(201),
    BAD_REQUEST(400),
    NOT_FOUND(404),
    INTERNAL_SERVER_ERROR(500);

    private final int httpStatus;

    StatusCode(int httpStatus) { this.httpStatus = httpStatus; }

}
