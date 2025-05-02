package com.pairing.buds.domain.user.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MyInfoResDto {

    private String userEmail;
    private String userName;
    private Integer letterCnt;

}
