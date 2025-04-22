package com.pairing.buds.domain.activity.service;

import com.pairing.buds.common.response.Common;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.activity.dto.request.CreateWakeTimeReqDto;
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
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class ActivityService {

    private final ActivityRepository activityRepository;
    private final UserRepository userRepository;
    private final SleepRepository sleepRepository;


    /** 기상 시간 등록 **/
    @Transactional
    public ResponseEntity<?> createWakeTime(@Valid CreateWakeTimeReqDto dto) {

        int userId = dto.getUserId();
        String wakeTime = dto.getWakeTime();

        // 유저 유무 조회
        User userToSave = userRepository.findById(userId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND)));
        // 저장
        Sleep newSleep = Sleep.builder()
                .user(userToSave)
                .wakeTime(wakeTime)
                .build();
        sleepRepository.save(newSleep);

        // 응답
        return ResponseEntity.ok().body(new ResponseDto(StatusCode.CREATED, Message.OK));
    }


}
