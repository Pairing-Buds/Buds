package com.pairing.buds.domain.cs.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.cs.dto.answer.req.CreateAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.DeleteAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.PatchAnswerReqDto;
import com.pairing.buds.domain.cs.service.AnswerService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/answer")
@RequiredArgsConstructor
public class AnswerController {

    private final AnswerService answerService;
    
    /** 답변 작성 **/
    @PostMapping("")
    public ResponseDto createAnswer(
            @AuthenticationPrincipal int adminId,
            @Valid @RequestBody CreateAnswerReqDto dto
            ){
        answerService.createAnswer(adminId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 답변 수정 **/
    @PatchMapping("")
    public ResponseDto patchAnswer(
            @AuthenticationPrincipal int adminId,
            @Valid @RequestBody PatchAnswerReqDto dto
    ){
        answerService.patchAnswer(adminId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 답변 삭제 **/
    @DeleteMapping("")
    public ResponseDto deleteAnswer(
            @AuthenticationPrincipal int adminId,
            @Valid @RequestBody DeleteAnswerReqDto dto
    ){
        answerService.deleteAnswer(adminId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

}
