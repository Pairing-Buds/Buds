package com.pairing.buds.common.auth.service;

import com.pairing.buds.common.auth.utils.CustomUserDetails;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.DisabledException;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {

    private final UserRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        User user = userRepository.findByUserEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다. 이메일: " + email));

        // 비활성 사용자라면 즉시 예외
        if (!user.getIsActive()) {
            throw new DisabledException("비활성(혹은 탈퇴)된 계정입니다.");
        }

        // 찾은 User 객체를 CustomUserDetails로 반환
        return new CustomUserDetails(user);
    }

}
