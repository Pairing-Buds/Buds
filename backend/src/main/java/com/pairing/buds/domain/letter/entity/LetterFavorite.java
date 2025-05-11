package com.pairing.buds.domain.letter.entity;

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
@Table(name = "letter_favorites")
public class LetterFavorite extends CreateBaseTime {

    @EmbeddedId
    private LetterFavoriteId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("letterId")
    @JoinColumn(name = "letter_id", nullable = false)
    private Letter letter;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("userId")
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

}
