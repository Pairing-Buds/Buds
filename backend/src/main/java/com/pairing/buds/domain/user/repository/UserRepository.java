package com.pairing.buds.domain.user.repository;

import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.TagType;
import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

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

    @Query("SELECT u FROM User u WHERE u.id <> :senderId ORDER BY function('RAND') ")
    List<User> findRandomReceiver(@Param("senderId") Integer senderId, Pageable pageable);

    @Query("""
    SELECT DISTINCT u FROM User u\s
    JOIN u.tags t\s
    WHERE u.id <> :senderId\s
    AND t.tagName IN :senderTagTypes
    ORDER BY function('RAND')
   \s""")
    List<User> findRandomReceiverByTags(@Param("senderId") Integer senderId,
                                        @Param("senderTagTypes") List<TagType> senderTagTypes,
                                        Pageable pageable);
}
