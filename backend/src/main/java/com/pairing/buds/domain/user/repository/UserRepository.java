package com.pairing.buds.domain.user.repository;

import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.TagType;
import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.Set;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByUserEmail(String email);

    boolean existsByUserEmail(@Email @NotNull String userEmail);

    boolean existsByUserName(String username);

    /** 취향 맞는 친구 추천 **/
    Set<User> findDistinctTop10ByIdNotAndIsActiveTrueAndTagsIn(
            int userId,
            Set<Tag> tags
    );

    /**
     * 편지 랜덤 발송 (필터링 적용)
     * - u.id <> :senderId
     * - 가장 최근 편지가 내가 보낸 편지이면서 1개월 이내인 경우 제외
     */
    @Query("""
        SELECT u FROM User u
        WHERE u.id <> :senderId
          AND u.isActive = true
          AND NOT EXISTS (
            SELECT l FROM Letter l
            WHERE ((l.sender.id = :senderId AND l.receiver.id = u.id)
                OR   (l.sender.id = u.id       AND l.receiver.id = :senderId))
              AND l.sender.id = :senderId
              AND l.createdAt >= :oneMonthAgo
              AND l.createdAt = (
                SELECT MAX(l2.createdAt) FROM Letter l2
                WHERE ((l2.sender.id = :senderId AND l2.receiver.id = u.id)
                    OR   (l2.sender.id = u.id       AND l2.receiver.id = :senderId))
              )
          )
        ORDER BY function('RAND')
        """)
    List<User> findRandomReceiver(
            @Param("senderId") Integer senderId,
            @Param("oneMonthAgo") LocalDateTime oneMonthAgo,
            Pageable pageable
    );

    /**
     * 편지 랜덤 발송 (태그 필터링 + 위 조건)
     */
    @Query("""
        SELECT DISTINCT u FROM User u
        JOIN u.tags t
        WHERE u.id <> :senderId
          AND u.isActive = true
          AND t.tagName IN :senderTagTypes
          AND NOT EXISTS (
            SELECT l FROM Letter l
            WHERE ((l.sender.id = :senderId AND l.receiver.id = u.id)
                OR   (l.sender.id = u.id       AND l.receiver.id = :senderId))
              AND l.sender.id = :senderId
              AND l.createdAt >= :oneMonthAgo
              AND l.createdAt = (
                SELECT MAX(l2.createdAt) FROM Letter l2
                WHERE ((l2.sender.id = :senderId AND l2.receiver.id = u.id)
                    OR   (l2.sender.id = u.id       AND l2.receiver.id = :senderId))
              )
          )
        ORDER BY function('RAND')
        """)
    List<User> findRandomReceiverByTags(
            @Param("senderId") Integer senderId,
            @Param("senderTagTypes") List<TagType> senderTagTypes,
            @Param("oneMonthAgo") LocalDateTime oneMonthAgo,
            Pageable pageable
    );

    boolean existsByUserEmailAndIsActiveTrue(@NotBlank @Email String userEmail);

    Optional<User> findByUserEmailAndIsActiveTrue(String email);

    List<User> findByIsActiveTrueAndLetterCntBetween(Integer min, Integer max);

    @Modifying
    @Query("DELETE FROM Tag t WHERE t.user.id = :userId")
    void deleteTagsByUserId(@Param("userId") Integer userId);

}
