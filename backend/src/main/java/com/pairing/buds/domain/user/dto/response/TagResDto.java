package com.pairing.buds.domain.user.dto.response;

import com.pairing.buds.domain.user.entity.Tag;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TagResDto {

    private Integer userTagId;
    private String tagType;

    public static TagResDto toTagRes(Tag tag) {
        return new TagResDto(
                tag.getId(),
                tag.getTagType().getTagName()
        );
    }

}
