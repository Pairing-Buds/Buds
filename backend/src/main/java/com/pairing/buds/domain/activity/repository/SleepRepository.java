package com.pairing.buds.domain.activity.repository;

import com.pairing.buds.domain.activity.entity.Wake;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface SleepRepository extends JpaRepository<Wake, Integer> {

}
