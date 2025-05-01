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

    @Column(name = "user_name", nullable = false)
    private String userName;

    @Enumerated(EnumType.STRING)
    @Column(name = "user_character", nullable = false)
    private UserCharacter userCharacter;

    @OneToMany(
            mappedBy = "user",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    private Set<Tag> tags = new HashSet<>();

    @Column(name = "letter_cnt", nullable = false)
    private Integer letterCnt;

    @Enumerated(EnumType.STRING)
    @Column(name = "is_completed", nullable = false)
    private SignupStatus isCompleted;

    @Column(name = "letter_cnt")
    private int letterCnt;

    @PrePersist
    private void prePersist() {
        if (this.isActive == null)    this.isActive = true;
        if (this.userName == null)      this.userName = "익명";
        if (this.userCharacter == null) this.userCharacter = UserCharacter.GECKO;
        if (this.letterCnt == null)      this.letterCnt = 0;
        if (this.isCompleted == null)   this.isCompleted = SignupStatus.PENDING;
    }

}
