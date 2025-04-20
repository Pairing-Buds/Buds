package com.pairing.buds.domain.survey.entity;

import com.pairing.buds.domain.users.entity.Users;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Data // toString 순환 참조 예방 @Getter 사용 권장
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "surveys")
public class Survey {

    // 카멜 케이스 및 id만 적어도 자동 구성
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer survey_id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_surveys_users_user_id")
    )
    private Users user;

    @Column(name = "questions", columnDefinition = "JSON")
    private String questions;

    @Column(name = "answers", columnDefinition = "JSON")
    private String answers;

    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "level")
    private String level;
}
