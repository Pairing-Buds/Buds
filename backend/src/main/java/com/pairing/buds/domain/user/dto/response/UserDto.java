package com.pairing.buds.domain.user.dto.response;

import com.pairing.buds.domain.user.entity.SignupStatus;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.entity.UserCharacter;
import com.pairing.buds.domain.user.entity.UserRole;
import jakarta.persistence.*;
import jakarta.validation.Valid;
import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class UserDto {

    private int userId;

    private String userEmail;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate birthDate;

    private UserRole role;

    private Boolean isActive;

    private Integer letterCnt;

    private String userName;

    public static UserDto toDto(User user){
        return UserDto.builder()
                .userId(user.getId())
                .userEmail(user.getUserEmail())
                .birthDate(user.getBirthDate())
                .role(user.getRole())
                .isActive(user.getIsActive())
                .letterCnt(user.getLetterCnt())
                .userName(user.getUserName())
                .build();
    }

}
