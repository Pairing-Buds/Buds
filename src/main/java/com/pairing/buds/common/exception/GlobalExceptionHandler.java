package com.pairing.buds.common.exception;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ApiException.class)
    public ResponseEntity<ResponseDto> handleApi(ApiException ex) {
        StatusCode code = ex.getCode();
        Message msg  = ex.getMessageEnum();
        ResponseDto body = new ResponseDto(code, msg.getText());
        return ResponseEntity
                .status(code.getHttpStatus())
                .body(body);
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ResponseDto> handleOther(Exception ex) {
        ResponseDto body = new ResponseDto(
                StatusCode.INTERNAL_SERVER_ERROR,
                Message.SERVER_ERROR.getText()
        );
        return ResponseEntity
                .status(StatusCode.INTERNAL_SERVER_ERROR.getHttpStatus())
                .body(body);
    }

}
