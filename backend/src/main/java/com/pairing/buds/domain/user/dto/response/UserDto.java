package com.pairing.buds.domain.user.dto.response;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.pairing.buds.domain.user.entity.*;
import jakarta.validation.Valid;
import lombok.*;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class UserDto {

    private int userId;

    private String userEmail;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDate birthDate;

    private UserRole role;

    private Boolean isActive;

    private Integer letterCnt;

    private String userName;

    private List<String> tagTypes;

    public static UserDto toDto(User user){
        return UserDto.builder()
                .userId(user.getId())
                .userEmail(user.getUserEmail())
                .birthDate(user.getBirthDate())
                .role(user.getRole())
                .isActive(user.getIsActive())
                .letterCnt(user.getLetterCnt())
                .userName(user.getUserName())
                .tagTypes(user.getTags().stream().map(tag -> tag.getTagType().getTagName()).collect(Collectors.toList()))
                .build();
    }

}
