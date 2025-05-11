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
import com.pairing.buds.domain.letter.dto.request.SendLetterReqDto;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/letters")
public class LetterController {

    private final LetterService letterService;

    /** 편지 조회 **/
    @GetMapping("/detail/{letterId}")
    public ResponseDto getLetterDetail(
            @AuthenticationPrincipal int userId,
            @PathVariable("letterId") int letterId
//            @Valid @RequestBody GetLetterDetailReqDto dto
    ) {
        return new ResponseDto(StatusCode.OK, letterService.getLetterDetail(userId, letterId));
    }

    /** 편지 채팅 리스트 조회 **/
    @GetMapping("/chats")
    public ResponseDto getLetterChatList(@AuthenticationPrincipal Integer userId) {
        return new ResponseDto(StatusCode.OK, letterService.getLetterChatList(userId));
    }

    /** 특정 사용자와의 편지 상세 목록 조회 **/
    @GetMapping("/chats/details")
    public ResponseDto getLetterDetailList(
            @AuthenticationPrincipal Integer userId,
            @RequestParam("opponentId") Integer opponentId,
            @RequestParam(name = "page", defaultValue = "0") int page,
            @RequestParam(name = "size", defaultValue = "5") int size) {
        return new ResponseDto(StatusCode.OK, letterService.getLetterDetailList(userId, opponentId, page, size));
    }

    /** 최근 수신 편지 1건 조회 **/
    @GetMapping("/latest-received")
    public ResponseDto getLatestReceivedLetter(@AuthenticationPrincipal Integer userId) {
        return new ResponseDto(StatusCode.OK, letterService.getLatestReceivedLetter(userId));
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

    /**
     * 편지 랜덤 발송
     * '관심' 버튼 클릭 후 발송시 관심 태그가 sender와 1개 이상 동일한 사람에게 랜덤 발송
     * '관심' 버튼 클릭하지 않고 보낼 경우, 무작위 랜덤으로 발송
     **/
    @PostMapping("/send")
    public ResponseDto sendLetter(@AuthenticationPrincipal Integer userId,
                                  @RequestBody SendLetterReqDto dto) {
        letterService.sendLetter(userId, dto);
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
