package com.pairing.buds.common.auth.dto.response;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KakaoTokenResDto {

    private String accessToken;
    private String refreshToken;

}
