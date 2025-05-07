package com.pairing.buds.domain.admin.dto.req;

import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.cs.entity.Answer;
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
public class ActiveUserReqDto {

    @NotNull
    @Positive
    private int userId;

    public static User toActiveUser(User user){
        user.setIsActive(true);
        return user;
    }
}
