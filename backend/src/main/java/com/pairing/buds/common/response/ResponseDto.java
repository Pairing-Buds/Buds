package com.pairing.buds.common.response;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public class ResponseDto {

    private StatusCode statusCode;
    private Object resMsg;

}
