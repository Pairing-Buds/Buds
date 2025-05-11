package com.pairing.buds.domain.cs.dto.answer.request;

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
public class CreateAnswerReqDto {

    @Positive
    @NotNull
    private int userId;

    @Positive
    @NotNull
    private int questionId;

    @NotNull
    private String content;

    public static Answer toAnswer(Admin admin, User user, String content){
        return Answer.builder()
//                .admin(admin)
//                .user(user)
                .content(content)
                .build();
    }
}
