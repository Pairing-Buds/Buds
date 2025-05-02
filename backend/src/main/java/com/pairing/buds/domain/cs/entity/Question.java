package com.pairing.buds.domain.cs.entity;

import com.pairing.buds.common.basetime.CUBaseTime;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.ColumnDefault;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "questions")
public class Question extends CUBaseTime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "question_id")
    private Integer id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", referencedColumnName = "user_id", nullable = false)
    private User user;

    @Column(name = "subject", nullable = false)
    private String subject;

    @Column(name = "content", nullable = false)
    private String content;

    @Enumerated(EnumType.STRING)
    @Column(name = "status", nullable = false)
    @ColumnDefault("'UNANSWERED'")
    private QuestionStatus status = QuestionStatus.UNANSWERED;

    @PrePersist
    public void initializeStatus(){
        if(this.status == null){
            this.status = QuestionStatus.UNANSWERED;
        }
    }

}
