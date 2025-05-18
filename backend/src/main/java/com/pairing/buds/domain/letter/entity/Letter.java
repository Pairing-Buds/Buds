package com.pairing.buds.domain.letter.entity;

import com.pairing.buds.common.basetime.CreateBaseTime;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "letters")
public class Letter extends CreateBaseTime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "letter_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "receiver", referencedColumnName = "user_id", nullable = false)
    private User receiver;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "sender", referencedColumnName = "user_id", nullable = false)
    private User sender;

    @Column(name = "content")
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    private LetterStatus status = LetterStatus.UNREAD;

    @Column(name = "is_tag_based", nullable = false)
    private Boolean isTagBased;

    @Column(name = "is_scrapped")
    private Boolean isScrapped = false;

}
