package com.pairing.buds.domain.cs.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.cs.dto.question.request.CreateQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.request.DeleteQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.request.PatchQuestionReqDto;
import com.pairing.buds.domain.cs.service.QuestionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/cs")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    /** 해당 유저의 문의 조회 **/
    @GetMapping("")
    public ResponseDto getQuestionsOfUser(
            @AuthenticationPrincipal int userId
//            @RequestParam("questionId") int questionId
    ){
        return new ResponseDto(StatusCode.OK, questionService.getQuestionsOfUser(userId));
    }

    /** 문의 생성 **/
    @PostMapping("")
    @PreAuthorize("hasRole('USER')")
    public ResponseDto createQuestion(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody CreateQuestionReqDto dto
    ){
        questionService.createQuestion(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.CREATED);
    }

    /** 문의 수정 **/
    @PatchMapping("")
    @PreAuthorize("hasRole('USER')")
    public ResponseDto patchQuestion(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody PatchQuestionReqDto dto
    ){
        questionService.patchQuestion(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 문의 삭제 **/
    @DeleteMapping("")
    @PreAuthorize("hasRole('USER')")
    public ResponseDto deleteQuestion(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody DeleteQuestionReqDto dto
    ){
        questionService.deleteQuestion(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
}
