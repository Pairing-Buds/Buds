package com.pairing.buds.domain.activity.dto.req;

import com.pairing.buds.domain.activity.entity.Activity;
import com.pairing.buds.domain.activity.entity.ActivityType;
import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDateTime;

@Setter
@Getter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class WakeVerifyReqDto {

    @Positive
    @NotBlank
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime userWakeTimeSet;

    @Positive
    @NotBlank
    @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss")
    private LocalDateTime userRealWakeTime;

    public static Activity toActivity(User user){
        return Activity.builder()
                .name(ActivityType.WAKE)
                .description("만보기 활동 인증")
                .bonusLetter(3)
                .build();
    }
}
