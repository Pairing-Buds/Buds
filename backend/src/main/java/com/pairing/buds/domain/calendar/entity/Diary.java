package com.pairing.buds.domain.calendar.entity;

import com.pairing.buds.common.basetime.CreateBaseTime;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

import java.util.Date;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "diaries")
public class Diary extends CreateBaseTime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "diary_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(name = "emotion_diary", nullable = false)
    private String emotion_diary;

    @Column(name = "active_diary", nullable = false)
    private String active_diary;

    @Column(name = "date", nullable = false)
    private Date date; //저장된 날짜가 아닌 일기 날짜

}
