package com.pairing.buds.domain.cs.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.cs.dto.req.CreateQuestionReqDto;
import com.pairing.buds.domain.cs.service.QuestionService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/question")
@RequiredArgsConstructor
public class QuestionController {

    private final QuestionService questionService;

    /** 문의 조회 **/
    @GetMapping("")
    public ResponseDto getQuestion(
            @AuthenticationPrincipal int userId,
            @RequestParam("questionId") int questionId
    ){
        return new ResponseDto(StatusCode.OK, questionService.getQuestion(questionId, userId));
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
}
