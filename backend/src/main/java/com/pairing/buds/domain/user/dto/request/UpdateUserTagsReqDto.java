package com.pairing.buds.domain.user.dto.request;

import com.pairing.buds.domain.user.entity.TagType;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class UpdateUserTagsReqDto {

    @NotNull
    private List<TagType> tags;

}
