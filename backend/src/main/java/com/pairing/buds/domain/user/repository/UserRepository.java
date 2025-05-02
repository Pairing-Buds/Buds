package com.pairing.buds.domain.user.repository;

import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

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
}
