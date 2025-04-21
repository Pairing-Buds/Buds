package com.pairing.buds.domain.emotion.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "emotion_badges")
public class EmotionBadge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "emotion_badge_id")
    private Integer id;

    @Column(name = "emotion", nullable = false)
    private String emotion;

    @Column(name = "image", nullable = false)
    private String image;

}
