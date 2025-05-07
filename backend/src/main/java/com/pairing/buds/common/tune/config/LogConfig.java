package com.pairing.buds.common.tune.config;

import com.pairing.buds.common.tune.service.LogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.springframework.stereotype.Component;

@Aspect
@Component
@Slf4j
@RequiredArgsConstructor
public class LogConfig { /** Log Aspect **/

//    private final LogService logService;
//    private final ThreadLocal<Long> startTime = new ThreadLocal<>();
//
//    @Pointcut(value = """
//            execution(* com.pairing.buds.*..service..*(..))
//            && !execution(* com.pairing.buds.common.tune.service..*(..))
//            """)
//    public void pointCutForLogging(){}
//
//    @Before("pointCutForLogging()")
//    public void logBefore(JoinPoint joinPoint){
//        startTime.set(System.currentTimeMillis());
//    }
//
//    @AfterReturning("pointCutForLogging()")
//    public void logAfterReturning(JoinPoint joinPoint){
//        Long start = startTime.get();
//        long elapse = System.currentTimeMillis() - start;
//
//        String sourceLocation = joinPoint.getSourceLocation().toString();
//        String completion = "SUCCESS";
//        String statusMessage = "OK";
//        logService.logging(sourceLocation, completion, elapse, statusMessage);
//    }
//
//    @AfterThrowing(value = "pointCutForLogging()", throwing = "throwable")
//    public void logAfter(JoinPoint joinPoint, Throwable throwable
//    ){
//        Long start = startTime.get();
//        long elapse = System.currentTimeMillis() - start;
//
//        String sourceLocation = joinPoint.getSourceLocation().toString();
//        String completion = "SUCCESS";
//        String statusMessage = throwable.getMessage(); // 에러 처리로 수정 요망
//        logService.logging(sourceLocation, completion, elapse, statusMessage);
//    }
//
//
//    @Around("pointCutForLogging()")
//    public Object adviceForHasReturnValue(ProceedingJoinPoint joinPoint ) throws Throwable {
//        long startTime = System.currentTimeMillis();
//        String sourceDescription = joinPoint.toShortString();
//
//        // 사용자 정보 (아이디, 이메일, 성별, 나이, 이름, ip 등) 추출
//
//        Object result;
//        String completion = "SUCCESS";
//        String statusMessage = "OK";
//        try {
//            result = joinPoint.proceed();
//        }catch(Exception e){
//            completion = "FAIL";
//            result = e.getMessage();
//            statusMessage = e.getMessage();
//        }finally{
//            long completionTime = System.currentTimeMillis() - startTime;
//            // 소스 상세, 성공 여부, 응답 시간, 에러 메시지
//            logService.logging(sourceDescription, completion, completionTime, statusMessage);
//        }
//        return result;
//    }
}
