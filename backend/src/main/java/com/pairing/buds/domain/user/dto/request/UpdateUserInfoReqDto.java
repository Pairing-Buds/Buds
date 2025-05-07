package com.pairing.buds.domain.user.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class UpdateUserInfoReqDto {

    @NotBlank(message = "캐릭터를 선택해주세요.")
    private String userCharacter;

}
