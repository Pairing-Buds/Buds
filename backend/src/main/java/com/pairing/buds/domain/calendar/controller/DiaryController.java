package com.pairing.buds.domain.calendar.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.calendar.dto.request.DiaryReqDto;
import com.pairing.buds.domain.calendar.service.DiaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/diaries")
@RequiredArgsConstructor
@PreAuthorize("hasRole('USER')")
public class DiaryController {
    private final DiaryService diaryService;

    /** 일기 저장 **/
    @PostMapping
    public ResponseDto addDiary(
            @AuthenticationPrincipal Integer userId,
            @RequestBody DiaryReqDto diaryReqDto
    ) {
        diaryService.addDiary(userId, diaryReqDto);
        return new ResponseDto(StatusCode.OK, Message.CREATED);
    }

    /** 일기 수정 **/
    @PatchMapping("/{diaryNo}")
    public ResponseDto updateDiary(
            @AuthenticationPrincipal Integer userId,
            @PathVariable Integer diaryNo,
            @RequestBody DiaryReqDto diaryReqDto
    ){
        diaryService.updateDiary(userId, diaryNo, diaryReqDto);
        return new ResponseDto(StatusCode.OK, Message.CREATED);
    }

    /** 일기 삭제 **/
    @DeleteMapping("/{diaryNo}")
    public ResponseDto deleteDiary(
            @AuthenticationPrincipal Integer userId,
            @PathVariable Integer diaryNo
    ){
        diaryService.deleteDiary(userId, diaryNo);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }


}
