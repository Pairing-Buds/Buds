package com.pairing.buds.domain.activity.repository;

import com.pairing.buds.domain.activity.entity.Wake;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface WakeRepository extends JpaRepository<Wake, Integer> {

    boolean existsByUser_id(int userId);
}
