package com.pairing.buds.domain.letter.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.letter.dto.req.AnswerLetterReqDto;
import com.pairing.buds.domain.letter.dto.req.GetLetterDetailReqDto;
import com.pairing.buds.domain.letter.dto.req.ScrapLetterCancelReqDto;
import com.pairing.buds.domain.letter.dto.req.ScrapLetterReqDto;
import com.pairing.buds.domain.letter.service.LetterService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/letters")
@RequiredArgsConstructor
public class LetterController {

    private final LetterService letterService;


















    /** 편지 조회 **/
    @GetMapping("/detail")
    public ResponseDto getLetterDetail(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody GetLetterDetailReqDto dto
    ) {
        return new ResponseDto(StatusCode.OK, letterService.getLetterDetail(userId, dto));
    }



    /** 편지 스크랩 추가 **/
    @PostMapping("/scrap")
    public ResponseDto scrapLetter(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody ScrapLetterReqDto dto
    ){
        letterService.scrapLetter(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
    /** 편지 답장 전송 **/
    @PostMapping("/answer")
    public ResponseDto answerLetter(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody AnswerLetterReqDto dto
    ){
        letterService.answerLetter(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }




    /** 편지 스크랩 취소 **/
    @DeleteMapping("/scrap-cancel")
    public ResponseDto scrapCancelLetter(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody ScrapLetterCancelReqDto dto
    ){
        letterService.scrapLetterCancel(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
    
    
    
}
