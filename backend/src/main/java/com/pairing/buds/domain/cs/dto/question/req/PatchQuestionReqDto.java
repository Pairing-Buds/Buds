package com.pairing.buds.domain.cs.dto.question.req;

import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
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
