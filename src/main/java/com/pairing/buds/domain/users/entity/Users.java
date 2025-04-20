package com.pairing.buds.domain.users.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Getter @Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "users")
public class Users {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "user_id") // 자동으로 테이블명_변수명 잡아주긴 하는데
    // 이렇게 명시화 하는 것도 좋다고 생각합니다. 저도 주로 명확하게 적는 편이에요
    // ManyToOne에 fetch = FetchType.LAZY 같은 부분도 명시화 해주는 것 좋다고 생각해요
    private Integer userId;

    @Column(name = "user_email", nullable = false)
    private String userEmail;

    @Column(name = "user_name", nullable = false)
    private String userName;

    @Column(name = "password", nullable = false)
    private String password;

    // @DateTimeFormat(pattern = "yyyy-MM-dd HH:mm:ss") 이렇게 하는 것은 어떨까요?
    @Column(name = "birth_date")
    private LocalDateTime birthDate;

    @CreationTimestamp
    private LocalDateTime createdAt; // 상속 받을 클래스 하나 만들어서 관리 하는 것은 어떨까요?

    @UpdateTimestamp
    private LocalDateTime updatedAt;

    @Column(name = "role")
    private String role; // enum 타입으로 하기로 했었던 것 같은데 확인이 필요합니다

    @Column(name = "is_active", nullable = false)
    private Boolean isActive;

}
