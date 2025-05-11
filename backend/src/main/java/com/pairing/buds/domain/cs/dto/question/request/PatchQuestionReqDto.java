package com.pairing.buds.domain.cs.dto.question.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class PatchQuestionReqDto {

    @NotNull
    private int questionId;

    @NotNull
    private String subject;

    @NotNull
    private String content;
}
