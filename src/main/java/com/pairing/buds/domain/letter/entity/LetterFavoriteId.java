package com.pairing.buds.domain.letter.entity;

import jakarta.persistence.*;
import lombok.*;

import java.io.Serializable;

@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LetterFavoriteId {

    @Column(name = "letter_id", nullable = false)
    private Integer letterId;

    @Column(name = "user_id", nullable = false)
    private Integer userId;

}
