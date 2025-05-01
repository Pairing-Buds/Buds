package com.pairing.buds.common.auth.controller;

import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
import com.pairing.buds.common.auth.service.RedisService;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/refresh")
public class RefreshController {

    private final JwtTokenProvider jwtTokenProvider;
    private final RedisService redisService;

    /** 쿠키에서 토큰 꺼내기 **/
    private String extractCookie(HttpServletRequest request, String cookieName) {
        if (request.getCookies() != null) {
            for (Cookie cookie : request.getCookies()) {
                if (cookieName.equals(cookie.getName())) {
                    return cookie.getValue();
                }
            }
        }
        return null;
    }

    @PostMapping("")
    public ResponseDto refreshAccessToken(HttpServletRequest request, HttpServletResponse response) {
        String refreshToken = extractCookie(request, "refresh_token");

        if (refreshToken == null || jwtTokenProvider.isExpired(refreshToken)) {
            return new ResponseDto(StatusCode.UNAUTHORIZED, "Refresh Token이 유효하지 않습니다.");
        }

        Integer userId = jwtTokenProvider.getUserId(refreshToken);

        // Redis에 저장된 토큰과 비교
        String savedRefreshToken = redisService.getRefreshToken(userId);
        if (savedRefreshToken == null || !savedRefreshToken.equals(refreshToken)) {
            return new ResponseDto(StatusCode.UNAUTHORIZED, "Refresh Token이 서버에 없습니다. 재로그인 필요");
        }

        String newAccessToken = jwtTokenProvider.createAccessToken(userId);
        // 쿠키에 새로운 토큰 세팅하기
        jwtTokenProvider.addTokensToResponse(response, newAccessToken, refreshToken);

        return new ResponseDto(StatusCode.OK, "Access Token 재발급 완료");
    }


//    @GetMapping("/test/redis-save")
//    public ResponseEntity<String> saveTest() {
//        redisService.saveRefreshToken(999, "test-refresh-token", 60000);
//        return ResponseEntity.ok("저장 성공");
//    }
//
//    @GetMapping("/test/redis-get")
//    public ResponseEntity<String> getTest() {
//        String token = redisService.getRefreshToken(999);
//        return ResponseEntity.ok("조회된 토큰: " + token);
//    }
//
//    @GetMapping("/jwt-test")
//    public ResponseEntity<String> jwtTest(HttpServletRequest request) {
//        String token = null;
//        if (request.getCookies() != null) {
//            token = Arrays.stream(request.getCookies())
//                    .filter(c -> "access_token".equals(c.getName()))
//                    .findFirst()
//                    .map(Cookie::getValue)
//                    .orElse(null);
//        }
//        return ResponseEntity.ok("쿠키에서 뽑은 토큰: " + token);
//    }

}
