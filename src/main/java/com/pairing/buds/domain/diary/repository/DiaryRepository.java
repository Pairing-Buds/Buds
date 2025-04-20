package com.pairing.buds.domain.diary.repository;

import com.pairing.buds.domain.diary.entity.Diary;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DiaryRepository extends JpaRepository<Diary, Integer> {
}
