package com.pairing.buds.common.log.config;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.log.service.LogService;
import com.pairing.buds.common.response.Message;
import jakarta.persistence.Column;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

@Aspect
@Component
@Slf4j
@RequiredArgsConstructor
public class LogConfig { /** Log Aspect **/

    private final LogService logService;

    @Pointcut(value = "execution(* com.pairing.buds.*..service..*(..)) ")
    public void pointCutForLogging(){}

    @Around("pointCutForLogging()")
    public Object adviceForHasReturnValue(ProceedingJoinPoint joinPoint ){
        long startTime = System.nanoTime();
        String sourceDescription = joinPoint.toShortString();

        // 사용자 정보 (아이디, 이메일, 성별, 나이, 이름, ip 등) 추출

        Object result;
        try{
            result = joinPoint.proceed();
            long completionTime = System.nanoTime() - startTime;
            // 소스 상세, 성공 여부, 응답 시간, 에러 메시지
            logService.logging(sourceDescription, true, completionTime, "");
        } catch (Throwable t) {
            long completionTime = System.nanoTime() - startTime;
            logService.logging(sourceDescription, false, completionTime, t.getMessage());
            throw new RuntimeException();
        }
        return result;
    }
}
