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

    @Positive(message = "Gotcha! Ha Ha!")
    @NotNull(message = "Seriously? Please Give Me Right Data.. Not Abusing")
    private int userId;

    @NotEmpty
    @NotBlank
    @Length(min = 4, max = 4 , message = "Oh, Not 4 characters.. what's wrong with you?")
    private String wakeTime;

}
