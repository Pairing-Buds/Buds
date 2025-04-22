package com.pairing.buds.domain.activity.service;

import com.pairing.buds.common.response.Common;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.activity.dto.request.CreateWakeTimeReqDto;
import com.pairing.buds.domain.activity.dto.request.DeleteWakeTimeReqDto;
import com.pairing.buds.domain.activity.dto.request.UpdateWakeTimeReqDto;
import com.pairing.buds.domain.activity.entity.Sleep;
import com.pairing.buds.domain.activity.repository.ActivityRepository;
import com.pairing.buds.domain.activity.repository.SleepRepository;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
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
    public ResponseEntity<?> createWakeTime(@Valid CreateWakeTimeReqDto dto) {

        String username = (String) SecurityContextHolder.getContext().getAuthentication().getDetails();
        String wakeTime = dto.getWakeTime();
        log.info("wakeTime : {}, username : {}", wakeTime, username);

        // 유저 유무 조회
        User userToSave = userRepository.findByUserName(username);
        if(userToSave == null) new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));

        // 저장
        Sleep newSleep = Sleep.builder()
                .user(userToSave)
                .wakeTime(wakeTime)
                .build();
        sleepRepository.save(newSleep);

        return ResponseEntity.ok().body(new ResponseDto(StatusCode.CREATED, Message.OK));
    }

    /** 기상 시간 수정 **/
    @Transactional
    public ResponseEntity<?> updateWakeTime(@Valid UpdateWakeTimeReqDto dto) {

        String username = (String) SecurityContextHolder.getContext().getAuthentication().getDetails();
        int sleepId = dto.getSleepId();
        String wakeTime = dto.getWakeTime();
        log.info("sleepId : {}, wakeTime : {}, username : {}", sleepId, wakeTime, username);
        
        // user, sleep 유무 검증
        User user = userRepository.findByUserName(username);
        Sleep sleepToUpdate = sleepRepository.findById(sleepId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.SLEEP_NOT_FOUND)));

        int userId = user.getId();
        int userIdOfSleepToUpdate = sleepToUpdate.getUser().getId();
        log.info("userId : {}, userIdOfSleepToUpdate : {}", userId, userIdOfSleepToUpdate);
        
        // sleep의 유저와 식별자 비교
        if(userId != userIdOfSleepToUpdate){
            log.info("userId, userIdOfSleepToUpdate Not Match");
            throw new RuntimeException(Common.toString(StatusCode.BAD_REQUEST, Message.AUGUMENT_NOT_PROPER));
        }
        
        // 저장
        sleepToUpdate.setWakeTime(wakeTime);
        sleepRepository.save(sleepToUpdate);
        
        return ResponseEntity.ok().body(new ResponseDto(StatusCode.OK, Message.OK));
    }
    
    /** 기상 시간 삭제 **/
    public ResponseEntity<?> deleteWakeTime(@Valid DeleteWakeTimeReqDto dto) {

        String username = (String) SecurityContextHolder.getContext().getAuthentication().getDetails();
        int sleepId = dto.getSleepId();
        log.info("sleepId : {}, username : {}", sleepId, username);

        User user = userRepository.findByUserName(username);
        Sleep sleepToDelete = sleepRepository.findById(sleepId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.SLEEP_NOT_FOUND)));

        int userId = user.getId();
        int userIdOfSleepToDelete = sleepToDelete.getUser().getId();
        log.info("userId : {}, userIdOfSleepToDelete : {}", userId, userIdOfSleepToDelete);

        if(userId != userIdOfSleepToDelete){
            log.info("userId, userIdOfSleepToDelete Not Match");
            throw new RuntimeException(Common.toString(StatusCode.BAD_REQUEST, Message.AUGUMENT_NOT_PROPER));
        }

        // DB에 데이터 부재 시 OptimisticLockingFailureException 발생
        sleepRepository.delete(sleepToDelete);

        return ResponseEntity.ok().body(new ResponseDto(StatusCode.OK, Message.OK));
    }
}
