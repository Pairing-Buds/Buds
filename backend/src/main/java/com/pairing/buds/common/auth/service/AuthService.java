package com.pairing.buds.common.auth.service;

import com.pairing.buds.common.auth.dto.request.UserCompleteReqDto;
import com.pairing.buds.common.auth.dto.request.UserSignupReqDto;
import com.pairing.buds.common.auth.dto.response.UsernameCheckResDto;
import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.entity.SignupStatus;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.entity.UserCharacter;
import com.pairing.buds.domain.user.entity.UserRole;
import com.pairing.buds.domain.user.repository.UserRepository;
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

    @Transactional
    public void userSignup(@Valid UserSignupReqDto dto) {

        if (userRepository.existsByUserEmail(dto.getUserEmail()))  {
            throw new ApiException(
                    StatusCode.CONFLICT, Message.DUPLICATE_EMAIL_EXCEPTION
            );
        }

        String encodedPwd = passwordEncoder.encode(dto.getPassword());

        User user = User.builder()
                .userEmail(dto.getUserEmail())
                .password(encodedPwd)
                .birthDate(dto.getBirthDate())
                .role(UserRole.USER)
                .build();

        userRepository.save(user);
    }

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

    public UsernameCheckResDto checkUsernameAvailable(String username) {
        boolean available = !userRepository.existsByUserName(username);
        String message = available
                ? "사용 가능한 닉네임입니다."
                : "이미 사용중인 닉네임입니다.";
        return new UsernameCheckResDto(available, message);
    }

}
