package com.pairing.buds.domain.user.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "random_names")
public class RandomName {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "random_name_id")
    private Integer id;

    @Column(name = "random_name", nullable = false, length = 20)
    private String randomName;

    @Enumerated(EnumType.STRING)
    @ColumnDefault("'AVAILABLE'")
    @Column(name = "status", nullable = false)
    private RandomNameStatus status;

    @Column(name = "assigned_at")
    private LocalDateTime assignedAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

}
