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
@Table(name = "sleep")
public class Sleep {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "sleep_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    // HHMM 형식
    @Column(name = "wake_time")
    private String wakeTime;

}
