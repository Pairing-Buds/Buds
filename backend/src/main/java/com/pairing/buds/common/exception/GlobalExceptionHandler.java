package com.pairing.buds.common.exception;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class GlobalExceptionHandler {

    // DTO 검증 실패 전용(빈 문자열 포함)
    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ResponseDto> handleValidationErrors(MethodArgumentNotValidException ex) {
        // 첫 번째 에러 메시지 꺼내기
        String message = ex.getBindingResult()
                .getFieldErrors()
                .stream()
                .findFirst()
                .map(FieldError::getDefaultMessage)
                .orElse("잘못된 입력입니다.");
        ResponseDto body = new ResponseDto(StatusCode.BAD_REQUEST, message);
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(body);
    }

    // 서비스나 enum 변환 단계에서 던진 ApiException
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
