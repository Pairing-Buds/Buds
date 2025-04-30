package com.pairing.buds.common.auth.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UsernameCheckResDto {

    private boolean available;
    private String message;

}
