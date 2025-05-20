package com.pairing.buds.domain.user.dto.response;

import com.pairing.buds.domain.user.entity.User;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GetAllUsersResDto {

    private int userId;

    private String username;

    public static GetAllUsersResDto toDto(User user){
        return GetAllUsersResDto.builder()
                .userId(user.getId())
                .username(user.getUserName())
                .build();
    }
}
