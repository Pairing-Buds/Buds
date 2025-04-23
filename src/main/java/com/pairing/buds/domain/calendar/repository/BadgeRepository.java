package com.pairing.buds.domain.calendar.repository;

import com.pairing.buds.domain.calendar.entity.Badge;
import com.pairing.buds.domain.calendar.entity.Calendar;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface BadgeRepository extends JpaRepository<Badge, Integer> {
}
