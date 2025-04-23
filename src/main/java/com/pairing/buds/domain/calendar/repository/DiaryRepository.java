package com.pairing.buds.domain.calendar.repository;

import com.pairing.buds.domain.calendar.entity.Diary;
import com.pairing.buds.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Date;
import java.util.List;

@Repository
public interface DiaryRepository extends JpaRepository<Diary, Integer> {
    // 특정 날짜의 일기 조회
    List<Diary> findByUserAndDate(User user, Date date);

    // 특정 달(yyyy-MM) 범위의 일기 조회 (필요시)
    List<Diary> findByUserAndDateBetween(User user, Date start, Date end);

}
