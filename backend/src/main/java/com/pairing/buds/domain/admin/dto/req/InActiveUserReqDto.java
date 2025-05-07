package com.pairing.buds.domain.admin.dto.req;

import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class InActiveUserReqDto {

    @NotNull
    @Positive
    private int userId;

    public static User toInActiveUser(User user){
        user.setIsActive(false);
        return user;
    }
}
