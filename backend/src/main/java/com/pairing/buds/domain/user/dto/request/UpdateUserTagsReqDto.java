package com.pairing.buds.domain.user.dto.request;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Size;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class UpdateUserTagsReqDto {

        @Size(min = 0, max = 3)
        private List<String> tagTypes;

}
