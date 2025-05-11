package com.pairing.buds.common.response;

import lombok.Getter;

@Getter
public enum StatusCode {

    OK(200),
    CREATED(201),
    BAD_REQUEST(400),
    UNAUTHORIZED(401), // Access Token 이 만료 된 상태
    FORBIDDEN(403), // 권한 없는 자원에 접근 한 상태
    NOT_FOUND(404),
    CONFLICT(409), // 중복된 데이터
    INTERNAL_SERVER_ERROR(500);

    private final int httpStatus;

    StatusCode(int httpStatus) { this.httpStatus = httpStatus; }

}
