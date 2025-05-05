package com.pairing.buds.domain.calendar.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.calendar.dto.request.DiaryReqDto;
import com.pairing.buds.domain.calendar.entity.Diary;
import com.pairing.buds.domain.calendar.entity.RecordType;
import com.pairing.buds.domain.calendar.repository.DiaryRepository;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
@Transactional
@RequiredArgsConstructor
public class DiaryService {
    private final DiaryRepository diaryRepository;
    private final UserRepository userRepository;

    /** 일기 저장 **/
    public void addDiary(Integer userId, DiaryReqDto diaryReqDto) {
        User user = userRepository.findById(userId).orElseThrow(()-> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));

        // 날짜 검증
        if (diaryReqDto.getDate() == null || diaryReqDto.getDate().trim().isEmpty()) {
            throw new ApiException(StatusCode.BAD_REQUEST, Message.DATE_IS_NOT_NULL);
        }

        // 활동 일기 저장
        if(diaryReqDto.getActive_diary() != null && !diaryReqDto.getActive_diary().trim().isEmpty()){
            Diary diary = Diary.builder()
                    .user(user)
                    .diaryType(RecordType.ACTIVE)
                    .content(diaryReqDto.getActive_diary())
                    .date(java.sql.Date.valueOf(LocalDate.parse(diaryReqDto.getDate())))
                    .build();

            diaryRepository.save(diary);
        }

        // 감정 일기 저장
        if(diaryReqDto.getEmotion_diary() != null && !diaryReqDto.getEmotion_diary().trim().isEmpty()){
            Diary diary = Diary.builder()
                    .user(user)
                    .diaryType(RecordType.EMOTION)
                    .content(diaryReqDto.getEmotion_diary())
                    .date(java.sql.Date.valueOf(LocalDate.parse(diaryReqDto.getDate())))
                    .build();

            diaryRepository.save(diary);
        }

    }

    /** 일기 삭제 **/
    public void deleteDiary(Integer userId, Integer diaryNo) {
        Diary diary = diaryRepository.findById(diaryNo).orElseThrow(()-> new ApiException(StatusCode.NOT_FOUND, Message.DIARY_NOT_FOUND));

        // 로그인한 유저와 일기를 작성한 유저가 다르면 예외 처리
        if(!diary.getUser().getId().equals(userId)){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_EQUAL);
        }

        diaryRepository.deleteById(diaryNo);
    }
}
