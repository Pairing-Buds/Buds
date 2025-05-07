package com.pairing.buds.domain.calendar.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "badges")
public class Badge {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "badge_id")
    private Integer id;

    @Column(name = "badge_type")
    private RecordType badgeType;

    @Enumerated(EnumType.STRING)
    @Column(name = "name")
    private BadgeType name;

}
