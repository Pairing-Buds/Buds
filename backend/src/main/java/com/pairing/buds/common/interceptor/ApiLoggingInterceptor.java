package com.pairing.buds.common.interceptor;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.UUID;

@Component
public class ApiLoggingInterceptor implements HandlerInterceptor {
    private static final Logger logger = LoggerFactory.getLogger(ApiLoggingInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // 요청 ID 생성 및 MDC에 추가
        String requestId = UUID.randomUUID().toString();
        MDC.put("requestId", requestId);

        // 클라이언트 정보 추가
        MDC.put("clientIp", request.getRemoteAddr());
        MDC.put("method", request.getMethod());
        MDC.put("uri", request.getRequestURI());

        // 요청 시작 로그
        logger.info("API 요청 시작: {} {}", request.getMethod(), request.getRequestURI());

        // 요청 시작 시간 기록
        request.setAttribute("startTime", System.currentTimeMillis());

        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) {
        // 별도 처리 없음
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        // 처리 시간 계산
        Long startTime = (Long) request.getAttribute("startTime");
        if (startTime != null) {
            long duration = System.currentTimeMillis() - startTime;

            // 응답 정보 추가
            MDC.put("status", String.valueOf(response.getStatus()));
            MDC.put("duration", String.valueOf(duration));

            // 요청 완료 로그
            logger.info("API 요청 완료: {} {} 상태: {} 처리시간: {}ms",
                    request.getMethod(), request.getRequestURI(),
                    response.getStatus(), duration);
        }

        // MDC 정리
        MDC.clear();
    }
}