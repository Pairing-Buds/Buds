package com.pairing.buds.common.auth.service;

import com.pairing.buds.common.auth.dto.request.PasswordResetReqDto;
import com.pairing.buds.common.auth.dto.request.UserCompleteReqDto;
import com.pairing.buds.common.auth.dto.request.UserSignupReqDto;
import com.pairing.buds.common.auth.dto.response.RandomNameResDto;
import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.entity.*;
import com.pairing.buds.domain.user.repository.UserRepository;
import com.pairing.buds.domain.user.repository.RandomNameRepository;
import com.pairing.buds.domain.user.service.VerificationService;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final VerificationService verificationService;
    private final RandomNameRepository randomNameRepository;

    /** 회원 가입 **/
    @Transactional
    public void userSignup(@Valid UserSignupReqDto dto) {
        // 활성화 상태인 계정만 이메일 중복 체크
        if (userRepository.existsByUserEmailAndIsActiveTrue(dto.getUserEmail()))  {
            throw new ApiException(
                    StatusCode.CONFLICT,
                    Message.DUPLICATE_EMAIL_EXCEPTION
            );
        }

        // 신규가입
        String encodedPwd = passwordEncoder.encode(dto.getPassword());
        User user = UserSignupReqDto.toUser(dto, encodedPwd);
        userRepository.save(user);
    }

    /** 닉네임/캐릭터 저장 **/
    @Transactional
    public void completeSignup(Integer userId, @Valid UserCompleteReqDto dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(
                        StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        if (user.getIsCompleted() == SignupStatus.DONE) {
            throw new ApiException(
                    StatusCode.BAD_REQUEST, Message.ALREADY_COMPLETED);
        }

        String desc = dto.getUserCharacter();
        if (desc == null || desc.isBlank()) {
            throw new ApiException(
                    StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }
        UserCharacter character;
        try {
            character = UserCharacter.fromDescription(desc);
        } catch (IllegalArgumentException e) {
            throw new ApiException(
                    StatusCode.BAD_REQUEST, Message.INVALID_USER_CHARACTER);
        }

        // 사용된 닉네임 USED 처리
        String chosenName = dto.getUserName();
        RandomName rn = randomNameRepository.findByRandomName(chosenName)
                .orElseThrow(() -> new ApiException(
                        StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER));
        if (rn.getStatus() == RandomNameStatus.USED) {
            throw new ApiException(
                    StatusCode.BAD_REQUEST, Message.RANDOM_NAME_ALREADY_EXIST);
        }

        rn.setStatus(RandomNameStatus.USED);
        rn.setAssignedAt(LocalDateTime.now());
        rn.setUser(user);

        user.setUserName(dto.getUserName());
        user.setUserCharacter(character);
        user.setIsCompleted(SignupStatus.DONE);

        userRepository.save(user);
        randomNameRepository.save(rn);
    }

    /** 회원 비밀번호 수정 **/
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

    /** 랜덤 닉네임 출력 **/
    @Transactional
    public RandomNameResDto getAvailableRandomName() {
        String randomName = randomNameRepository.findRandomNameByStatus(RandomNameStatus.AVAILABLE)
            .map(RandomName::getRandomName)
            .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.RANDOM_NAME_ALREADY_EXIST));

        return new RandomNameResDto(randomName);
    }

    /** 계정 복구 **/

}
