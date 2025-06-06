package com.pairing.buds.common.auth.utils;

import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.JwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import jakarta.annotation.PostConstruct;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.Getter;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.util.Date;
import java.util.UUID;

/**
 * JWT 토큰의 생성 및 검증을 담당하는 클래스.
 * Spring Security와 함께 사용, HTTP 요청에서 JWT를 기반으로 사용자를 인증하는 데 사용됨
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class JwtTokenProvider {

    @Value("${jwt.secret}")
    private String secretKey;

    @Value("${jwt.access-expiration-time}")
    private long accessExpiration;
    @Getter
    @Value("${jwt.refresh-expiration-time}")
    private long refreshExpiration;

    /** HMAC SHA 알고리즘 사용을 위한 전역 SecretKey 변수 **/
    private SecretKey secretKeyInstance;

    /** secretKey를 한 번만 바이트 배열로 변환하여 SecretKey 생성 **/
    @PostConstruct
    public void init() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        this.secretKeyInstance = Keys.hmacShaKeyFor(keyBytes);
    }

    private static final Logger logger = LoggerFactory.getLogger(JwtTokenProvider.class);


    /** 엑세스 토큰 생성 메서드 **/
    public String createAccessToken(Integer userId, long version, String role) {
        Date now = new Date();
        String jti = UUID.randomUUID().toString();

        return Jwts.builder()
                .id(jti)
                .claim("userId", userId)
                .claim("role", role)
                .claim("ver", version)
                .issuedAt(now)
                .expiration(new Date(now.getTime() + accessExpiration))
                .signWith(secretKeyInstance)
                .compact();
    }

    /** 리프레시 토큰 생성 메서드 **/
    public String createRefreshToken(Integer userId) {
        Date now = new Date();
        String jti = UUID.randomUUID().toString();

        return Jwts.builder()
                .id(jti)
                .claim("userId", userId)
                .issuedAt(now)
                .expiration(new Date(now.getTime() + refreshExpiration))
                .signWith(secretKeyInstance)
                .compact();
    }

    /**
     * response 에 access 토큰과 refresh 토큰을 HttpOnly 쿠키로 추가
     */
    public void addTokensToResponse(HttpServletResponse response, String accessToken, String refreshToken) {
        // 1) Access Token 쿠키 설정
        Cookie accessCookie = new Cookie("access_token", accessToken);
        accessCookie.setHttpOnly(true);                  // 자바스크립트 접근 차단
        accessCookie.setSecure(false);                    // HTTPS에서만 전송
        accessCookie.setPath("/");                       // 전체 경로에서 접근 가능
        accessCookie.setMaxAge((int) (accessExpiration / 1000));  // 만료 시간(초)
        response.addCookie(accessCookie);

        // 2) Refresh Token 쿠키 설정
        Cookie refreshCookie = new Cookie("refresh_token", refreshToken);
        refreshCookie.setHttpOnly(true);
        refreshCookie.setSecure(false);
        refreshCookie.setPath("/");
        refreshCookie.setMaxAge((int) (refreshExpiration / 1000));
        response.addCookie(refreshCookie);
    }

    /** 쿠키에서 토큰 추출 **/
    public String extractCookie(HttpServletRequest req, String name) {
        if (req.getCookies() == null) return null;
        for (Cookie c : req.getCookies()) {
            if (c.getName().equals(name)) return c.getValue();
        }
        return null;
    }

    /** 토큰에서 ver(claim) 꺼내기 **/
    public long getVersionFromToken(String token) {
        return Jwts.parser()
                .verifyWith(secretKeyInstance)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .get("ver", Long.class);
    }

    /** 토큰에서 role 추출 */
    public String getRoleFromToken(String token) {
        return Jwts.parser()
                .verifyWith(secretKeyInstance)
                .build()
                .parseSignedClaims(token)
                .getPayload()
                .get("role", String.class);
    }

    /** jwt 토큰에서 userId 추출 **/
    public Integer getUserId(String token) {
        return Jwts.parser()
                .verifyWith(secretKeyInstance)
                .build()
                .parseSignedClaims(token) // JWT의 서명 검증 진행, JWT의 페이로드에서 Claims 추출
                .getPayload()
                .get("userId", Integer.class);
    }

    public boolean validateToken(String token) {
        try {
            // 서명 검증 + 만료 검증 + 포맷 검증
            Jwts.parser()
                    .verifyWith(secretKeyInstance)
                    .build()
                    .parseSignedClaims(token);
            return true;
        } catch (ExpiredJwtException e) {
            logger.info("만료된 JWT: {}", e.getMessage());
            return false;
        } catch (JwtException | IllegalArgumentException e) {
            logger.warn("JWT 검증 실패: {}", e.getMessage());
            return false;
        }
    }

    /** 쿠키에서 엑세스 토큰 추출 - 서브 메서드 **/
    public String resolveAccessToken(HttpServletRequest request) {
        String bearerToken = request.getHeader("Authorization");
        if (bearerToken != null && bearerToken.startsWith("Bearer ")) {
            return bearerToken.substring(7);
        }
        return extractCookie(request, "access_token");
    }

    /** 쿠키에서 리프레시 토큰 추출 - 서브 메서드 **/
    public String resolveRefreshToken(HttpServletRequest request) {
        return extractCookie(request, "refresh_token");
    }

}
