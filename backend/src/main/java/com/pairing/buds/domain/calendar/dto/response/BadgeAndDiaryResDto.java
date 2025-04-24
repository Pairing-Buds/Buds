package com.pairing.buds.domain.calendar.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BadgeAndDiaryResDto {
    private String date;
    private List<BadgeResDto> badgeList;
    private List<DiaryResDto> diaryList;

}
