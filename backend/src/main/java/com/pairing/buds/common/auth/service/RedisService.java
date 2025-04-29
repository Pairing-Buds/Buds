package com.pairing.buds.common.auth.service;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.util.concurrent.TimeUnit;

@Service
public class RedisService {

    private final RedisTemplate<String, String> redisTemplate;
    private final String REFRESH_PREFIX = "refresh:";

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

}
