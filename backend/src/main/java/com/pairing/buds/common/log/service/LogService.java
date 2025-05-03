package com.pairing.buds.common.log.service;

import com.pairing.buds.common.log.entity.Log;
import com.pairing.buds.common.log.repository.LogRepository;
import com.pairing.buds.common.response.Message;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class LogService {

    private final LogRepository logRepository;
    
    /** 사용자 패턴, 메소드, 소스 경로, 응답 시간, 성공 여부 로그 **/
    public void logging(String sourceDescription, boolean b, long completionTime, String statusMessage) {
        // 로그 
        Log log = new Log();
        log.setSourceDescription(sourceDescription);
        log.setCompletion(b);
        log.setResponseTime((int)completionTime);
        log.setStatusMessage(statusMessage);
        // 저장
        logRepository.save(log);
    }



}
