package com.pairing.buds.domain.user.dto.response;

import jakarta.validation.Valid;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TagResDto {

    private String tagType;
    private String displayName;

}
