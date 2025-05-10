package com.pairing.buds.domain.user.service;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class UserLetterCntScheduler {

    private final UserService userService;

    /** 매일 밤 12시 letterCnt +5 처리
     *  - letterCnt가 5 이상인 경우 해당 X
     *  - isActive가 true인 경우와 편지수가 5보다 적은 경우만 해당
     **/
    @Scheduled(cron = "0 0 0 * * *")
    public void replenishLetterCnt() {
        userService.replenishLetterCntIfNecessary();
    }

}
