package com.pairing.buds.domain.calendar.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "calendar_badges")
public class CalendarBadge {

    @EmbeddedId
    private CalendarBadgeId id;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("calendarId")
    @JoinColumn(name = "calendar_id", nullable = false)
    private Calendar calendar;

    @ManyToOne(fetch = FetchType.LAZY)
    @MapsId("badgeId")
    @JoinColumn(name = "badge_id", nullable = false)
    private Badge badge;
}
