package com.pairing.buds.common.auth.service;

import com.pairing.buds.common.auth.dto.request.UserSignupReqDto;
import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.entity.User;
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
            throw new ApiException(StatusCode.CONFLICT, Message.DUPLICATE_EMAIL_EXEPTION);
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

}
