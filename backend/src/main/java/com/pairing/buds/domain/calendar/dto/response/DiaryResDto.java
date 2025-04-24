package com.pairing.buds.domain.calendar.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DiaryResDto {
    private String diaryType;
    private String content;
    private String date;

}
