package com.pairing.buds.domain.letter.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Valid
public class CreateLetterByUserIdReqDto {

    @Positive
    @NotNull
    private int receiverId;

    @NotNull
    private String content;
}
