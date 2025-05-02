package com.pairing.buds.domain.user.dto.request;

import com.pairing.buds.domain.user.entity.UserCharacter;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class UpdateUserInfoReqDto {

    @NotNull
    private UserCharacter userCharacter;

}
