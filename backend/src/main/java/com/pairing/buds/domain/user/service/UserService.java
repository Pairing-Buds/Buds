package com.pairing.buds.domain.user.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.dto.request.SaveSurveyResultReqDto;
import com.pairing.buds.domain.user.dto.request.UpdateUserInfoReqDto;
import com.pairing.buds.domain.user.dto.request.WithdrawUserReqDto;
import com.pairing.buds.domain.user.dto.response.MyInfoResDto;
import com.pairing.buds.domain.user.dto.response.TagResDto;
import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.TagType;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    /** 사용자 태그 조회 **/
    @Transactional
    public List<TagResDto> getUserTags(Integer userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        return user.getTags().stream()
                .map(TagResDto::toTagRes)
                .collect(Collectors.toList());
    }

    /** 태그 업데이트(신규 저장 포함) **/
    @Transactional
    public void updateUserTags(Integer userId, List<TagType> selected) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        // 기존 태그 제거
        user.getTags().clear();

        // 새로 선택된 enum 목록 Tag 엔티티 생성·추가
        for (TagType type : selected) {
            Tag tag = new Tag();
            tag.setUser(user);
            tag.setTagName(type);
            user.getTags().add(tag);
        }

        userRepository.save(user);
    }

    /** 전체 태그 조회 **/
    public String[] getAllTags(int userId) {
        return new String[]{"취업", "자격증", "운동", "패션", "음악", "독서", "요리", "게임", "만화"};
    }

    /** 설문조사 결과 저장 **/
    public void saveSurveyResult(int userId, SaveSurveyResultReqDto dto) {
        int seclusionScore = dto.getSeclusionScore();
        int opennessScore = dto.getOpennessScore();
        int routineScore = dto.getRoutineScore();
        int sociabilityScore = dto.getSociabilityScore();
        int quietnessScore = dto.getQuietnessScore();
        int expressionScore = dto.getExpressionScore();
        log.info("userId : {}, opennessScore : {}, routineScore : {}, quitenessScore : {}, expressionScore : {}, seclusionScore : {}, sociabilityScore",
                userId, opennessScore, routineScore, quietnessScore, expressionScore, seclusionScore, sociabilityScore);
        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        User updatedUser = SaveSurveyResultReqDto.toUser(user, dto);
        userRepository.save(updatedUser);
    }

    /** 내 정보 조회 **/
    public MyInfoResDto getMyInfo(Integer userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        return MyInfoResDto.toMyInfoRes(user);
    }

    /** 회원 수정 **/
    @Transactional
    public void updateUserInfo(Integer userId, UpdateUserInfoReqDto dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        user.setUserCharacter(dto.getUserCharacter());
        userRepository.save(user);
    }

    /** 회원 탈퇴 */
    @Transactional
    public void withdrawUser(Integer userId, WithdrawUserReqDto dto) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        // 입력 비밀번호 검증
        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new ApiException(StatusCode.BAD_REQUEST, Message.PASSWORD_NOT_MATCHED);
        }

        // 탈퇴 처리 (소프트 삭제)
        user.setIsActive(false);
        userRepository.save(user);
    }

}
