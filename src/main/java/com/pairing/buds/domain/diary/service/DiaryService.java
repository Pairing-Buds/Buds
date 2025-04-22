package com.pairing.buds.domain.diary.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.diary.dto.request.DiaryReqDto;
import com.pairing.buds.domain.diary.entity.Diary;
import com.pairing.buds.domain.diary.repository.DiaryRepository;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import com.pairing.buds.domain.user.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class DiaryService {
    private final DiaryRepository diaryRepository;
    private final UserRepository userRepository;

    public void addDiary(Integer userId, DiaryReqDto diaryReqDto) {
        User user = userRepository.findById(userId).orElseThrow(()-> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));

        Diary diary = Diary.builder()
                .user(user)
                .content(diaryReqDto.getContent())
                .build();

        diaryRepository.save(diary);
    }
}
