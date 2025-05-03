package com.pairing.buds.domain.activity.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Common;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.activity.dto.req.*;
import com.pairing.buds.domain.activity.dto.res.FindFriendByTagResDto;
import com.pairing.buds.domain.activity.entity.*;
import com.pairing.buds.domain.activity.repository.ActivityRepository;
import com.pairing.buds.domain.activity.repository.SleepRepository;
import com.pairing.buds.domain.activity.repository.UserActivityRepository;
import com.pairing.buds.domain.letter.entity.Letter;
import com.pairing.buds.domain.user.dto.response.UserDto;
import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;

@Service
@RequiredArgsConstructor
@Slf4j
public class ActivityService {

    private final ActivityRepository activityRepository;
    private final UserRepository userRepository;
    private final SleepRepository sleepRepository;
    private final UserActivityRepository userActivityRepository;

    /** 기상 시간 등록 **/
    @Transactional
    public void createWakeTime(int userId , @Valid CreateWakeTimeReqDto dto) {

        String wakeTime = dto.getWakeTime();
        log.info("wakeTime : {}, userId : {}", wakeTime, userId);

        // 유저 유무 조회
        User userToSave = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));

        // 저장
        Wake newSleep = Wake.builder()
                .user(userToSave)
                .wakeTime(wakeTime)
                .build();
        sleepRepository.save(newSleep);
    }
    /** 최초 페이지 방문 리워드 **/
    @Transactional
    public void firstVisitReward(int userId, FirstVisitRewardReqDto dto) {

        PageName pageName = dto.getPageName();
        log.info("userId : {}, pageName : {}", userId, pageName);

        if(!activityRepository.isVisited(userId, pageName)){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }

        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        user.setLetterCnt(user.getLetterCnt() + 3);
    }
    /** 기상 시간 인증 **/
    @Transactional
    public void wakeVerify(int userId) {
        LocalDate today = LocalDate.now();
        LocalDateTime start = today.atStartOfDay();
        LocalDateTime end   = today.plusDays(1).atStartOfDay();
        // 유저 조회
        User user = userRepository.findById(userId)
                .orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        // 검증
        if(userActivityRepository.existsByUserIdAndActivity_NameAndCreatedAtBetween(userId, ActivityType.WAKE, start, end)){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ALREADY_VERIFIED);
        }
        user.setLetterCnt(user.getLetterCnt() + 3);
        // 활동, 유저 활동 생성
        Activity activity = WakeVerifyReqDto.toActivity(user);
        UserActivity userActivity = new UserActivity();
        userActivity.setUser(user);
        userActivity.setActivity(activity);
        userActivity.setStatus(UserActivityStatus.DONE);
        userActivity.setProof("인증 완료");
        // 저장
        userRepository.save(user);
        log.info("유저 리워드 편지 3개 추가 저장");
        activityRepository.save(activity);
        log.info("Activity 저장");
        userActivityRepository.save(userActivity);
        log.info("userActivity 저장");
    }
    /** 사용자 음성 활동 인증 **/
    @Transactional
    public void activitySentenceVoice(int userId, ActivitySentenceVoiceReqDto dto) {
        String originalSentenceText = dto.getOriginalSentenceText() != null? dto.getOriginalSentenceText().trim() : "";
        String userSentence = dto.getUserSentenceText() != null? dto.getUserSentenceText().trim() : "";
        log.info("originalSentenceText : {}, userSentence : {}", originalSentenceText, userSentence);

        if(originalSentenceText.isEmpty() || userSentence.isEmpty() || !originalSentenceText.equalsIgnoreCase(userSentence)   ){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }
        Activity activity = new Activity();
        activity.setName(ActivityType.VOICE_TEXT);
        activity.setDescription("사용자 음성 텍스트 활동 인증");
        activity.setBonusLetter(3);
        log.info("활동 생성 완료");

        Activity createdActivity = activityRepository.save(activity);

        // 유저 정보가 필요하므로 조회
        User user = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        user.setLetterCnt(user.getLetterCnt() + 3);

        UserActivity userActivity = new UserActivity();
        userActivity.setUser(user);
        userActivity.setActivity(createdActivity);
        userActivity.setStatus(UserActivityStatus.DONE);
        userActivity.setProof(userSentence);

        userRepository.save(user);
        log.info("유저 리워드 편지 3개 추가 저장 완료");
        userActivityRepository.save(userActivity);
        log.info("사용자 활동 생성 완료");


    }
