package com.pairing.buds.domain.letter.entity;

import com.pairing.buds.domain.users.entity.Users;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "matches")
public class Match {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer matchId;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user1_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_matches_users_user1_id")
    )
    private Users user1;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(
            name = "user2_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_matches_users_user2_id")
    )
    private Users user2;

    @Column(name = "matched_at", nullable = false)
    private LocalDateTime matchedAt;

}
