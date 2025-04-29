package com.pairing.buds.common.auth.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.pairing.buds.common.auth.dto.response.KakaoTokenResDto;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.web.client.HttpClientErrorException;
import org.springframework.web.client.RestTemplate;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class KakaoLoginService {

    private final UserRepository userRepository;
    private final JwtTokenProvider jwtTokenProvider;

    @Value("${kakao.userinfo.url}")
    private String kakaoUserInfoUrl;

    public KakaoTokenResDto processKakaoLoginAndGetToken(String accessToken) {
        String userInfo = getUserInfo(accessToken);
        if (userInfo == null) {
            throw new UsernameNotFoundException("카카오 사용자 정보 조회 실패");
        }

        ObjectMapper objectMapper = new ObjectMapper();
        String email;

        try {
            JsonNode rootNode = objectMapper.readTree(userInfo);
            JsonNode kakaoAccount = rootNode.path("kakao_account");
            email = kakaoAccount.path("email").asText();
        } catch (Exception e) {
            throw new UsernameNotFoundException("사용자 정보 파싱 실패", e);
        }

        Optional<Object> existingUser = userRepository.findByUserEmail(email);
        User user;
        if (existingUser.isPresent()) {
            user = (User) existingUser.get();
        } else {
            user = new User();
            user.setUserEmail(email);
            user = userRepository.save(user);
        }

        String customAccessToken = jwtTokenProvider.createAccessToken(user.getId());
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getId());

        return new KakaoTokenResDto(customAccessToken, refreshToken);
    }

    public String getUserInfo(String accessToken) {
        RestTemplate restTemplate = new RestTemplate();
        HttpHeaders headers = new HttpHeaders();
        headers.set("Authorization", "Bearer " + accessToken);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        try {
            ResponseEntity<String> response = restTemplate.exchange(
                    kakaoUserInfoUrl, HttpMethod.GET, entity, String.class);
            return response.getBody();
        } catch (HttpClientErrorException ex) {
            if (ex.getStatusCode() == HttpStatus.UNAUTHORIZED) {
                throw new UsernameNotFoundException("유효하지 않은 토큰입니다", ex);
            }
            throw ex;
        }
    }



}
