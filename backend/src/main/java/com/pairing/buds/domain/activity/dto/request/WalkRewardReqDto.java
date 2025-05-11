package com.pairing.buds.domain.activity.dto.request;

import com.pairing.buds.domain.activity.entity.Activity;
import com.pairing.buds.domain.activity.entity.ActivityType;
import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Positive;
import lombok.*;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class WalkRewardReqDto {

    @Positive
//    @NotBlank
    private int userStepSet;

    @Positive
//    @NotBlank
    private int userRealStep;
    
    public static Activity toActivity(User user, WalkRewardReqDto dto){
        return Activity.builder()
                .name(ActivityType.WALK)
                .description("만보기 활동 인증")
                .bonusLetter(3)
                .build();
    }
}
