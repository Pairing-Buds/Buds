package com.pairing.buds.common.auth.service;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.Set;
import java.util.concurrent.TimeUnit;

@Service
public class RedisService {

    private final RedisTemplate<String, String> redisTemplate;
    private final String REFRESH_PREFIX = "refresh:";
    private static final String VERSION_PREFIX = "ver:";

    public RedisService(@Qualifier("CustomRedisTemplate") RedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    // RefreshToken 저장
    public void saveRefreshToken(Integer userId, String refreshToken, long expirationMillis) {
        String key = REFRESH_PREFIX + userId;
        redisTemplate.opsForValue().set(key, refreshToken, expirationMillis, TimeUnit.MILLISECONDS);
    }

    // RefreshToken 조회
    public String getRefreshToken(Integer userId) {
        String key = REFRESH_PREFIX + userId;
        return redisTemplate.opsForValue().get(key);
    }

    // RefreshToken 삭제 (로그아웃)
    public void deleteRefreshToken(Integer userId) {
        String key = REFRESH_PREFIX + userId;
        redisTemplate.delete(key);
    }

    // (중복로그인 테스트용) 모든 키를 가져온 뒤 한 번에 삭제
    public void deleteRefreshTokenAll() {
        Set<String> keys = redisTemplate.keys("refresh_token:*");
        if (!keys.isEmpty()) {
            redisTemplate.delete(keys);
        }
    }

    // 로그인 시 호출, 버전 1 증가, 증가된 값 반환
    public long incrementTokenVersion(Integer userId) {
        return redisTemplate.opsForValue().increment(VERSION_PREFIX + userId, 1);
    }

    // 요청 검증 시 호출: 현재 버전 조회 (없으면 0)
    public long getTokenVersion(Integer userId) {
        String val = redisTemplate.opsForValue().get(VERSION_PREFIX + userId);
        return (val == null) ? 0L : Long.parseLong(val);
    }

    // 로그아웃 시 버전 삭제
    public void deleteTokenVersion(Integer userId) {
        redisTemplate.delete(VERSION_PREFIX + userId);
    }

}
