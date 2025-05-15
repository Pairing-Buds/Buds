package com.pairing.buds.domain.user.dto.response;

import com.pairing.buds.domain.user.entity.TagType;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TagTypeResDto {

    private Integer id;
    private String name;

    public static TagTypeResDto of(TagType e) {
        return new TagTypeResDto(
                e.getId(),
                e.getTagName()
        );
    }

}
