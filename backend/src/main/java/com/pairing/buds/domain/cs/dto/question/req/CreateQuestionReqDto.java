package com.pairing.buds.domain.cs.dto.question.req;

import jakarta.persistence.Column;
import jakarta.validation.Valid;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class CreateQuestionReqDto {

    private String subject;

    private String content;
}
