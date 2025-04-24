package com.pairing.buds.domain.activity.service;

import com.pairing.buds.common.response.Common;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.activity.dto.request.CreateWakeTimeReqDto;
import com.pairing.buds.domain.activity.dto.request.DeleteWakeTimeReqDto;
import com.pairing.buds.domain.activity.dto.request.UpdateWakeTimeReqDto;
import com.pairing.buds.domain.activity.entity.Wake;
import com.pairing.buds.domain.activity.repository.ActivityRepository;
import com.pairing.buds.domain.activity.repository.SleepRepository;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ActivityService {

    /**
     * 중요 정보 로깅은 배포 시 제거
     * **/

    private final ActivityRepository activityRepository;
    private final UserRepository userRepository;
    private final SleepRepository sleepRepository;

    /** 기상 시간 등록 **/
    @Transactional
    public void createWakeTime(int userId , @Valid CreateWakeTimeReqDto dto) {

        String wakeTime = dto.getWakeTime();
        log.info("wakeTime : {}, userId : {}", wakeTime, userId);

        // 유저 유무 조회
        User userToSave = userRepository.findById(userId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND)));

        // 저장
        Wake newSleep = Wake.builder()
                .user(userToSave)
                .wakeTime(wakeTime)
                .build();
        sleepRepository.save(newSleep);
    }

    /** 기상 시간 수정 **/
    @Transactional
    public void updateWakeTime(int userId, @Valid UpdateWakeTimeReqDto dto) {

        int wakeId = dto.getWakeId();
        String wakeTime = dto.getWakeTime();
        log.info("sleepId : {}, wakeTime : {}, userId : {}", wakeId, wakeTime, userId);
        
        // user, sleep 유무 검증
        User user = userRepository.findById(userId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND)));
        Wake wakeToUpdate = sleepRepository.findById(wakeId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.SLEEP_NOT_FOUND)));

        int userIdOfWakeToUpdate = wakeToUpdate.getUser().getId();
        log.info("userId : {}, userIdOfWakeToUpdate : {}", userId, userIdOfWakeToUpdate);
        
        // sleep의 유저와 식별자 비교
        if(userId != userIdOfWakeToUpdate){
            log.info("userId, userIdOfSleepToUpdate Not Match");
            throw new RuntimeException(Common.toString(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER));
        }
        
        // 저장
        wakeToUpdate.setWakeTime(wakeTime);
        sleepRepository.save(wakeToUpdate);
    }
    
    /** 기상 시간 삭제 **/
    @Transactional
    public void deleteWakeTime(int userId, @Valid DeleteWakeTimeReqDto dto) {

        int wakeId = dto.getWakeId();
        log.info("wakeId : {}, userId : {}", wakeId, userId);

        // exists...
        User user = userRepository.findById(userId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND)));
        Wake wakeToDelete = sleepRepository.findById(wakeId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.SLEEP_NOT_FOUND)));

        int userIdOfWakeToDelete = wakeToDelete.getUser().getId();
        log.info("userId : {}, userIdOfWakeToDelete : {}", userId, userIdOfWakeToDelete);

        if(userId != userIdOfWakeToDelete){
            log.info("userId, userIdOfSleepToDelete Not Match");
            throw new RuntimeException(Common.toString(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER));
        }

        // DB에 데이터 부재 시 OptimisticLockingFailureException 발생
        sleepRepository.delete(wakeToDelete);
    }
}
