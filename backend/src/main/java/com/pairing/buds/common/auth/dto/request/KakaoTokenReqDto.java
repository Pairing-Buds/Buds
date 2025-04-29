package com.pairing.buds.common.auth.dto.request;

import lombok.*;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class KakaoTokenReqDto {

    private String accessToken;

}
