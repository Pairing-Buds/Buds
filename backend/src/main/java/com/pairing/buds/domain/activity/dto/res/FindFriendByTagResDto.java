package com.pairing.buds.domain.activity.dto.res;

import com.pairing.buds.domain.user.dto.response.UserDto;
import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.Valid;
import lombok.*;

import java.util.Set;
import java.util.stream.Collectors;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class FindFriendByTagResDto {

    private Set<UserDto> users;

    public static Set<UserDto> toDto(Set<User> users){
        return users.parallelStream().map(UserDto::toDto).collect(Collectors.toSet());
    }

}
