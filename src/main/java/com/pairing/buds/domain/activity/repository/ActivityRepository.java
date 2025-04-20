package com.pairing.buds.domain.activity.repository;

import com.pairing.buds.domain.activity.entity.Activity;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ActivityRepository extends JpaRepository<Activity, Integer> {
}
