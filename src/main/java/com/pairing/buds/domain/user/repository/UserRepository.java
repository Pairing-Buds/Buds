package com.pairing.buds.domain.user.repository;

import com.pairing.buds.domain.user.entity.User;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    @Query(value = "SELECT user_id FROM users WHERE user_name = :username", nativeQuery = true)
    User findByUserName(@Param("username") String username);
}
