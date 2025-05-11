package com.pairing.buds.domain.calendar.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiaryResDto {
    private Integer diaryNo;
    private String emotionDiary;
    private String activeDiary;

}
