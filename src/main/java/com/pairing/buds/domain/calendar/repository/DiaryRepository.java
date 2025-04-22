package com.pairing.buds.domain.calendar.repository;

import com.pairing.buds.domain.calendar.entity.Diary;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface DiaryRepository extends JpaRepository<Diary, Integer> {
}
