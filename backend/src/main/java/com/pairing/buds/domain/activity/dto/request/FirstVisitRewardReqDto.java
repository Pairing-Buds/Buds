package com.pairing.buds.domain.activity.dto.request;

import com.pairing.buds.domain.activity.entity.PageName;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class FirstVisitRewardReqDto {

    @NotNull
    private PageName pageName;
}
