package com.pairing.buds;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.pairing.buds.common.auth.service.RedisService;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.servlet.http.Cookie;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.MvcResult;

import java.util.Map;

import static org.junit.jupiter.api.Assertions.assertNotEquals;
import static org.springframework.http.MediaType.APPLICATION_JSON;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.cookie;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/**
 * spring:
 *   mvc:
 *     static-path-pattern: /static/**
 * 설정 해줘야 테스트 성공 뜹니다.
 */

@SpringBootTest
@AutoConfigureMockMvc
class DuplicateLoginCookieTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private RedisService redisService;

    @BeforeEach
    void setUp() {
        redisService.deleteRefreshTokenAll();  // Redis 토큰 전부 삭제
    }

    @Test
    void whenSecondLogin_thenPreviousCookieIsInvalidated() throws Exception {
        Map<String, String> loginReq = Map.of(
                "userEmail", "buds@ssafy.com",
                "password",  "20250522"
        );
        String loginJson = objectMapper.writeValueAsString(loginReq);

        // 첫 로그인
        MvcResult r1 = mockMvc.perform(post("/login")
                        .contentType(APPLICATION_JSON)
                        .content(loginJson))
                .andExpect(status().isOk())
                .andExpect(cookie().exists("access_token"))
                .andExpect(cookie().exists("refresh_token"))
                .andReturn();
        Cookie firstAccess  = r1.getResponse().getCookie("access_token");
        Cookie firstRefresh = r1.getResponse().getCookie("refresh_token");

        Thread.sleep(1200); // 1.1초 대기

        // 두 번째 로그인 (redis에는 두 번째 refresh만 남음)
        MvcResult r2 = mockMvc.perform(post("/login")
                        .contentType(APPLICATION_JSON)
                        .content(loginJson))
                .andExpect(status().isOk())
                .andReturn();
        Cookie secondAccess  = r2.getResponse().getCookie("access_token");
        Cookie secondRefresh = r2.getResponse().getCookie("refresh_token");

        // 1) 첫 Access는 아직 valid
        mockMvc.perform(get("/users/all-tags")
                        .cookie(firstAccess))
                .andExpect(status().isOk());

        // 2) 두 번째 Access도 valid
        mockMvc.perform(get("/users/all-tags")
                        .cookie(secondAccess))
                .andExpect(status().isOk());

        // 3) 오래된 Refresh로는 재발급 불가
        mockMvc.perform(post("/refresh")
                        .cookie(firstRefresh))
                .andExpect(status().isUnauthorized());

        // 4) 최신 Refresh로는 재발급 성공 (새 Access 토큰 발급)
        MvcResult refreshResult = mockMvc.perform(post("/refresh")
                        .cookie(secondRefresh))
                .andExpect(status().isOk())
                .andExpect(cookie().exists("access_token"))
                .andReturn();

        Cookie refreshedAccess = refreshResult.getResponse().getCookie("access_token");
        assertNotEquals(secondAccess.getValue(), refreshedAccess.getValue(),
                "새로 발급된 Access 토큰이 달라야 합니다.");
    }
}
