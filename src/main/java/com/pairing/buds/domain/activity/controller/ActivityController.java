package com.pairing.buds.domain.activity.controller;

import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.domain.activity.dto.request.CreateWakeTimeReqDto;
import com.pairing.buds.domain.activity.dto.request.DeleteWakeTimeReqDto;
import com.pairing.buds.domain.activity.dto.request.UpdateWakeTimeReqDto;
import com.pairing.buds.domain.activity.service.ActivityService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/activity")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;

    /** 기상 시간 등록 **/
    @PostMapping("/wake")
    public ResponseDto createWakeTime(@AuthenticationPrincipal int userId,
            @Valid @RequestBody CreateWakeTimeReqDto dto){
        return activityService.createWakeTime(userId, dto);
    }

    /** 기상 시간 인증 **/


    /** 기상 시간 수정 **/
    @PatchMapping("/wake")
    public ResponseDto updateWakeTime(@AuthenticationPrincipal int userId,
            @Valid @RequestBody UpdateWakeTimeReqDto dto){
        return activityService.updateWakeTime(userId, dto);
    }

    /** 기상 시간 삭제 **/
    @DeleteMapping("/wake")
    public ResponseDto deleteWakeTime(@AuthenticationPrincipal int userId,
            @Valid @RequestBody DeleteWakeTimeReqDto dto){
        return activityService.deleteWakeTime(userId, dto);
    }

}
