package com.pairing.buds.domain.diary.controller;

import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.diary.dto.request.DiaryReqDto;
import com.pairing.buds.domain.diary.service.DiaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/diary")
@RequiredArgsConstructor
public class DiaryController {
    private final DiaryService diaryService;

    // 일기 저장
    @PostMapping
    public ResponseDto addDiary(
            @AuthenticationPrincipal Integer userId,
            @RequestBody DiaryReqDto diaryReqDto
    ) {
        diaryService.addDiary(userId, diaryReqDto);
        return new ResponseDto(StatusCode.OK, "저장 성공");
    }


}
