package com.pairing.buds.domain.user.dto.request;

import jakarta.validation.Valid;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class UpdateUserTagsReqDto {

    private List<Integer> tagTypeIds;

}
