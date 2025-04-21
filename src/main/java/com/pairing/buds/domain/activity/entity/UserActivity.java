package com.pairing.buds.domain.activity.entity;

import com.pairing.buds.common.basetime.CreateBaseTime;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "user_activities")
public class UserActivity extends CreateBaseTime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_activity_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "activity_id", nullable = false)
    private Activity activity;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private UserActivityStatus status;

    @Column(name = "proof")
    private String proof;

}
