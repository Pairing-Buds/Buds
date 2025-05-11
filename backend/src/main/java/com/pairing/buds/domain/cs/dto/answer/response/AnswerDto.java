package com.pairing.buds.domain.cs.dto.answer.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.pairing.buds.domain.cs.entity.Answer;
import jakarta.validation.Valid;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class AnswerDto {

    private int id;

//    private AdminDto admin;
//
//    private UserDto user;

    private String content;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime createdAt;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime updatedAt;
    public static AnswerDto toAnswerDto(Answer answer){
        return AnswerDto.builder()
                .id(answer.getId())
//                .admin(AdminDto.toAdminDto(answer.getAdmin()))
//                .user(UserDto.toDto(answer.getUser()))
                .content(answer.getContent())
                .createdAt(answer.getCreatedAt())
                .updatedAt(answer.getUpdatedAt())
                .build();
    }
}
