package com.pairing.buds.common.auth.service;

import com.pairing.buds.common.auth.utils.CustomUserDetails;
import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.admin.repository.AdminRepository;
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
    private final AdminRepository adminRepository;

    @Override
    public UserDetails loadUserByUsername(String email) throws UsernameNotFoundException {
        // 관리자
        if ("admin@ssafy.com".equalsIgnoreCase(email)) {
            Admin admin = adminRepository.findByEmail(email)
                    .orElseThrow(() ->
                            new UsernameNotFoundException("관리자 계정을 찾을 수 없습니다. 이메일: " + email)
                    );
            return new CustomUserDetails(admin);
        }

        // 일반 사용자
        User user = userRepository.findByUserEmailAndIsActiveTrue(email)
                .orElseThrow(() -> new UsernameNotFoundException("사용자를 찾을 수 없습니다. 이메일: " + email));

        return new CustomUserDetails(user);
    }

}
