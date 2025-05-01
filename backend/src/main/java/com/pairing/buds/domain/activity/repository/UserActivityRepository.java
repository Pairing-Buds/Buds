package com.pairing.buds.domain.activity.repository;

import com.pairing.buds.domain.activity.entity.ActivityType;
import com.pairing.buds.domain.activity.entity.UserActivity;
import com.pairing.buds.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;

@Repository
public interface UserActivityRepository extends JpaRepository<UserActivity, Integer> {

    boolean existsByUserIdAndActivity_NameAndCreatedAtBetween(
            Integer userId,
            ActivityType name,
            LocalDateTime startOfDay,
            LocalDateTime endOfDay
    );
}
