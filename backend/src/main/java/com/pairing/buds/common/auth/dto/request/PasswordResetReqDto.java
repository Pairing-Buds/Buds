package com.pairing.buds.common.auth.dto.request;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PasswordResetReqDto {

    private String token;
    private String newPassword;

}
