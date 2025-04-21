package com.pairing.buds.domain.letter.entity;

import com.pairing.buds.common.basetime.CUBaseTime;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "matches")
public class Match extends CUBaseTime {

    @EmbeddedId
    private MatchId id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("user1")
    @JoinColumn(name = "user1_id", referencedColumnName = "user_id", nullable = false)
    private User user1;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("user2")
    @JoinColumn(name = "user2_id", referencedColumnName = "user_id", nullable = false)
    private User user2;

}
