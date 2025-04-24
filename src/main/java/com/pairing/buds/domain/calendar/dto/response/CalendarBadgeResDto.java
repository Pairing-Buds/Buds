package com.pairing.buds.domain.calendar.dto.response;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CalendarBadgeResDto {
    private String date;
    private String badge;
}
