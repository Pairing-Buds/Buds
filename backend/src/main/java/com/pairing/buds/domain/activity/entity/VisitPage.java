package com.pairing.buds.domain.activity.entity;

import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "visit_pages")
public class VisitPage {

    @Id @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "visit_page_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = true, cascade = {})
    @JoinColumn(name = "user_id", unique = true)
    private User user;
//
//    @Enumerated(EnumType.STRING)
//    @Column(name = "page_name")
//    private
}
