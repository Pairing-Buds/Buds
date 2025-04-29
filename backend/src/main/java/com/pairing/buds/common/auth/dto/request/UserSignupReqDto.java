package com.pairing.buds.common.auth.dto.request;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
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
    @Email
    private String userEmail;

    @NotBlank
    @Length(max = 50, message = "비밀번호는 최대 50자까지 지정 가능합니다.")
    private String password;

    private LocalDate birthDate;

}
