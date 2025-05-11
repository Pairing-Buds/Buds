package com.pairing.buds.domain.cs.entity;

import com.pairing.buds.common.basetime.CUBaseTime;
import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "answers")
public class Answer extends CUBaseTime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "answer_id")
    private Integer id;


    // 변경을 대비한 주석처리 입니다.
//    @ManyToOne(fetch = FetchType.LAZY, optional = true)
//    @JoinColumn(name = "admin_id", referencedColumnName = "admin_id", nullable = true)
//    private Admin admin;

//    @ManyToOne(fetch = FetchType.LAZY, optional = false)
//    @JoinColumn(name = "user_id", referencedColumnName = "user_id", nullable = false)
//    private User user;

    @Column(name = "content", nullable = false)
    private String content;

}
