package com.pairing.buds.common.auth.dto.request;

import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.entity.UserRole;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.*;
import org.hibernate.validator.constraints.Length;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserSignupReqDto {

    @NotBlank
    @Email(regexp = "[0-9a-zA-Z]*@[a-z]*.[a-z]{2,3}]")
    private String userEmail;

    @NotBlank
    @Length(max = 50, message = "비밀번호는 최대 50자까지 지정 가능합니다.")
    @Pattern(regexp = "[0-9a-zA-Z!@#(),.]{4,15}")
    private String password;

    private LocalDate birthDate;

    public static User toUser(UserSignupReqDto dto, String encodedPassword) {
        User user = new User();
        user.setUserEmail(dto.getUserEmail());
        user.setPassword(encodedPassword);
        user.setBirthDate(dto.getBirthDate());
        user.setRole(UserRole.USER);

        return user;
    }

}
