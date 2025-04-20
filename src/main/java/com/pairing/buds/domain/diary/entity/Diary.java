package com.pairing.buds.domain.diary.entity;

import com.pairing.buds.domain.users.entity.Users;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.hibernate.annotations.CreationTimestamp;

import java.lang.annotation.Retention;
import java.lang.annotation.Target;
import java.time.LocalDateTime;

import static java.lang.annotation.RetentionPolicy.RUNTIME;

@Entity
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Table(name = "diaries")
public class Diary {
    // getter, id
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer diaryId;
/**
    @Target({})
    @Retention(RUNTIME)
    public @interface ForeignKey {

         * (Optional) The name of the foreign key constraint.  If this
         * is not specified, it defaults to a provider-generated name.
        String name() default "";

 혹시 name 키를 직접 제어 하신 용도를 여쭈어 봐도 될까요?
 **/

        @ManyToOne
    @JoinColumn(
            name = "user_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "FK_diaries_users_user_id")
    )
    private Users user;



    @Column(name = "subject", nullable = false)
    private String subject;

    @Column(name = "content", nullable = false)
    private String content;

    @CreationTimestamp
    private LocalDateTime createdAt;

}
