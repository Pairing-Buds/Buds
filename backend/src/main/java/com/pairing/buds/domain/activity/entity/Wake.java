package com.pairing.buds.domain.activity.entity;

import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "wakes")
public class Wake {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "wake_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // HHMM 형식
    @Column(name = "wake_time")
    private String wakeTime;
}
