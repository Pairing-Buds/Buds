package com.pairing.buds.domain.user.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.dto.request.*;
import com.pairing.buds.domain.user.service.UserService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/users")
@PreAuthorize("hasRole('USER')")
public class UserController {

    private final UserService userService;

    /** 사용자 태그 조회 **/
    @GetMapping("/tags")
    public ResponseDto getTags(@AuthenticationPrincipal Integer userId) {
        return new ResponseDto(StatusCode.OK, userService.getUserTags(userId));
    }

    /** 전체 태그 조회 **/
    @GetMapping("/all-tags")
    public ResponseDto getAllTags(@AuthenticationPrincipal int userId) {
        return new ResponseDto(StatusCode.OK, userService.getAllTags(userId));
    }



    /** 태그 업데이트(신규 저장 포함) **/
    @PostMapping("/tags")
    public ResponseDto updateUserTags(
            @AuthenticationPrincipal Integer userId,
            @Valid @RequestBody UpdateUserTagsReqDto dto) {
        userService.updateUserTags(userId, dto.getTagTypes());
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 첫 설문조사 결과 저장 **/
    @PostMapping("/survey-result")
    public ResponseDto saveSurveyResult(
            @AuthenticationPrincipal Integer userId,
            @Valid @RequestBody SaveSurveyResultReqDto dto) {
        userService.saveSurveyResult(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
    /** 재설문 결과 저장 **/
    @PostMapping("/re-survey-result")
    public ResponseDto saveReSurveyResult(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody SaveReSurveyResultReqDto dto) {
        userService.saveReSurveyResult(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }


    /** 내 정보 조회 **/
    @GetMapping("/my-info")
    public ResponseDto getMyInfo(@AuthenticationPrincipal Integer userId) {
        return new ResponseDto(StatusCode.OK, userService.getMyInfo(userId));
    }

    /** 회원 수정 **/
    @PatchMapping("/my-info")
    public ResponseDto updateUserInfo(
            @AuthenticationPrincipal Integer userId,
            @Valid @RequestBody UpdateUserInfoReqDto dto) {
        userService.updateUserInfo(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 회원 탈퇴(소프트 삭제) **/
    @DeleteMapping("/withdrawal")
    public ResponseDto withdraw(
            @AuthenticationPrincipal Integer userId,
            @RequestBody WithdrawUserReqDto dto,
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication) {
        userService.withdrawUser(userId, dto, request, response, authentication);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

}
