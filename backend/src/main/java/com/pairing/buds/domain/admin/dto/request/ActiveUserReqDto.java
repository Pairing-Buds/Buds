package com.pairing.buds.domain.admin.dto.request;

import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ActiveUserReqDto {

    @NotNull
    @Positive
    private int userId;

    public static User toActiveUser(User user){
        user.setIsActive(true);
        return user;
    }
}
