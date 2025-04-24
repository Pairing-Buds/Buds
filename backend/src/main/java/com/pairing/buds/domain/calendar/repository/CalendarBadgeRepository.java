package com.pairing.buds.domain.calendar.repository;

import com.pairing.buds.domain.calendar.entity.Calendar;
import com.pairing.buds.domain.calendar.entity.CalendarBadge;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
@Repository
public interface CalendarBadgeRepository  extends JpaRepository<CalendarBadge, Integer> {

    /** 캘린더 ID 리스트로 연관된 CalendarBadge 조회 (N+1 문제 방지를 위한 페치 조인) **/
    @Query("SELECT cb FROM CalendarBadge cb JOIN FETCH cb.badge WHERE cb.id.calendarId IN :calendarIds")
    List<CalendarBadge> findByCalendarIdsWithBadge(@Param("calendarIds") List<Integer> calendarIds);

    List<CalendarBadge> findByCalendarIdIn(List<Integer> calendarIds);
}
