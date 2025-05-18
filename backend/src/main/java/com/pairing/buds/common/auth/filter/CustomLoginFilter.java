package com.pairing.buds.common.auth.filter;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pairing.buds.common.auth.dto.request.UserLoginReqDto;
import com.pairing.buds.common.auth.service.RedisService;
import com.pairing.buds.common.auth.utils.CustomUserDetails;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.http.MediaType;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationServiceException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.AbstractAuthenticationProcessingFilter;
import org.springframework.security.web.util.matcher.AntPathRequestMatcher;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.Optional;

@Component
public class CustomLoginFilter extends AbstractAuthenticationProcessingFilter {
    private static final ObjectMapper OBJECT_MAPPER = new ObjectMapper();
    private final JwtTokenProvider jwtTokenProvider;
    private final RedisService redisService;

    public CustomLoginFilter(AuthenticationManager authenticationManager,
                             JwtTokenProvider jwtTokenProvider,
                             RedisService redisService) {
        super(new AntPathRequestMatcher("/login", "POST"), authenticationManager);
        this.jwtTokenProvider = jwtTokenProvider;
        this.redisService = redisService;
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
            creds = OBJECT_MAPPER.readValue(request.getInputStream(), UserLoginReqDto.class);
        } catch (IOException e) {
            throw new AuthenticationServiceException("잘못된 로그인 요청 포맷입니다.", e);
        }
        String username  = Optional.ofNullable(creds.getUserEmail()).map(String::trim).orElse("");
        String password = Optional.ofNullable(creds.getPassword()).orElse("");

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

        CustomUserDetails principal = (CustomUserDetails) authResult.getPrincipal();
        Integer userId = principal.getUserId();

        // 이전 RT 무효화, 엑세스 토큰 버전 +1
        redisService.deleteRefreshToken(userId);
        long newVersion = redisService.incrementTokenVersion(userId);

        // principal에 담긴 권한(user 혹은 admin)
        String role = principal.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .findFirst()
                .orElseThrow(() -> new RuntimeException("권한 정보가 없습니다."));

        // 새 토큰 생성 및 저장
        String accessToken = jwtTokenProvider.createAccessToken(userId, newVersion, role); // 액세스 토큰 생성
        String refreshToken = jwtTokenProvider.createRefreshToken(userId); // 리프레시 토큰 생성
        redisService.saveRefreshToken(userId, refreshToken, jwtTokenProvider.getRefreshExpiration());

//        response.setHeader("Authorization", "Bearer " + accessToken); // 헤더 설정
        jwtTokenProvider.addTokensToResponse(response, accessToken, refreshToken); // 쿠키에 새로운 토큰 설정

        // SecurityContext 업데이트
        Authentication newAuth =
            new UsernamePasswordAuthenticationToken(
                userId,
                null,
                principal.getAuthorities()
            );
        SecurityContextHolder.getContext().setAuthentication(newAuth);
    }

    @Override
    protected void unsuccessfulAuthentication(HttpServletRequest request,
                                              HttpServletResponse response,
                                              AuthenticationException failed) throws IOException {
        response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "인증 실패");
    }

}