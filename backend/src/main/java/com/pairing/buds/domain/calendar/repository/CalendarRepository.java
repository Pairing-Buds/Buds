package com.pairing.buds.domain.calendar.repository;

import com.pairing.buds.domain.calendar.entity.Calendar;
import com.pairing.buds.domain.user.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Repository
public interface CalendarRepository extends JpaRepository<Calendar, Integer> {
    // 특정 달의 캘린더(뱃지) 조회
    List<Calendar> findByUserAndDateBetween(User user, LocalDate start, LocalDate end);

    // 특정 날짜의 캘린더(뱃지) 조회
    List<Calendar> findByUserAndDate(User user, LocalDate date);
    
    // 특정 날짜 캘린더 조회
    Optional<Calendar> findByUser_idAndDate(int userId, LocalDate date);
}
