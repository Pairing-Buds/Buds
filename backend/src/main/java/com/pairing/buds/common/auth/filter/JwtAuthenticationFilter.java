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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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
    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    private final String[] publicPath = {"/login","/auth/sign-up"};

    // 메소드
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
        try {
            Authentication auth = resolveAuthentication(accessToken, refreshToken, response);
            if (auth != null) {
                SecurityContextHolder.getContext().setAuthentication(auth);
            }
        } catch (JwtException ex) {
            log.warn("JWT 처리 중 오류 발생: {}", ex.getMessage());
        }

        chain.doFilter(request, response);
    }

    /**
     * Access/Refresh 토큰을 받아서,
     *  1) accessToken이 유효하면 해당 Authentication 반환
     *  2) accessToken 만료 & refreshToken 유효하면 새 accessToken 발급 후 Authentication 반환
     *  3) 그 외엔 null 반환
     */
    private Authentication resolveAuthentication(String accessToken,
                                                 String refreshToken,
                                                 HttpServletResponse response) {
        // A) Access 토큰이 정상 유효할 때
        if (accessToken != null && jwtTokenProvider.validateToken(accessToken)) {
            return getAuthenticationFromAccessToken(accessToken);
        }

        // B) Access 만료 & Refresh 토큰이 정상 유효할 때
        if (accessToken != null
                && jwtTokenProvider.isExpired(accessToken)
                && StringUtils.hasText(refreshToken)
                && jwtTokenProvider.validateToken(refreshToken)) {

            Integer userId     = jwtTokenProvider.getUserId(refreshToken);
            String savedRefresh = redisService.getRefreshToken(userId);

            // Redis에 저장된 리프레시 토큰과 비교
            if (refreshToken.equals(savedRefresh)) {
                // 새 Access 토큰 발급
                String newAccess = jwtTokenProvider.createAccessToken(userId);
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