package com.pairing.buds.domain.user.dto.response;

import com.pairing.buds.domain.user.entity.Tag;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TagResDto {

    private String tagType;
    private String displayName;

    public static TagResDto toTagRes(Tag tag) {
        return new TagResDto(
                tag.getTagName().name(),
                tag.getTagName().getDisplayName()
        );
    }

}
