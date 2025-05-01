package com.pairing.buds.domain.activity.dto.req;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class ActivitySentenceVoiceReqDto {

    @NotBlank
    private String originalSentenceText;

    @NotBlank
    private String userSentenceText;
}
