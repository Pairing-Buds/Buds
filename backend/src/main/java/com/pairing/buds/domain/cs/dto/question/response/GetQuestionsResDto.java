package com.pairing.buds.domain.cs.dto.question.response;

import com.pairing.buds.domain.cs.entity.Question;
import jakarta.validation.Valid;
import lombok.*;

import java.util.List;
import java.util.stream.Collectors;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class GetQuestionsResDto {

    List<QuestionDto> questions;

    public static GetQuestionsResDto toGetQuestionsResDto(List<Question> questions){
        return  GetQuestionsResDto.builder()
                .questions(questions.stream().map(QuestionDto::toQuestionDto).collect(Collectors.toList()))
                .build();
    }
}
