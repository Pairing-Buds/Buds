package com.pairing.buds.domain.calendar.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.calendar.dto.response.BadgeAndDiaryResDto;
import com.pairing.buds.domain.calendar.dto.response.BadgeResDto;
import com.pairing.buds.domain.calendar.dto.response.CalendarBadgeResDto;
import com.pairing.buds.domain.calendar.dto.response.DiaryResDto;
import com.pairing.buds.domain.calendar.entity.Calendar;
import com.pairing.buds.domain.calendar.entity.CalendarBadge;
import com.pairing.buds.domain.calendar.entity.Diary;
import com.pairing.buds.domain.calendar.repository.BadgeRepository;
import com.pairing.buds.domain.calendar.repository.CalendarBadgeRepository;
import com.pairing.buds.domain.calendar.repository.CalendarRepository;
import com.pairing.buds.domain.calendar.repository.DiaryRepository;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class CalendarService {
    private final DiaryRepository diaryRepository;
    private final UserRepository userRepository;
    private final CalendarRepository calendarRepository;
    private final CalendarBadgeRepository calendarBadgeRepository;

    /** 달별 뱃지 조회 **/
    public List<CalendarBadgeResDto> getBadgeByCalendar(int userId, String date){
        User user = userRepository.findById(userId).orElseThrow(()-> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));

        // date는 "yyyy-MM" 의 형태
        LocalDate start = LocalDate.parse(date + "-01", DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        LocalDate end = start.withDayOfMonth(start.lengthOfMonth());

        List<Calendar> calendars = calendarRepository.findByUserAndDateBetween(user, start, end);

        // CalendarBadgeResDto로 변환
        return calendars.stream()
                .map(calendar -> CalendarBadgeResDto.builder()
                        .date(calendar.getDate().toString())
                        .badge(calendar.getBadge()) /** 2025.05.15 15:58 CalendarBadgeResDto의 badge 필드를 BadgeType에서 String으로 변경 **/
                        .build())
                .collect(Collectors.toList());
    }

    /** 일별 뱃지, 일기 조회 **/
    public List<BadgeAndDiaryResDto> getBadgesAndDiary(int userId, String date) {
        User user = userRepository.findById(userId).orElseThrow(()-> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));

        // 1. 달 범위 계산 (date = "yyyy-MM")
        LocalDate startDate = LocalDate.parse(date + "-01", DateTimeFormatter.ofPattern("yyyy-MM-dd"));
        LocalDate endDate = startDate.withDayOfMonth(startDate.lengthOfMonth());

        // 2. 달 범위 내의 모든 Calendar 엔티티 조회
        List<Calendar> calendars = calendarRepository.findByUserAndDateBetween(user, startDate, endDate);

        // 3. 해당 달의 모든 CalendarBadge 조회 (calendar_id in ...)
        List<Integer> calendarIds = calendars.stream().map(Calendar::getId).collect(Collectors.toList());
        List<CalendarBadge> calendarBadges = calendarIds.isEmpty() ?
                Collections.emptyList() :
                calendarBadgeRepository.findByCalendarIdIn(calendarIds);

        // 4. 해당 달의 모든 Diary 조회
        Date start = java.sql.Date.valueOf(startDate);
        Date end = java.sql.Date.valueOf(endDate);
        List<Diary> diaries = diaryRepository.findByUserAndDateBetween(user, start, end);

        // 5. 날짜별로 그룹화
        Map<LocalDate, List<CalendarBadge>> badgeMap = calendarBadges.stream()
                .collect(Collectors.groupingBy(cb -> cb.getCalendar().getDate()));
        Map<LocalDate, List<Diary>> diaryMap = diaries.stream()
                .collect(Collectors.groupingBy(
                        d -> d.getDate().toInstant().atZone(ZoneId.systemDefault()).toLocalDate()
                ));

        // 6. 날짜별로 BadgeAndDiaryResDto 생성
        List<BadgeAndDiaryResDto> result = new ArrayList<>();
        for (LocalDate day = startDate; !day.isAfter(endDate); day = day.plusDays(1)) {
            List<BadgeResDto> badgeList = badgeMap.getOrDefault(day, Collections.emptyList())
                    .stream()
                    .map(cb -> BadgeResDto.builder()
                            .badgeType(cb.getBadge().getBadgeType())  /** 2025.05.15 15:57 .getName이 불필요하게 되어 삭제 **/
                            .badge(cb.getBadge().getName())
                            .build())
                    .collect(Collectors.toList());

            // 각 일기에 대해 일기 ID와 함께 DTO 생성
            List<DiaryResDto> diaryList = diaryMap.getOrDefault(day, Collections.emptyList())
                    .stream()
                    .map(diary -> DiaryResDto.builder()
                            .diaryNo(diary.getId())
                            .emotionDiary(diary.getEmotion_diary())
                            .activeDiary(diary.getActive_diary())
                            .build())
                    .collect(Collectors.toList());

            result.add(BadgeAndDiaryResDto.builder()
                    .date(day.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")))
                    .badgeList(badgeList)
                    .diaryList(diaryList)
                    .build());
        }

        return result;
    }
}