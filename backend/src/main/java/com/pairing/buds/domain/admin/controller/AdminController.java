package com.pairing.buds.domain.admin.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.admin.dto.req.ActiveUserReqDto;
import com.pairing.buds.domain.admin.dto.req.InActiveUserReqDto;
import com.pairing.buds.domain.admin.service.AdminService;
import com.pairing.buds.domain.cs.dto.answer.req.CreateAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.DeleteAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.PatchAnswerReqDto;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminService adminService;

    /** 문의 목록 조회 **/
    @GetMapping("/cs/answered-questions")
    public ResponseDto getAnsweredQuestionList(
            @AuthenticationPrincipal int adminId
    ){
        return new ResponseDto(StatusCode.OK, adminService.getAnsweredQuestionList(adminId));
    }
    /** 미답변 문의 목록 조회 **/
    @GetMapping("/cs/unanswered-questions")
    public ResponseDto getUnAnsweredQuestionList(
            @AuthenticationPrincipal int adminId
    ){
        return new ResponseDto(StatusCode.OK, adminService.getUnAnsweredQuestionList(adminId));
    }
    /** 특정 유저의 문의 조회 **/
    @GetMapping("/cs/users/{userId}")
    public ResponseDto getQuestionOfUser(
            @AuthenticationPrincipal int adminId,
            @PathVariable("userId") int userId
    ){
        return new ResponseDto(StatusCode.OK, adminService.getQuestionOfUser(adminId, userId));
    }

    /** 답변 작성 **/
    @PostMapping("/cs")
    public ResponseDto createAnswer(
            @AuthenticationPrincipal int adminId,
            @Valid @RequestBody CreateAnswerReqDto dto
    ){
        adminService.createAnswer(adminId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 답변 수정 **/
    @PatchMapping("/cs")
    public ResponseDto patchAnswer(
            @AuthenticationPrincipal int adminId,
            @Valid @RequestBody PatchAnswerReqDto dto
    ){
        adminService.patchAnswer(adminId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
    /** 회원 활성화 **/
    @PatchMapping("/is-active")
    public ResponseDto activeUser(
            @AuthenticationPrincipal int adminId,
            @Valid @RequestBody ActiveUserReqDto dto
    ){
        adminService.activeUser(adminId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
    /** 회원 비활성화 **/
    @PatchMapping("/not-active")
    public ResponseDto inactiveUser(
            @AuthenticationPrincipal int adminId,
            @Valid @RequestBody InActiveUserReqDto dto
    ){
        adminService.inactiveUser(adminId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 답변 삭제 **/
    @DeleteMapping("/cs")
    public ResponseDto deleteAnswer(
            @AuthenticationPrincipal int adminId,
            @Valid @RequestBody DeleteAnswerReqDto dto
    ){
        adminService.deleteAnswer(adminId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
}
