package com.pairing.buds.common.exception;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ResponseBody> handleApi(ApiException ex) {
        StatusCode code = ex.getCode();
        Message    msg  = ex.getMessageEnum();
        ResponseBody body = new ResponseBody(code, msg.getText());
        return ResponseEntity
                .status(code.getHttpStatus())
                .body(body);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ResponseBody> handleOther(Exception ex) {
        ResponseBody body = new ResponseBody(
                StatusCode.INTERNAL_SERVER_ERROR,
                Message.SERVER_ERROR.getText()
        );
        return ResponseEntity
                .status(StatusCode.INTERNAL_SERVER_ERROR.getHttpStatus())
                .body(body);
    }

}
