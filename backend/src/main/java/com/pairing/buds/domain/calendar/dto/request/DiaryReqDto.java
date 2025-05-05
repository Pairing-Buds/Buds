package com.pairing.buds.domain.calendar.dto.request;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class DiaryReqDto {
    private String active_diary;
    private String emotion_diary;
    private String date;
}
