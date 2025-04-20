package com.pairing.buds.domain.letter.entity;

import com.pairing.buds.domain.activity.entity.UserActivityStatus;
import com.pairing.buds.domain.users.entity.Users;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "letters")
public class Letter {
    // @Ge.. Id..
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer letterId;

    @ManyToOne
    @JoinColumn(
            name = "match_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_matches_TO_letters_1")
    )
    private Match match;

    @ManyToOne
    @JoinColumn(
            name = "receiver_id",
            referencedColumnName = "user_id",
            foreignKey = @ForeignKey(name = "FK_letters_users_receiver_id")
    )
    private Users receiver;

    @Column(name = "content")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private LetterStatus status;

    @CreationTimestamp
    private LocalDateTime createdAt;

}
