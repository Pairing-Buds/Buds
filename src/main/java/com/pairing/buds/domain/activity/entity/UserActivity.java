package com.pairing.buds.domain.activity.entity;

import com.pairing.buds.domain.users.entity.Users;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Data // toString 순환 참조 예방 @Getter 사용 권장
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "user_activities")
public class UserActivity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer userActivityId; // id로 해도 자동으로 테이블명_id 형태로 해줄 거에요!

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private Users user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activity_id", nullable = false)
    private Activity activity;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private UserActivityStatus status;

    @Column(name = "proof")
    private String proof;

    @Column(name = "recorded_at", nullable = false)
    private LocalDateTime recordedAt;

}
