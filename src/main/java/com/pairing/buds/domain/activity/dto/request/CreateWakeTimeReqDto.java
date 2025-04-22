package com.pairing.buds.domain.activity.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.*;
import org.hibernate.validator.constraints.Length;

@Getter @Setter
@NoArgsConstructor @AllArgsConstructor
@Builder
@Valid
public class CreateWakeTimeReqDto {

    @NotEmpty
    @NotBlank
    @Length(min = 4, max = 4 , message = "wakeTime field not proper")
    private String wakeTime;
}
