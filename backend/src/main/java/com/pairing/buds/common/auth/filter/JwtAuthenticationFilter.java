package com.pairing.buds.common.auth.filter;

import com.pairing.buds.common.auth.service.RedisService;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
import com.pairing.buds.domain.user.repository.UserRepository;
import io.jsonwebtoken.ExpiredJwtException;
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
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;

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

    /**
     * Access Token 유효 & 버전 일치 시 바로 인증 처리
     * Access Token 만료 시 ExpiredJwtException을 캐치해 Refresh 흐름으로 진입
     * Refresh Token 유효 & Redis 저장 토큰과 일치 시 새 Access Token 발급 후 Authentication 재설정
     * 그 외의 경우 401 응답
     */
    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain chain)
            throws ServletException, IOException {

        if (isPublicPath(request)) {
            chain.doFilter(request, response);
            return;
        }

        String accessToken  = extractCookie(request, "access_token");
        String refreshToken = extractCookie(request, "refresh_token");
        Authentication auth = null;

        try {
            if (StringUtils.hasText(accessToken)) {
                try {
                    // 1) Access Token 검증
                    jwtTokenProvider.validateToken(accessToken);

                    // 2) 버전 비교
                    Integer userId   = jwtTokenProvider.getUserId(accessToken);
                    long    claimVer = jwtTokenProvider.getVersionFromToken(accessToken);
                    long    currVer  = redisService.getTokenVersion(userId);
                    if (claimVer != currVer) {
                        response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                                "다른 기기 로그인으로 액세스 토큰이 무효화되었습니다.");
                        return;
                    }

                    // 3) 유효한 Token이라면 인증 정보 생성
                    auth = getAuthenticationFromAccessToken(accessToken);

                } catch (ExpiredJwtException eje) {
                    // 액세스 만료 시 리프레시 확인 로직 실행
                }
            }

            if (auth == null && StringUtils.hasText(refreshToken)) {
                // 4) Refresh Token 검증
                if (jwtTokenProvider.validateToken(refreshToken)) {
                    Integer userId = jwtTokenProvider.getUserId(refreshToken);
                    String savedRefresh = redisService.getRefreshToken(userId);
                    if (refreshToken.equals(savedRefresh)) {
                        // 5) Redis 일치 → 새 Access 발급
                        long currVer = redisService.getTokenVersion(userId);

                        // 새 엑세스 토큰 발행시 role도 함꼐 전달
                        String role   = jwtTokenProvider.getRoleFromToken(refreshToken);
                        String newAccess = jwtTokenProvider.createAccessToken(userId, currVer, role);

                        jwtTokenProvider.addTokensToResponse(response, newAccess, refreshToken);
                        auth = getAuthenticationFromAccessToken(newAccess);
                    } else {
                        response.sendError(HttpServletResponse.SC_UNAUTHORIZED,
                                "리프레시 토큰이 유효하지 않습니다.");
                        return;
                    }
                }
            }

            if (auth == null) {
                response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "인증 정보가 없습니다.");
                return;
            }

            SecurityContextHolder.getContext().setAuthentication(auth);
            chain.doFilter(request, response);

        } catch (JwtException ex) {
            log.warn("JWT 처리 중 오류: {}", ex.getMessage());
            response.sendError(HttpServletResponse.SC_UNAUTHORIZED, "토큰 검증 실패");
        }
    }

    private Authentication getAuthenticationFromAccessToken(String token) {
        Integer userId = jwtTokenProvider.getUserId(token);
        String  role   = jwtTokenProvider.getRoleFromToken(token);

        // role(claim) 기반으로 GrantedAuthority 생성
        SimpleGrantedAuthority authority = new SimpleGrantedAuthority(role);

//        User user = userRepository.findById(userId)
//                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다. id=" + userId));
//
//        // 권한 정보만 CustomUserDetails에서 꺼내 온다고 가정
//        CustomUserDetails userDetails = new CustomUserDetails(user);
//        Collection<? extends GrantedAuthority> authorities = userDetails.getAuthorities();

        return new UsernamePasswordAuthenticationToken(
                userId,
                null,
                List.of(authority)
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