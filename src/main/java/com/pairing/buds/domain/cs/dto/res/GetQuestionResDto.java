package com.pairing.buds.domain.cs.dto.res;

import com.pairing.buds.domain.cs.entity.Question;
import com.pairing.buds.domain.user.entity.User;
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
public class GetQuestionResDto {

    @Positive
    @NotNull
    private int questionId;

    @NotNull
    private User user;

    private String subject;

    private String content;

    public static GetQuestionResDto toDto(Question question){
        return GetQuestionResDto.builder()
                .questionId(question.getId())
                .user(question.getUser())
                .subject(question.getSubject())
                .content(question.getContent())
                .build();
    }
}
