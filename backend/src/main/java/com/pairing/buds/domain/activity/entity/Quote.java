package com.pairing.buds.domain.activity.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "quotes")
public class Quote {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "quote_id")
    private Integer id;

    @Column(name = "sentence")
    private String sentence;

    @Column(name = "speaker")
    private String speaker;
}
