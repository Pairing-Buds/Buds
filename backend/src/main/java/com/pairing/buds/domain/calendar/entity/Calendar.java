package com.pairing.buds.domain.calendar.entity;
import com.pairing.buds.common.basetime.CreateBaseTime;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "calendars")
public class Calendar extends CreateBaseTime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "calendar_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Enumerated(EnumType.STRING)
    @Column(name = "badge")
    private BadgeType badge; // 캘린더에 표시할 대표 뱃지, 뱃지를 저장할 때 기분 뱃지가 있다면 기분 뱃지, 없다면 가장 최근 활동 뱃지가 대표 이미지

    @Column(name = "date", nullable = false)
    private LocalDate date;

    public Calendar(User user, BadgeType badge, LocalDate date) {
        this.user = user;
        this.badge = badge;
        this.date = date;
    }
}
