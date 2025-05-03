package com.pairing.buds.domain.letter.dto.request;

import jakarta.validation.Valid;
import lombok.*;
import org.hibernate.validator.constraints.Length;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class SendLetterReqDto {

    @Length(min = 10, message = "편지는 10자 이상 작성하셔야 합니다.")
    private String content;

    private Boolean isTagBased;

}
