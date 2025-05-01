package com.pairing.buds.domain.user.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.dto.request.UpdateUserTagsReqDto;
import com.pairing.buds.domain.user.service.UserService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/users")
public class UserController {

    private final UserService userService;

    /** 사용자 태그 조회 **/
    @GetMapping("/tags")
    public ResponseDto getTags(@AuthenticationPrincipal Integer userId) {
        return new ResponseDto(StatusCode.OK, userService.getUserTags(userId));
    }

    /** 태그 업데이트(신규 저장 포함) **/
    @PostMapping("/tags")
    public ResponseDto updateUserTags(
            @AuthenticationPrincipal Integer userId,
            @Valid @RequestBody UpdateUserTagsReqDto dto) {
        userService.updateUserTags(userId, dto.getTags());
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

}
