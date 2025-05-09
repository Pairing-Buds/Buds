package com.pairing.buds.domain.user.service;

import com.pairing.buds.common.auth.service.RedisService;
import com.pairing.buds.common.auth.utils.JwtTokenProvider;
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
import com.pairing.buds.domain.user.entity.UserCharacter;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.authentication.logout.CookieClearingLogoutHandler;
import org.springframework.security.web.authentication.logout.SecurityContextLogoutHandler;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@Slf4j
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final RedisService redisService;

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
        return new String[]{"취업", "자격증", "운동", "패션", "음악", "독서", "요리", "게임", "만화","영화"};
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

        Set<Tag> newTags = dto.getTags().parallelStream().map( newTag ->
                Tag.builder()
                        .user(user)
                        .tagName(newTag)
                        .build()
        ).collect(Collectors.toSet());

        User userToUpdate = SaveSurveyResultReqDto.toUser(user, dto);
        userToUpdate.getTags().addAll(newTags);
        userRepository.save(userToUpdate);
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

        String desc = dto.getUserCharacter();
        if (desc != null && !desc.isBlank()) {
            UserCharacter character;
            try {
                // 한글(description) → Enum 변환
                character = UserCharacter.fromDescription(desc);
            } catch (IllegalArgumentException e) {
                throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
            }
            user.setUserCharacter(character);
        }

        userRepository.save(user);
    }

    /** 회원 탈퇴 */
    @Transactional
    public void withdrawUser(
            Integer userId,
            WithdrawUserReqDto dto,
            HttpServletRequest request,
            HttpServletResponse response,
            Authentication authentication
    ) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        // 이미 완료된 탈퇴 계정 검증
        if (!user.getIsActive()) {
            throw new ApiException(StatusCode.BAD_REQUEST, Message.USER_ALREADY_DELETED);
        }
        // 입력 비밀번호 검증
        if (!passwordEncoder.matches(dto.getPassword(), user.getPassword())) {
            throw new ApiException(StatusCode.BAD_REQUEST, Message.PASSWORD_NOT_MATCHED);
        }

        // 탈퇴 처리 (소프트 삭제)
        user.setIsActive(false);
        userRepository.save(user);

        // 쿠키 삭제
        new CookieClearingLogoutHandler("access_token", "refresh_token")
                .logout(request, response, authentication);

        // 세션 무효화 & SecurityContext 비우기
        new SecurityContextLogoutHandler()
                .logout(request, response, authentication);

        // Redis 에 저장된 리프레시 토큰 삭제
        String refreshToken = jwtTokenProvider.extractCookie(request, "refresh_token");
        if (refreshToken != null && jwtTokenProvider.validateToken(refreshToken)) {
            Integer rtUserId = jwtTokenProvider.getUserId(refreshToken);
            redisService.deleteRefreshToken(rtUserId);
        }
    }

}
