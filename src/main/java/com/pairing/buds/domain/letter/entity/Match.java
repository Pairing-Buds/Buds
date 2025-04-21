package com.pairing.buds.domain.letter.entity;

import com.pairing.buds.common.basetime.CUBaseTime;
import com.pairing.buds.common.basetime.UpdateBaseTime;
import com.pairing.buds.domain.page.entity.PageVisitId;
import com.pairing.buds.domain.users.entity.Users;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CurrentTimestamp;
import org.hibernate.annotations.UpdateTimestamp;
import org.springframework.data.annotation.CreatedDate;

import java.time.LocalDateTime;

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
    private Users user1;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @MapsId("user2")
    @JoinColumn(name = "user2_id", referencedColumnName = "user_id", nullable = false)
    private Users user2;

}
