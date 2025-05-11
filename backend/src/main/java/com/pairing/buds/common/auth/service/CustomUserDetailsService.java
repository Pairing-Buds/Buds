package com.pairing.buds.common.auth.service;

import com.pairing.buds.common.auth.utils.CustomUserDetails;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
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
        // 활성화 상태인 이메일 조회
        User user = userRepository.findByUserEmailAndIsActiveTrue(email)
                .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다. 이메일: " + email));

        // 찾은 User 객체를 CustomUserDetails로 반환
        return new CustomUserDetails(user);
    }

}
