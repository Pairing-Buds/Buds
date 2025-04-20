package com.pairing.buds.domain.activity.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.Set;

@Entity
@Data // toString 순환 참조 예방 @Getter 사용 권장
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "activities")
public class Activity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer activityId; // id로 해도 자동으로 테이블명_id 형태로 해줄 거에요!

    @Column(name = "name", nullable = false)
    private String name;

    @Column(name = "description")
    private String description;

    @OneToMany(mappedBy = "activity")
    private Set<UserActivity> userActivities;

}