//    /** 사용자 필사 활동 인증 **/
//    @Transactional
//    public void activitySentenceText(int userId, ActivitySentenceVoiceReqDto dto) {
//        String originalSentenceText = dto.getOriginalSentenceText() != null? dto.getOriginalSentenceText().trim() : "";
//        String userSentence = dto.getUserSentenceText() != null? dto.getUserSentenceText().trim() : "";
//        log.info("originalSentenceText : {}, userSentence : {}", originalSentenceText, userSentence);
//
//        if(originalSentenceText.isEmpty() || userSentence.isEmpty() || !originalSentenceText.equalsIgnoreCase(userSentence)   ){
//            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
//        }
//        Activity activity = new Activity();
//        activity.setName(ActivityType.TEXT);
//        activity.setDescription("사용자 필사 활동 인증");
//        activity.setBonusLetter(3);
//        log.info("활동 생성 완료");
//
//        Activity createdActivity = activityRepository.save(activity);
//
//        // 유저 정보가 필요하므로 조회
//        User user = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
//        user.setLetterCnt(user.getLetterCnt() + 3);
//
//        UserActivity userActivity = new UserActivity();
//        userActivity.setUser(user);
//        userActivity.setActivity(createdActivity);
//        userActivity.setStatus(UserActivityStatus.DONE);
//        userActivity.setProof(userSentence);
//
//        userRepository.save(user);
//        log.info("유저 리워드 편지 3개 추가 저장 완료");
//        userActivityRepository.save(userActivity);
//        log.info("사용자 활동 생성 완료");
//    }
    /** 만보기 리워드 신청 **/
    @Transactional
    public void walkRewardReq(int userId, WalkRewardReqDto dto) {
        // 변수
        int userStepSet = dto.getUserStepSet();
        int userRealStep = dto.getUserRealStep();
        log.info("userStepSet : {}, userRealStep : {}", userStepSet, userRealStep);
        // 검증
        if(userStepSet > userRealStep){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }
        // 유저 조회
        User user = userRepository.findById(userId)
                .orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        user.setLetterCnt(user.getLetterCnt() + 3);
        // 활동, 유저 활동 생성
        Activity activity = WalkRewardReqDto.toActivity(user, dto);
        UserActivity userActivity = UserActivity.builder()
                .user(user)
                .activity(activity)
                .status(UserActivityStatus.DONE)
                .proof("인증 완료")
                .build();
        // 저장
        userRepository.save(user);
        log.info("유저 리워드 편지 3개 추가 저장");
        activityRepository.save(activity);
        log.info("Activity 저장");
        userActivityRepository.save(userActivity);
        log.info("userActivity 저장");
    }

    /** 기상 시간 수정 **/
    @Transactional
    public void updateWakeTime(int userId, @Valid UpdateWakeTimeReqDto dto) {

        int wakeId = dto.getWakeId();
        String wakeTime = dto.getWakeTime();
        log.info("sleepId : {}, wakeTime : {}, userId : {}", wakeId, wakeTime, userId);
        
        // user, sleep 유무 검증
        User user = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Wake wakeToUpdate = sleepRepository.findById(wakeId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.SLEEP_NOT_FOUND));

        int userIdOfWakeToUpdate = wakeToUpdate.getUser().getId();
        log.info("userId : {}, userIdOfWakeToUpdate : {}", userId, userIdOfWakeToUpdate);
        
        // sleep의 유저와 식별자 비교
        if(userId != userIdOfWakeToUpdate){
            log.info("userId, userIdOfSleepToUpdate Not Match");
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }
        
        // 저장
        wakeToUpdate.setWakeTime(wakeTime);
        sleepRepository.save(wakeToUpdate);
    }
    
    /** 기상 시간 삭제 **/
    @Transactional
    public void deleteWakeTime(int userId, @Valid DeleteWakeTimeReqDto dto) {

        int wakeId = dto.getWakeId();
        log.info("wakeId : {}, userId : {}", wakeId, userId);

        // exists...
        User user = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Wake wakeToDelete = sleepRepository.findById(wakeId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.SLEEP_NOT_FOUND));

        int userIdOfWakeToDelete = wakeToDelete.getUser().getId();
        log.info("userId : {}, userIdOfWakeToDelete : {}", userId, userIdOfWakeToDelete);

        if(userId != userIdOfWakeToDelete){
            log.info("userId, userIdOfSleepToDelete Not Match");
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }

        // DB에 데이터 부재 시 OptimisticLockingFailureException 발생
        sleepRepository.delete(wakeToDelete);
    }

    /** 추천 장소 방문 리워드 **/
    @Transactional
    public void visitRecommendedPlaceReward(int userId) {
        // 변수
        log.info("userId : {}", userId);
        User user = userRepository.findById(userId).orElseThrow(()-> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        
        // 활동
        Activity activity = new Activity();
        activity.setName(ActivityType.VISIT_PLACE);
        activity.setDescription("추천 장소 방문 활동");
        activity.setBonusLetter(3);
        
        // 유저 활동
        UserActivity userActivity = new UserActivity();
        userActivity.setUser(user);
        userActivity.setActivity(activity);
        userActivity.setStatus(UserActivityStatus.DONE);
        userActivity.setProof("추천 장소 방문 활동 인증 완료");
        

        activityRepository.save(activity);
        log.info("활동 저장 완료");
        userActivityRepository.save(userActivity);
        log.info("유저 활동 저장 완료");

        // 유저 리워드 편지 3개 추가
        user.setLetterCnt(user.getLetterCnt() + 3);
        log.info("유저 리워드 편지 3개 증정 완료");
    }   
        
    /** 취향이 맞는 친구 찾기 **/
    public Set<UserDto> findFriendByTag(int userId) {
        // 변수
        log.info("userId : {}", userId);
        // 유저 및 태그 조회
        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Set<Tag> userTags = user.getTags();
        // 취향 맞는 추천 친구 조회
        Set<User> recommendedUsers = userRepository.findDistinctTop10ByIdNotAndIsActiveTrueAndTagsIn(userId, userTags);
        // 사용자 태그 수집
        // 유저가 아닌 다른 사람만
        // IN으로 사용자 태그 리스트 안에 있는 것 수집
        // 활성화된 사용자만
        // 10개만 수집
        // 랜덤은 parallel 메소드로 순서 보장 하지 않음
        Set<UserDto> responseDto = FindFriendByTagResDto.toDto(recommendedUsers); // Set<User> users
        return responseDto;
    }
}
