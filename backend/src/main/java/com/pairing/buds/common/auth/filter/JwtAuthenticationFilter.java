package com.pairing.buds.common.auth.filter;

import com.pairing.buds.common.auth.service.RedisService;
import com.pairing.buds.common.auth.utils.CustomUserDetails;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import io.jsonwebtoken.JwtException;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.Collection;

/**
 * 클라이언트 요청에 포함된 JWT 토큰 확인하고 이를 기반으로 인증 처리
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtTokenProvider jwtTokenProvider;
    private final UserRepository userRepository;
    private final RedisService redisService;

    private final String[] publicPath = {
            "/login", // 로그인
            "/auth/sign-up", // 회원가입

            "/auth/email/request", // 회원가입 이메일 인증-토큰 요청
            "/auth/verify-email", // 회원가입 이메일 인증-토큰 검증
            "/auth/email/request/password-reset", // 비밀번호 재설정 이메일 인증-토큰 요청
            "/auth/reset-password", // 비밀번호 재설정-토큰 검증
    };

    public boolean isPublicPath(HttpServletRequest request){
        String uri = request.getRequestURI();

        for(String path : publicPath){
            if(path.equals(uri)){
                return true;
            }
        }
        return false;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain)
            throws ServletException, IOException {

        if (isPublicPath(request)){
            chain.doFilter(request, response);
            return;
        }

        // 토큰 추출
        String accessToken = extractCookie(request, "access_token");
        String refreshToken = extractCookie(request, "refresh_token");
        Authentication auth;
        try {
            auth = resolveAuthentication(accessToken, refreshToken, response);
        } catch (JwtException ex) {
            log.warn("JWT 처리 중 오류 발생: {}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "유효하지 않은 토큰입니다.");
            return;
        }

        // 토큰이 없거나 재로그인이 필요한 상태 -> 401 반환
        if (auth == null) {
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "인증 정보가 없습니다");
            return;
        }
        SecurityContextHolder.getContext().setAuthentication(auth);

        chain.doFilter(request, response);
    }

    /**
     * Access/Refresh 토큰을 받아서,
     *  1) accessToken이 유효하면 해당 Authentication 반환
     *  2) accessToken 만료 & refreshToken 유효 & Redis와 일치하면 새 access 발급 Authentication 반환
     *  3) 그 외엔 null 반환
     */
    private Authentication resolveAuthentication(String accessToken,
                                                 String refreshToken,
                                                 HttpServletResponse response) {
        // A) accessToken이 유효하면 바로 인증 (리프레시 일치 여부 확인 추가?)
        if (accessToken != null && jwtTokenProvider.validateToken(accessToken)) {
            return getAuthenticationFromAccessToken(accessToken);
        }

        // B) accessToken 만료 & refreshToken 유효 & Redis와 일치하면 새 access 발급
        if (StringUtils.hasText(refreshToken)
                && jwtTokenProvider.validateToken(refreshToken)) {
            Integer userId = jwtTokenProvider.getUserId(refreshToken);
            String savedRefresh = redisService.getRefreshToken(userId);

            if (refreshToken.equals(savedRefresh)) {
                String newAccess = jwtTokenProvider.createAccessToken(userId);
                // 쿠키에 새 Access만, Refresh는 그대로 재설정
                jwtTokenProvider.addTokensToResponse(response, newAccess, refreshToken);
                return getAuthenticationFromAccessToken(newAccess);
            }
        }

        // 인증 정보 없음
        return null;
    }

    private Authentication getAuthenticationFromAccessToken(String token) {
        Integer userId = jwtTokenProvider.getUserId(token);
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다. id=" + userId));

        // 권한 정보만 CustomUserDetails에서 꺼내 온다고 가정
        CustomUserDetails userDetails = new CustomUserDetails(user);
        Collection<? extends GrantedAuthority> authorities = userDetails.getAuthorities();

        return new UsernamePasswordAuthenticationToken(
                userId,
                null,
                authorities
        );
    }

    private String extractCookie(HttpServletRequest req, String name) {
        if (req.getCookies() == null) return null;
        return Arrays.stream(req.getCookies())
                .filter(c -> name.equals(c.getName()))
                .map(Cookie::getValue)
                .findFirst()
                .orElse(null);
    }

}