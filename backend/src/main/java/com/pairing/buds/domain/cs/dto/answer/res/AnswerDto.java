package com.pairing.buds.domain.cs.dto.answer.res;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.pairing.buds.domain.admin.dto.res.AdminDto;
import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.cs.entity.Answer;
import com.pairing.buds.domain.user.dto.response.UserDto;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
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

    private AdminDto admin;

    private UserDto user;

    private String content;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private LocalDateTime createdAt;

    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private LocalDateTime updatedA

    public static AnswerDto toAnswerDto(Answer answer){
        return AnswerDto.builder()
                .id(answer.getId())
                .admin(AdminDto.toAdminDto(answer.getAdmin()))
                .user(UserDto.toDto(answer.getUser()))
                .content(answer.getContent())
                .createdAt(answer.getCreatedAt())
                .updatedAt(answer.getUpdatedAt())
                .build();
    }
}
