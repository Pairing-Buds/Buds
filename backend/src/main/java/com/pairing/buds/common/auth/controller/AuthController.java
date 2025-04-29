package com.pairing.buds.common.auth.controller;

import com.pairing.buds.common.auth.dto.request.UserSignupReqDto;
import com.pairing.buds.common.auth.service.AuthService;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/sign-up")
    public ResponseDto userSignup(
            @Valid @RequestBody UserSignupReqDto dto) {
        authService.userSignup(dto);
        return new ResponseDto(StatusCode.CREATED, Message.OK);
    }

}
