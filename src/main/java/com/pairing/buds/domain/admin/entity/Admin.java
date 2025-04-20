package com.pairing.buds.domain.admin.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "admin")
public class Admin {
    // toString 순환 참조 예방 @Getter 사용 권장
    // id로 해도 자동으로 테이블명_id 형태로 해줄 거에요!
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer adminId;

    @Column(name = "password", nullable = false)
    private String password;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt; // 여긴 CreationTimeStamp가 없네요?
                                    // BaseTimeEntity 같은거 만들어서 상속 구조를 쓰는 것은 어떨까요?
    @Column(name = "role")
    private String role; // Enum으로 하기로 했었던 것 같기도..

}
