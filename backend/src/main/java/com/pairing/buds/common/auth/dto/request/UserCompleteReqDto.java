package com.pairing.buds.common.auth.dto.request;

import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserCompleteReqDto {

    @NotBlank(message = "유저 이름을 입력해주세요.")
    private String userName;

    @NotBlank(message = "캐릭터를 선택해주세요.")
    private String userCharacter;

}
