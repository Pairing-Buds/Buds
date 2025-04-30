package com.pairing.buds.common.auth.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pairing.buds.common.auth.dto.request.UserLoginReqDto;
import com.pairing.buds.common.auth.utils.CustomUserDetails;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Optional;
import java.util.concurrent.TimeUnit;

@Component
public class CustomLoginFilter extends AbstractAuthenticationProcessingFilter {
    private final JwtTokenProvider jwtTokenProvider;
    private final RedisTemplate<String, String> redisTemplate;
    private final ObjectMapper objectMapper = new ObjectMapper();

    public CustomLoginFilter(AuthenticationManager authenticationManager,
                             JwtTokenProvider jwtTokenProvider,
                             @Qualifier("CustomRedisTemplate") RedisTemplate<String, String> redisTemplate) {
        super(new AntPathRequestMatcher("/login", "POST"), authenticationManager);
        this.jwtTokenProvider = jwtTokenProvider;
        this.redisTemplate = redisTemplate;
    }

    @Override
    public Authentication attemptAuthentication(HttpServletRequest request,
                                                HttpServletResponse response)
            throws AuthenticationException, IOException {

        // HTTP 메서드 검증
        if (!"POST".equalsIgnoreCase(request.getMethod())) {
            throw new AuthenticationServiceException("지원하지 않는 메소드: " + request.getMethod());
        }
        // Content-Type 검증
        if (!MediaType.APPLICATION_JSON_VALUE.equals(request.getContentType())) {
            throw new AuthenticationServiceException("Content-Type must be application/json");
        }

        // JSON 바디 파싱
        UserLoginReqDto creds;
        try {
            creds = objectMapper.readValue(request.getInputStream(), UserLoginReqDto.class);
        } catch (IOException e) {
            throw new AuthenticationServiceException("잘못된 로그인 요청 포맷입니다.", e);
        }
        String username  = Optional.ofNullable(creds.getUserEmail()).map(String::trim).orElse("");
        String password = Optional.ofNullable(creds.getPassword()).orElse("");

        // 다중 로그인 방지 로직 (새 로그인 요청이 들어오면 기존 로그인 세션(lazy 키)을 삭제)
        markUserAsLoggedIn(username);

        // 인증 토큰 생성 및 상세정보 설정
        UsernamePasswordAuthenticationToken authRequest =
                new UsernamePasswordAuthenticationToken(username, password);

        // AuthenticationManager로 인증 위임
        return this.getAuthenticationManager().authenticate(authRequest);
    }

    @Override
    protected void successfulAuthentication(HttpServletRequest request,
                                            HttpServletResponse response,
                                            FilterChain chain,
                                            Authentication authResult) throws IOException, ServletException {

        // SecurityContext 저장
        SecurityContextHolder.getContext().setAuthentication(authResult);

        // 토큰생성 + 헤더/쿠키 세팅
        CustomUserDetails principal = (CustomUserDetails) authResult.getPrincipal();
        Integer userId = principal.getUserId();

        String accessToken = jwtTokenProvider.createAccessToken(userId); // 액세스 토큰 생성
        String refreshToken = jwtTokenProvider.createRefreshToken(userId); // 리프레시 토큰 생성

        // Redis에 새로운 로그인 세션 키 저장 (30분)
        markUserAsLoggedIn(principal.getUsername());

//        response.setHeader("Authorization", "Bearer " + accessToken); // 헤더 설정
        jwtTokenProvider.addTokensToResponse(response, accessToken, refreshToken); // 쿠키 설정

        Authentication newAuth = new UsernamePasswordAuthenticationToken(
                userId,
                null,
                principal.getAuthorities()
        );
        SecurityContextHolder.getContext().setAuthentication(newAuth);

//        // 3) JSON 응답(추후 삭제)
//        response.setContentType(MediaType.APPLICATION_JSON_VALUE);
//        response.setStatus(HttpServletResponse.SC_OK);
//        response.getWriter().write(
//                objectMapper.writeValueAsString(
//                        Map.of(
//                                "status",       "OK",
//                                "accessToken",  accessToken,
//                                "refreshToken", refreshToken
//                        )
//                )
//        );
        response.getWriter().close();

    }

    @Override
    protected void unsuccessfulAuthentication(HttpServletRequest request,
                                              HttpServletResponse response,
                                              AuthenticationException failed) throws IOException {
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "인증 실패");
    }

    // 로그인 시 Redis에 로그인 상태를 저장
    private void markUserAsLoggedIn(String email) {
        String loginStatusKey = "user:login:" + email;
        redisTemplate.opsForValue().set(loginStatusKey, "loggedIn", 30, TimeUnit.MINUTES); // 30분 동안 로그인 상태 유지
    }

    // 다중 로그인 방지를 위한 Redis에서 사용자 로그인 상태를 확인
    private boolean checkIfUserIsLoggedIn(String email) {
        String loginStatusKey = "user:login:" + email;
        return redisTemplate.hasKey(loginStatusKey);
    }

    // 로그아웃시 Redis에서 해당 키 삭제
    private void markUserAsLoggedOut(String email) {
        String loginStatusKey = "user:login:" + email;
        redisTemplate.delete(loginStatusKey);
    }

}