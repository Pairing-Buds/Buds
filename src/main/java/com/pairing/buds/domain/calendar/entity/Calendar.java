package com.pairing.buds.domain.calendar.entity;
import com.pairing.buds.common.basetime.CreateBaseTime;
import com.pairing.buds.domain.emotion.entity.EmotionBadge;
import com.pairing.buds.domain.users.entity.Users;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

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
    private Users user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "emotion_badge_id", nullable = false)
    private EmotionBadge emotionBadge;

    // 2025-04-21 형식인지?
    @Column(name = "date", nullable = false)
    private LocalDate date;

}
