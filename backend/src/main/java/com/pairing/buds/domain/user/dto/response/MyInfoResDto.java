package com.pairing.buds.domain.user.dto.response;

import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.entity.UserCharacter;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MyInfoResDto {

    private String userEmail;
    private String userName;
    private Integer letterCnt;
    private UserCharacter userCharacter;

    public static MyInfoResDto toMyInfoRes(User user) {
        return new MyInfoResDto(
                user.getUserEmail(),
                user.getUserName(),
                user.getLetterCnt(),
                user.getUserCharacter()
        );
    }

}
