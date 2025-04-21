package com.pairing.buds.domain.survey.entity;

import com.pairing.buds.common.basetime.CreateBaseTime;
import com.pairing.buds.domain.users.entity.Users;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "surveys")
public class Survey extends CreateBaseTime {
    
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "survey_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private Users user;

    @Column(name = "questions", columnDefinition = "JSON")
    private String questions;

    @Column(name = "answers", columnDefinition = "JSON")
    private String answers;

    @Column(name = "level")
    private String level;

}
