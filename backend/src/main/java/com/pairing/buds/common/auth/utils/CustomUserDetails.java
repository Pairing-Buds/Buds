package com.pairing.buds.common.auth.utils;

import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.user.entity.User;
import lombok.Data;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

/**
 * 사용자의 인증 정보(사용자 ID, 역할)를 제공
 **/
@Data
public class CustomUserDetails implements UserDetails {
    private final Integer id;
    private final String username;
    private final String password;
    private final List<GrantedAuthority> authorities;
    private final boolean isActive;

    // User 기반 생성자
    public CustomUserDetails(User user) {
        this.id         = user.getId();
        this.username   = user.getUserEmail();
        this.password   = user.getPassword();
        this.isActive   = user.getIsActive();
        this.authorities = List.of(
                new SimpleGrantedAuthority(user.getRole().name())
        );
    }

    // Admin 기반 생성자
    public CustomUserDetails(Admin admin) {
        this.id         = admin.getId();
        this.username   = admin.getEmail();
        this.password   = admin.getPassword();
        this.isActive   = true;  // Admin 엔티티에 isActive 필드가 없다면 항상 활성화로 처리
        this.authorities = List.of(
                new SimpleGrantedAuthority(admin.getRole().name())
        );
        System.out.println(admin.getRole().name());
    }

    /** 사용자가 하나의 권한만 가지는 경우 **/
    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return authorities;
    }

    /** getUserId() 메서드 추가: 사용자 ID 반환 **/
    public Integer getUserId() {
        return id;
    }

    /** 이메일을 사용한 로그인 **/
    @Override
    public String getUsername() {
        return username;
    }

    @Override
    public String getPassword() {
        return password;
    }

    @Override
    public boolean isAccountNonExpired() {
        return UserDetails.super.isAccountNonExpired();
    }
    @Override
    public boolean isAccountNonLocked() {
        return UserDetails.super.isAccountNonLocked();
    }
    @Override
    public boolean isCredentialsNonExpired() {
        return UserDetails.super.isCredentialsNonExpired();
    }
    @Override
    public boolean isEnabled() {
        return isActive;
    }

}
