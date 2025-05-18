package com.pairing.buds.common.auth.config;
import com.pairing.buds.common.auth.filter.CustomLoginFilter;
import com.pairing.buds.common.auth.service.CustomUserDetailsService;
import com.pairing.buds.common.auth.filter.JwtAuthenticationFilter;
import java.util.Arrays;
import java.util.List;

import com.pairing.buds.common.auth.service.RedisService;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.security.web.authentication.logout.*;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

/**
 * Spring Security의 보안 설정을 담당하는 클래스
 * 필터, CORS 설정, 세션 관리 등 다양한 보안 설정이 포함
 */
@Configuration
public class SecurityConfig {

    private final AuthenticationConfiguration authenticationConfiguration;
    private final CustomUserDetailsService userDetailsService;
    private final JwtTokenProvider jwtTokenProvider;
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final RedisService redisService;

    public SecurityConfig(AuthenticationConfiguration authenticationConfiguration,
                          CustomUserDetailsService userDetailsService,
                          JwtTokenProvider jwtTokenProvider,
                          JwtAuthenticationFilter jwtAuthenticationFilter, RedisService redisService) {
        this.authenticationConfiguration = authenticationConfiguration;
        this.userDetailsService          = userDetailsService;
        this.jwtTokenProvider          = jwtTokenProvider;
        this.jwtAuthenticationFilter   = jwtAuthenticationFilter;
        this.redisService = redisService;
    }


    // AuthenticationManager 빈 등록
    @Bean
    public AuthenticationManager authenticationManager() throws Exception {
        return authenticationConfiguration.getAuthenticationManager();
    }

    // PasswordEncoder 빈
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    // DaoAuthenticationProvider 빈 (UserDetailsService + PasswordEncoder 연결)
    @Bean
    public DaoAuthenticationProvider daoAuthenticationProvider() {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());
        return provider;
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 기본 보안 기능 비활성화
                .csrf(AbstractHttpConfigurer::disable) // CSRF 비활성화
                .httpBasic(AbstractHttpConfigurer::disable)  // HTTP 기본 인증 비활성화
                .formLogin(AbstractHttpConfigurer::disable)  // formLogin 비활성화
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))

                // 세션 없이 JWT만으로 인증
                .sessionManagement(sm -> sm
                        .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )

                // URL 권한 설정
                .authorizeHttpRequests(authz -> authz
                        .requestMatchers("/admin/**").hasAuthority("ADMIN")
                        .requestMatchers( "/**").permitAll()
                        .anyRequest().authenticated()
                )

                // AuthenticationProvider 등록
                .authenticationProvider(daoAuthenticationProvider()
                );

//                .authorizeHttpRequests(authz -> authz
//                // 로그인, 리프레시, 회원가입만 공개
//                .requestMatchers("/login", "/refresh", "/auth/sign-up").permitAll()
//                .requestMatchers("/admin/**").hasRole("ADMIN")
//                // 그 외에는 모두 인증된 사용자만
//                .anyRequest().authenticated())
//
//                // AuthenticationProvider 등록
//                .authenticationProvider(daoAuthenticationProvider()
//                );

        // CustomLoginFilter를 직접 생성해서 삽입
        CustomLoginFilter customLoginFilter =
                new CustomLoginFilter(
                        authenticationManager(),
                        jwtTokenProvider,
                        redisService
                );

        http
                // 로그인 처리 필터
                .addFilterAt(
                        customLoginFilter,
                        UsernamePasswordAuthenticationFilter.class
                )
                // JWT 인증 필터
                .addFilterBefore(
                        jwtAuthenticationFilter,
                        CustomLoginFilter.class
                )
                // 로그아웃
                .logout(logout -> logout
                        // 로그아웃 성공 시 200 응답
                        .logoutSuccessHandler(new HttpStatusReturningLogoutSuccessHandler())
                        // SecurityContext 비우기 + 세션 무효화
                        .clearAuthentication(true)
                        .invalidateHttpSession(true)
                        // 쿠키 삭제
                        .deleteCookies("access_token", "refresh_token")
                        // Redis에 저장된 refresh_token 삭제
                        .addLogoutHandler((req, res, auth) -> {
                            String rt = jwtTokenProvider.extractCookie(req, "refresh_token");
                            if (rt != null && jwtTokenProvider.validateToken(rt)) {
                                Integer userId = jwtTokenProvider.getUserId(rt);
                                redisService.deleteRefreshToken(userId);
                            }
                        })
                );

        return http.build();
    }

    // CORS 설정
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowCredentials(true);
        configuration.setAllowedOriginPatterns(List.of("*"));  // 모든 출처 허용
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuration.setAllowedHeaders(Arrays.asList("Authorization", "Content-Type"));
        configuration.setExposedHeaders(Arrays.asList("Authorization", "Set-Cookie"));

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }

}