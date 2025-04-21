package com.pairing.buds.common.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;

@AllArgsConstructor
@Getter
public class ResponseBody {

    private StatusCode statusCode;
    private String     resMsg;

}
