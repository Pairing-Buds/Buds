package com.pairing.buds.domain.letter.entity;

import com.pairing.buds.domain.users.entity.Users;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

/**
 * 검토 필요
 */
@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "letter_favorites")
public class LetterFavorite {

    @Id
    @Column(name = "letter_id")
    private Integer letterId;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId
    @JoinColumn(
            name = "letter_id",
            foreignKey = @ForeignKey(name = "FK_letters_TO_letter_favorites_1")
    )
    private Letter letter;

    @ManyToOne
    @JoinColumn(
            name = "user_id",
            referencedColumnName = "user_id",
            foreignKey = @ForeignKey(name = "FK_letter_favorites_users_user_id")
    )
    private Users user;

    @CreationTimestamp
    private LocalDateTime createdAt;

}
