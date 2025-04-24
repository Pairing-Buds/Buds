package com.pairing.buds.domain.calendar.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Embeddable
@Getter
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode
public class CalendarBadgeId implements Serializable {

    @Column(name = "calendar_id")
    private Integer calendarId;

    @Column(name = "badge_id")
    private Integer badgeId;
}
