package com.pairing.buds.domain.user.repository;

import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotNull;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Integer> {

    Optional<User> findByUserEmail(String email);

    boolean existsByUserEmail(@Email @NotNull String userEmail);

    boolean existsByUserName(String username);
}
