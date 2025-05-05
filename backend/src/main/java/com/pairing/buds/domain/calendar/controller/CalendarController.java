package com.pairing.buds.domain.calendar.controller;

import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.calendar.dto.request.DiaryReqDto;
import com.pairing.buds.domain.calendar.service.CalendarService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/calendars")
public class CalendarController {

    private final CalendarService calendarService;

    /** 달별 뱃지 조회 **/
    @GetMapping("/{date}")
    public ResponseDto getBadgeByCalendar(
            @AuthenticationPrincipal Integer userId,
            @PathVariable String date
    ) {
        return new ResponseDto(StatusCode.OK, calendarService.getBadgeByCalendar(userId, date));
    }

    /** 일별 뱃지, 일기 조회 **/
    @GetMapping("/day/{date}")
    public ResponseDto getBadgesAndDiary(
            @AuthenticationPrincipal Integer userId,
            @PathVariable String date
    ) {
        return new ResponseDto(StatusCode.OK, calendarService.getBadgesAndDiary(userId, date));
    }

}

