package com.pairing.buds.domain.user.repository;

import com.pairing.buds.domain.user.entity.RandomName;
import com.pairing.buds.domain.user.entity.RandomNameStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface RandomNameRepository extends JpaRepository<RandomName, Integer> {

    @Query("SELECT rn FROM RandomName rn WHERE rn.status = :status ORDER BY function('RAND') LIMIT 1")
    Optional<RandomName> findRandomNameByStatus(@Param("status") RandomNameStatus status);

    Optional<RandomName> findByRandomName(String userName);

}