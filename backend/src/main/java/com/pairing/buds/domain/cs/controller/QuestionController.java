package com.pairing.buds.domain.cs.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.cs.dto.question.req.CreateQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.req.DeleteQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.req.PatchQuestionReqDto;
import com.pairing.buds.domain.cs.service.QuestionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/cs")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    /** 문의 조회 **/
    @GetMapping("")
    public ResponseDto getQuestion(
            @AuthenticationPrincipal int userId
//            @RequestParam("questionId") int questionId
    ){
        return new ResponseDto(StatusCode.OK, questionService.getQuestion(userId));
    }

    /** 문의 생성 **/
    @PostMapping("")
    public ResponseDto createQuestion(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody CreateQuestionReqDto dto
    ){
        questionService.createQuestion(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.CREATED);
    }

    /** 문의 수정 **/
    @PatchMapping("")
    public ResponseDto patchQuestion(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody PatchQuestionReqDto dto
    ){
        questionService.patchQuestion(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 문의 삭제 **/
    @DeleteMapping("")
    public ResponseDto deleteQuestion(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody DeleteQuestionReqDto dto
    ){
        questionService.deleteQuestion(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
}
