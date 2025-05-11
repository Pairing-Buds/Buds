package com.pairing.buds.domain.user.entity;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonValue;
import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import lombok.Getter;

import java.util.Arrays;
import java.util.Map;
import java.util.stream.Collectors;

@Getter
public enum UserCharacter {

    GECKO("게코"),
    RABBIT("토끼"),
    FROG("개구리"),
    MARMOT("마멋"),
    CAT("고양이"),
    DUCK("오리");

    private final String description;

    // 한글 → enum 상수 매핑을 위한 Map
    private static final Map<String, UserCharacter> BY_DESCRIPTION =
            Arrays.stream(values())
                    .collect(Collectors.toMap(UserCharacter::getDescription, uc -> uc));

    UserCharacter(String description) {
        this.description = description;
    }

    // 직렬화: enum → 한글
    @JsonValue
    public String getDescription() {
        return description;
    }

    // 역직렬화: 한글 → enum
    @JsonCreator(mode = JsonCreator.Mode.DELEGATING)
    public static UserCharacter fromDescription(String description) {
        UserCharacter uc = BY_DESCRIPTION.get(description);
        if (uc == null || description == null) {
            throw new ApiException(
                    StatusCode.BAD_REQUEST,
                    Message.INVALID_USER_CHARACTER
            );
        }
        return uc;
    }

}
