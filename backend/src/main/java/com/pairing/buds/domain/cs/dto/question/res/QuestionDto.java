package com.pairing.buds.domain.cs.dto.question.res;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.pairing.buds.domain.cs.dto.answer.res.AnswerDto;
import com.pairing.buds.domain.cs.entity.Question;
import com.pairing.buds.domain.cs.entity.QuestionStatus;
import com.pairing.buds.domain.user.dto.response.UserDto;
import jakarta.validation.Valid;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class QuestionDto {

    private int id;
    private UserDto user;
    private String subject;
    private String content;
    private AnswerDto answer;
    private QuestionStatus status;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private LocalDateTime createdAt;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private LocalDateTime updatedAt;
    public static QuestionDto toQuestionDto(Question question){
        return QuestionDto.builder()
                .id(question.getId())
                .content(question.getContent())
                .subject(question.getSubject())
                .user(UserDto.toDto(question.getUser()))
                .answer(AnswerDto.toAnswerDto(question.getAnswer()))
                .status(question.getStatus())
                .createdAt(question.getCreatedAt())
                .updatedAt(question.getUpdatedAt())
                .build();
    }

}
