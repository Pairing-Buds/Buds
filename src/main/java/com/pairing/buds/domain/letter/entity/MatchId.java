package com.pairing.buds.domain.letter.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MatchId implements Serializable {

    @Column(name = "user1_id", nullable = false)
    private Integer user1;

    @Column(name = "user2_id", nullable = false)
    private Integer user2;

}
