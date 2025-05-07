package com.pairing.buds.domain.calendar.dto.response;

import com.pairing.buds.domain.calendar.entity.BadgeType;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CalendarBadgeResDto {
    private String date;
    private BadgeType badge;
}
