package com.pairing.buds.domain.cs.dto.question.req;


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
public class DeleteQuestionReqDto {

    @NotNull
    @Positive
    private int questionId;
}
