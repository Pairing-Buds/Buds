package com.pairing.buds.domain.cs.dto.question.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class CreateQuestionReqDto {

    @NotBlank
    private String subject;

    @NotBlank
    private String content;
}
