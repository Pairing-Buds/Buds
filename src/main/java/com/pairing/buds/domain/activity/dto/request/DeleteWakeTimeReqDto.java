package com.pairing.buds.domain.activity.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class DeleteWakeTimeReqDto {

    @Positive(message = "Gotcha! Ha Ha!")
    @NotNull(message = "Seriously? Please Give Me Right Data.. Not Abusing")
    private int sleepId;
}
