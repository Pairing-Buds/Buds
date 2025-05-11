package com.pairing.buds.domain.admin.dto.response;

import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.user.entity.UserRole;
import jakarta.validation.Valid;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class AdminDto {

    private int id;

    private String email;

    private UserRole role;

    public static AdminDto toAdminDto(Admin admin){
        if(admin != null){
            return AdminDto.builder()
                    .id(admin.getId())
                    .email(admin.getEmail())
                    .role(admin.getRole())
                    .build();
        }else{
            return null;
        }
    }
}
