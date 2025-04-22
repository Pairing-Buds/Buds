package com.pairing.buds.domain.activity.controller;

import com.pairing.buds.domain.activity.dto.request.CreateWakeTimeReqDto;
import com.pairing.buds.domain.activity.service.ActivityService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/activity")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;

    /** 기상 시간 등록 **/
    @PostMapping("/wake")
    public ResponseEntity<?> createWakeTime(@Valid @RequestBody CreateWakeTimeReqDto dto){
        return activityService.createWakeTime(dto);
    }

    /** 기상 시간 인증 **/


    /** 기상 시간 수정 **/
//    @PatchMapping("/wake")
//    public ResponseEntity<?> updateWakeTime(@Valid @RequestBody UpdateWakeTimeReqDto dto){
//        return activityService.updateWakeTime(dto);
//    }

    /** 기상 시간 삭제 **/

    /** 취침 시간 등록 **/

    /** 취침 시간 인증 **/

    /** 취침 시간 수정 **/

    /** 취침 시간 삭제 **/
}
