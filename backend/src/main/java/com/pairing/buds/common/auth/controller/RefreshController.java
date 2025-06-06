package com.pairing.buds.common.auth.controller;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
import com.pairing.buds.common.auth.service.RedisService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.util.WebUtils;

@RestController
@RequiredArgsConstructor
@RequestMapping("/refresh")
@PreAuthorize("hasRole('ADMIN')")
public class RefreshController {

    private final JwtTokenProvider jwtTokenProvider;
    private final RedisService redisService;

    @PostMapping
    public ResponseDto refreshAccessToken(HttpServletRequest request,
                                          HttpServletResponse response) {

        // 쿠키에서 리프레시 토큰 꺼내기
        Cookie refreshCookie = WebUtils.getCookie(request, "refresh_token");
        if (refreshCookie == null)
            throw new ApiException(StatusCode.UNAUTHORIZED, Message.TOKEN_NOT_FOUND); // 리프레시 토큰이 없습니다
        String refreshToken = refreshCookie.getValue();
         // 유효성 검사 & Redis 에 저장된 것과 비교
        if (!jwtTokenProvider.validateToken(refreshToken))
            throw new ApiException(StatusCode.UNAUTHORIZED, Message.TOKEN_NOT_FOUND); // 유효하지 않은 리프레시 토큰입니다.

        Integer userId = jwtTokenProvider.getUserId(refreshToken);
        // Redis에 저장된 리프레시 토큰과 비교
        String savedRefresh = redisService.getRefreshToken(userId);
        if (!refreshToken.equals(savedRefresh))
            throw new ApiException(StatusCode.UNAUTHORIZED, Message.TOKEN_NOT_FOUND); // 리프레시 토큰 불일치

        // 새로운 Access 토큰 생성, 발행시 role도 함꼐 전달
        long currentVer = redisService.getTokenVersion(userId);
        String role = jwtTokenProvider.getRoleFromToken(refreshToken);
        String newAccessToken = jwtTokenProvider.createAccessToken(userId, currentVer, role);

        // 쿠키에 새로운 토큰 세팅 (기존 쿠키 덮어쓰기)
        jwtTokenProvider.addTokensToResponse(response, newAccessToken, refreshToken);
        return new ResponseDto(StatusCode.OK, "Access Token 재발급 완료");
    }

}
