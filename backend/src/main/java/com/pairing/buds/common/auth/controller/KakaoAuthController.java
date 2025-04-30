package com.pairing.buds.common.auth.controller;

import com.pairing.buds.common.auth.dto.request.KakaoTokenReqDto;
import com.pairing.buds.common.auth.dto.response.KakaoTokenResDto;
import com.pairing.buds.common.auth.service.KakaoLoginService;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth/kakao")
public class KakaoAuthController {

    private final KakaoLoginService kakaoLoginService;
    private final JwtTokenProvider  jwtTokenProvider;

    @PostMapping("/login")
    public ResponseDto authenticateWithKakao(@RequestBody KakaoTokenReqDto tokenRequest,
                                                               HttpServletResponse response) {
        KakaoTokenResDto tokens = kakaoLoginService.processKakaoLoginAndGetToken(
                tokenRequest.getAccessToken()
        );

        jwtTokenProvider.addTokensToResponse(
                response,
                tokens.getAccessToken(),
                tokens.getRefreshToken()
        );

        return new ResponseDto(StatusCode.OK, tokens);
    }

}
