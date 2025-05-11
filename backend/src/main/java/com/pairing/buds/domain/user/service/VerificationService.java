package com.pairing.buds.domain.user.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.stream.Collectors;
import java.util.stream.IntStream;

@Service
public class VerificationService {

    private static final String CODE_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    private static final int    CODE_LENGTH = 6;
    private static final SecureRandom RANDOM = new SecureRandom();

    private final RedisTemplate<String, String> redisTemplate;

    public VerificationService(@Qualifier("CustomRedisTemplate") RedisTemplate<String, String> redisTemplate) {
        this.redisTemplate = redisTemplate;
    }

    /** 토큰 생성 후 Redis에 저장하고 반환 */
    public String createToken(String email) {
        // 6자리 랜덤 대문자 코드 생성
        String token = IntStream.range(0, CODE_LENGTH)
                .map(i -> RANDOM.nextInt(CODE_CHARS.length()))
                .mapToObj(CODE_CHARS::charAt)
                .map(Object::toString)
                .collect(Collectors.joining());

        // 레디스에 30분간 보관
        String key = "email:verify:" + token;
        redisTemplate.opsForValue().set(key, email, Duration.ofMinutes(30));

        return token;
    }

    /** 토큰 검증: Redis에서 꺼내면서 삭제 */
    public void validateToken(String token) {
        String key = "email:verify:" + token;
        String email = redisTemplate.opsForValue().get(key);
        if (email == null) {
            throw new ApiException(StatusCode.BAD_REQUEST, Message.TOKEN_NOT_FOUND);
        }
        redisTemplate.delete(key);
    }

    public String getEmailAndInvalidate(String token) {
        String key = "email:verify:" + token;
        String email = redisTemplate.opsForValue().get(key);
        if (email == null) {
            throw new ApiException(StatusCode.BAD_REQUEST, Message.TOKEN_NOT_FOUND);
        }
        redisTemplate.delete(key);
        return email;
    }

}
