package com.pairing.buds.common.auth.service;

import com.pairing.buds.common.auth.dto.request.PasswordResetReqDto;
import com.pairing.buds.common.auth.dto.request.UserCompleteReqDto;
import com.pairing.buds.common.auth.dto.request.UserSignupReqDto;
import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.entity.SignupStatus;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.entity.UserCharacter;
import com.pairing.buds.domain.user.repository.UserRepository;
import com.pairing.buds.domain.user.service.VerificationService;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final VerificationService verificationService;


    /** 회원 가입 **/
    @Transactional
    public void userSignup(@Valid UserSignupReqDto dto) {

        if (userRepository.existsByUserEmail(dto.getUserEmail()))  {
            throw new ApiException(
                    StatusCode.CONFLICT, Message.DUPLICATE_EMAIL_EXCEPTION
            );
        }

        String encodedPwd = passwordEncoder.encode(dto.getPassword());

        User user = UserSignupReqDto.toUser(dto, encodedPwd);

        userRepository.save(user);
    }

    /** 닉네임/캐릭터 저장 **/
    @Transactional
    public void completeSignup(Integer userId, @Valid UserCompleteReqDto dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(
                        StatusCode.NOT_FOUND, Message.USER_NOT_FOUND)
                );

        if (user.getIsCompleted() == SignupStatus.DONE) {
            throw new ApiException(
                    StatusCode.BAD_REQUEST, Message.ALREADY_COMPLETED
            );
        }

        user.setUserName(dto.getUserName());
        user.setUserCharacter(UserCharacter.valueOf(dto.getUserCharacter()));
        user.setIsCompleted(SignupStatus.DONE);

        userRepository.save(user);
    }

    @Transactional
    public void resetPassword(PasswordResetReqDto dto) {
        String token = dto.getToken();
        String newPassword = dto.getNewPassword();

        // 토큰 검증 및 이메일 추출
        String email = verificationService.getEmailAndInvalidate(token);

        User user = userRepository.findByUserEmail(email)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        // 비밀번호 변경
        user.setPassword(passwordEncoder.encode(newPassword));

        userRepository.save(user);
    }

}
