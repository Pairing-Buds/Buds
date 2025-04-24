package com.pairing.buds.domain.cs.dto.answer.req;

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
public class DeleteAnswerReqDto {

    @NotNull
    @Positive
    private int answerId;
}
