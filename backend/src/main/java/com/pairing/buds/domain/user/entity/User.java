package com.pairing.buds.domain.user.entity;

import com.pairing.buds.common.basetime.CUBaseTime;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

import java.time.LocalDate;
import java.util.HashSet;
import java.util.Set;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "users")
public class User extends CUBaseTime {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id")
    private Integer id;

    @Column(name = "user_email", nullable = false)
    private String userEmail;

    @Column(name = "password", nullable = false)
    private String password;

    @DateTimeFormat(pattern = "yyyy-MM-dd")
    @Column(name = "birth_date")
    private LocalDate birthDate;

    @Enumerated(EnumType.STRING)
    @Column(name = "role", nullable = false)
    private UserRole role;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;

    @Column(name = "letter_cnt", nullable = false)
    private Integer letterCnt;

    @Column(name = "user_name", nullable = false)
    private String userName;

    @Enumerated(EnumType.STRING)
    @Column(name = "user_character", nullable = false)
    private UserCharacter userCharacter;

    @Enumerated(EnumType.STRING)
    @Column(name = "is_completed", nullable = false)
    private SignupStatus isCompleted;

    // 페르소나 점수 컬럼들
    @Column(name = "seclusion_score", nullable = false)
    private Integer seclusionScore;

    @Column(name = "openness_score", nullable = false)
    private Integer opennessScore;

    @Column(name = "sociability_score", nullable = false)
    private Integer sociabilityScore;

    @Column(name = "routine_score", nullable = false)
    private Integer routineScore;

    @Column(name = "quietness_score", nullable = false)
    private Integer quietnessScore;

    @Column(name = "expression_score", nullable = false)
    private Integer expressionScore;

    @OneToMany(
            mappedBy = "user",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private Set<Tag> tags = new HashSet<>();

    @PrePersist
    private void prePersist() {
        if (this.isActive == null)    this.isActive = true;
        if (this.userName == null)      this.userName = "익명";
        if (this.userCharacter == null) this.userCharacter = UserCharacter.GECKO;
        if (this.letterCnt == null)      this.letterCnt = 0;
        if (this.isCompleted == null)   this.isCompleted = SignupStatus.PENDING;
        if (this.seclusionScore == null)          this.seclusionScore = 0;
        if (this.opennessScore == null)       this.opennessScore = 0;
        if (this.sociabilityScore == null)    this.sociabilityScore = 0;
        if (this.routineScore == null)        this.routineScore = 0;
        if (this.quietnessScore == null)      this.quietnessScore = 0;
        if (this.expressionScore == null)     this.expressionScore = 0;
    }

}
