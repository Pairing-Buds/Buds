package com.pairing.buds.common.auth.controller;

import com.pairing.buds.common.auth.dto.request.PasswordResetReqDto;
import com.pairing.buds.common.auth.dto.request.UserCompleteReqDto;
import com.pairing.buds.common.auth.dto.request.UserSignupReqDto;
import com.pairing.buds.common.auth.service.AuthService;
import com.pairing.buds.common.auth.utils.NicknameGenerator;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.service.EmailService;
import com.pairing.buds.domain.user.service.VerificationService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/auth")
public class AuthController {

    private final AuthService authService;
    private final EmailService emailService;
    private final VerificationService verificationService;
    private final NicknameGenerator ng;

    /** 회원가입 이메일 인증 메일 요청 **/
    @PostMapping("/email/request")
    public ResponseDto requestEmailToken(
            @RequestParam("user-email") @Email String userEmail) {
        emailService.sendVerificationEmail(userEmail);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 토큰 입력 후 인증 클릭 시 검증 **/
    @GetMapping("/verify-email")
    public ResponseDto verifyEmailToken(@RequestParam("token") String token) {
        verificationService.validateToken(token);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 회원 가입 **/
    @PostMapping("/sign-up")
    public ResponseDto userSignup(
            @Valid @RequestBody UserSignupReqDto dto) {
        authService.userSignup(dto);
        return new ResponseDto(StatusCode.CREATED, Message.OK);
    }

    /** 중복 없는 닉네임 랜덤 제공 **/
    @GetMapping("/random-nickname")
    public ResponseDto randomNickname() {
        return new ResponseDto(StatusCode.OK, ng.generateName());
    }

    /** 닉네임/캐릭터 저장 **/
    @PatchMapping("/sign-up/complete")
    public ResponseDto completeSignup(
            @AuthenticationPrincipal Integer userId,
            @Valid @RequestBody UserCompleteReqDto dto) {
        authService.completeSignup(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 비밀번호 재설정 이메일 인증 메일 요청 */
    @PostMapping("/email/request/password-reset")
    public ResponseDto requestPasswordResetEmailToken(
            @RequestParam("user-email") @Email String userEmail) {
        emailService.sendPasswordResetEmail(userEmail);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /**
     * 비밀번호 재설정
     * 기존 이메일 인증 요청 메서드를 통해 인증코드 이메일 전송, verification 거침
     **/
    @PostMapping("/reset-password")
    public ResponseDto resetPassword(@RequestBody PasswordResetReqDto dto) {
        authService.resetPassword(dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

}
