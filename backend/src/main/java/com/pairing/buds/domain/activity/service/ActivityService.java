package com.pairing.buds.domain.activity.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.activity.dto.request.*;
import com.pairing.buds.domain.activity.dto.response.FindFriendByTagResDto;
import com.pairing.buds.domain.activity.dto.response.GetQuoteByRandomResDto;
import com.pairing.buds.domain.activity.entity.*;
import com.pairing.buds.domain.activity.repository.ActivityRepository;
import com.pairing.buds.domain.activity.repository.QuoteRepository;
import com.pairing.buds.domain.activity.repository.WakeRepository;
import com.pairing.buds.domain.activity.repository.UserActivityRepository;
import com.pairing.buds.domain.calendar.entity.*;
import com.pairing.buds.domain.calendar.repository.BadgeRepository;
import com.pairing.buds.domain.calendar.repository.CalendarBadgeRepository;
import com.pairing.buds.domain.calendar.repository.CalendarRepository;
import com.pairing.buds.domain.user.dto.response.UserDto;
import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.TagType;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class ActivityService {

    private final ActivityRepository activityRepository;
    private final UserRepository userRepository;
    private final WakeRepository wakeRepository;
    private final UserActivityRepository userActivityRepository;
    private final QuoteRepository quoteRepository;
    private final CalendarRepository calendarRepository;
    private final BadgeRepository badgeRepository;
    private final CalendarBadgeRepository calendarBadgeRepository;

    /** 기상 시간 등록 **/
    @Transactional
    public void createWakeTime(int userId , @Valid CreateWakeTimeReqDto dto) {
        String wakeTime = dto.getWakeTime();
        // 유저 유무 조회
        User userToSave = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        // 기상 시간 중복 등록 방지        
//        if(wakeRepository.existsByUser_id(userId)){
//            throw new ApiException(StatusCode.NOT_FOUND, Message.ARGUMENT_NOT_PROPER);
//        }
        // Wake 빌드
        Wake newSleep = Wake.builder()
                .user(userToSave)
                .wakeTime(wakeTime)
                .build();
        // 저장
        wakeRepository.save(newSleep);
    }
    /** 최초 페이지 방문 리워드 **/
    @Transactional
    public void firstVisitReward(int userId, FirstVisitRewardReqDto dto) {

        PageName pageName = dto.getPageName();

        if(!activityRepository.isVisited(userId, pageName)){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }

        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        user.setLetterCnt(user.getLetterCnt() + 3);
    }
    /** 기상 시간 인증 **/
    @Transactional
    public void wakeVerify(int userId) {

        // 유저 조회
        User user = userRepository.findById(userId)
                .orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));

        user.setLetterCnt(user.getLetterCnt() + 3);
        // 활동, 유저 활동 생성
        Activity activity = WakeVerifyReqDto.toActivity(user);
        UserActivity userActivity = new UserActivity();
        userActivity.setUser(user);
        userActivity.setActivity(activity);
        userActivity.setStatus(UserActivityStatus.DONE);
        userActivity.setProof("인증 완료");

        LocalDate today = LocalDate.now();
        LocalDateTime start = today.atStartOfDay();
        LocalDateTime end   = today.plusDays(1).atStartOfDay();
        // 검증
        if(userActivityRepository.existsByUserIdAndActivity_NameAndCreatedAtBetween(userId, ActivityType.WAKE, start, end)){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ALREADY_VERIFIED);
        }

        // 뱃지 생성
        Badge badge = new Badge();
        badge.setBadgeType(RecordType.ACTIVE);
        badge.setName(BadgeType.WAKE);
        Badge createdBadge = badgeRepository.save(badge);

        // 캘린더와 연동
        // 오늘자 캘린더 불러오기
        // id값으로 연동하기
        LocalDate date = LocalDate.now();
        Calendar calendar = calendarRepository.findByUser_idAndDate(userId, date).orElse(new Calendar(user, createdBadge.getName(), date));
        CalendarBadge calendarBadge = new CalendarBadge();
        calendarBadge.setId(new CalendarBadgeId());
        calendarBadge.setBadge(badge);
        calendarBadge.setCalendar(calendar);

        userRepository.save(user);
        activityRepository.save(activity);
        userActivityRepository.save(userActivity);
        calendarRepository.save(calendar);
        calendarBadgeRepository.save(calendarBadge);
    }
    /** 사용자 음성 활동 인증 **/
    @Transactional
    public void activitySentenceVoice(int userId, ActivitySentenceVoiceReqDto dto) {
        String originalSentenceText = dto.getOriginalSentenceText().replaceAll("[ !@#$%^&*()_+=,.?/|-]", "");
        String userSentence = dto.getUserSentenceText().replaceAll("[ !@#$%^&*()_+=,.?/|-]", "");

        if(originalSentenceText.isEmpty() || userSentence.isEmpty() || !originalSentenceText.equalsIgnoreCase(userSentence)   ){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }


        Activity activity = new Activity();
        activity.setName(ActivityType.VOICE_TEXT);
        activity.setDescription("사용자 음성 텍스트 활동 인증");
        activity.setBonusLetter(3);

        LocalDate today = LocalDate.now();
        LocalDateTime start = today.atStartOfDay();
        LocalDateTime end   = today.plusDays(1).atStartOfDay();
        // 검증
        if(userActivityRepository.existsByUserIdAndActivity_NameAndCreatedAtBetween(userId, activity.getName(), start, end)){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ALREADY_VERIFIED);
        }

        Activity createdActivity = activityRepository.save(activity);

        // 유저 정보가 필요하므로 조회
        User user = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        user.setLetterCnt(user.getLetterCnt() + 3);

        UserActivity userActivity = new UserActivity();
        userActivity.setUser(user);
        userActivity.setActivity(createdActivity);
        userActivity.setStatus(UserActivityStatus.DONE);
        userActivity.setProof(userSentence);

        // 뱃지 생성
        Badge badge = new Badge();
        badge.setBadgeType(RecordType.ACTIVE);
        badge.setName(BadgeType.VOICE_TEXT);
        Badge createdBadge = badgeRepository.save(badge);

        // 캘린더와 연동
        LocalDate date = LocalDate.now();
        Calendar calendar = calendarRepository.findByUser_idAndDate(userId, date).orElse(new Calendar(user, createdBadge.getName(), date));
        CalendarBadge calendarBadge = new CalendarBadge();
        calendarBadge.setId(new CalendarBadgeId());
        calendarBadge.setBadge(badge);
        calendarBadge.setCalendar(calendar);

        userRepository.save(user);
        userActivityRepository.save(userActivity);
        calendarRepository.save(calendar);
        userActivityRepository.save(userActivity);
        calendarBadgeRepository.save(calendarBadge);


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
        // 검증
        LocalDate today = LocalDate.now();
        LocalDateTime start = today.atStartOfDay();
        LocalDateTime end   = today.plusDays(1).atStartOfDay();
        // 검증
        if(userActivityRepository.existsByUserIdAndActivity_NameAndCreatedAtBetween(userId, activity.getName(), start, end)){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ALREADY_VERIFIED);
        }
        
        // 뱃지 생성
        Badge badge = new Badge();
        badge.setBadgeType(RecordType.ACTIVE);
        // 뱃지 종류 저장, 만보기 1000, 3000, 5000, 10000
        if(userStepSet == 1000){
            badge.setName(BadgeType.WALK1000);
        }else if(userStepSet == 3000){
            badge.setName(BadgeType.WALK3000);
        }else if(userStepSet == 5000){
            badge.setName(BadgeType.WALK5000);
        }else if(userStepSet == 10000){
            badge.setName(BadgeType.WALK10000);
        }else{
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }
        Badge createdBadge = badgeRepository.save(badge);
        // 캘린더와 연동
        LocalDate date = LocalDate.now();
        Calendar calendar = calendarRepository.findByUser_idAndDate(userId, date).orElse(new Calendar(user, createdBadge.getName(), date));
        CalendarBadge calendarBadge = new CalendarBadge();
        calendarBadge.setId(new CalendarBadgeId());
        calendarBadge.setBadge(badge);
        calendarBadge.setCalendar(calendar);

        // 저장
        userRepository.save(user);
        activityRepository.save(activity);
        userActivityRepository.save(userActivity);
        calendarRepository.save(calendar);
        calendarBadgeRepository.save(calendarBadge);
    }

    /** 기상 시간 수정 **/
    @Transactional
    public void updateWakeTime(int userId, @Valid UpdateWakeTimeReqDto dto) {

        int wakeId = dto.getWakeId();
        String wakeTime = dto.getWakeTime();

        // user, sleep 유무 검증
        User user = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Wake wakeToUpdate = wakeRepository.findById(wakeId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.SLEEP_NOT_FOUND));

        int userIdOfWakeToUpdate = wakeToUpdate.getUser().getId();

        // sleep의 유저와 식별자 비교
        if(userId != userIdOfWakeToUpdate){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }
        
        // 저장
        wakeToUpdate.setWakeTime(wakeTime);
        wakeRepository.save(wakeToUpdate);
    }
    
    /** 기상 시간 삭제 **/
    @Transactional
    public void deleteWakeTime(int userId, @Valid DeleteWakeTimeReqDto dto) {

        int wakeId = dto.getWakeId();

        // exists...
        User user = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Wake wakeToDelete = wakeRepository.findById(wakeId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.SLEEP_NOT_FOUND));

        int userIdOfWakeToDelete = wakeToDelete.getUser().getId();

        if(userId != userIdOfWakeToDelete){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }

        // DB에 데이터 부재 시 OptimisticLockingFailureException 발생
        wakeRepository.delete(wakeToDelete);
    }

    /** 추천 장소 방문 리워드 **/
    @Transactional
    public void visitRecommendedPlaceReward(int userId) {
        // 변수
        User user = userRepository.findById(userId).orElseThrow(()-> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));

        // 활동
        Activity activity = new Activity();
        activity.setName(ActivityType.VISIT_PLACE);
        activity.setDescription("추천 장소 방문 활동");
        activity.setBonusLetter(3);

        LocalDate today = LocalDate.now();
        LocalDateTime start = today.atStartOfDay();
        LocalDateTime end   = today.plusDays(1).atStartOfDay();
        // 검증
        if(userActivityRepository.existsByUserIdAndActivity_NameAndCreatedAtBetween(userId, activity.getName(), start, end)){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ALREADY_VERIFIED);
        }
        
        // 유저 활동
        UserActivity userActivity = new UserActivity();
        userActivity.setUser(user);
        userActivity.setActivity(activity);
        userActivity.setStatus(UserActivityStatus.DONE);
        userActivity.setProof("추천 장소 방문 활동 인증 완료");

        activityRepository.save(activity);
        userActivityRepository.save(userActivity);

        // 유저 리워드 편지 3개 추가
        user.setLetterCnt(user.getLetterCnt() + 3);
    }

    /** 취향이 맞는 친구 찾기 **/
    public Set<UserDto> findFriendByTag(int userId, int opponentId) {
        // 변수
        // 유저 및 태그 조회
        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Set<Tag> userTags = user.getTags();
        Set<TagType> userTagsType = userTags.stream().map(Tag::getTagType).collect(Collectors.toSet());
        // 취향 맞는 추천 친구 조회
        Set<User> recommendedUsers = userRepository.findTOP10RecommendedUser(userId, opponentId, userTagsType);
        // 사용자 태그 수집
        // 유저가 아닌 다른 사람만
        // IN으로 사용자 태그 리스트 안에 있는 것 수집
        // 활성화된 사용자만
        // 10개만 수집
        // 랜덤은 parallel 메소드로 순서 보장 하지 않음
        return FindFriendByTagResDto.toDto(recommendedUsers);
    }

    /** 명언 랜덤 조회 **/
    public GetQuoteByRandomResDto getQuoteByRandom(int userId) {
        // 명언 랜덤 조회
        Quote quote = activityRepository.getQuoteByRandom().orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.QUOTE_NOT_FOUND));
        // 응답
        return GetQuoteByRandomResDto.toDto(quote);
    }













    /** 명언 저장 API **/
    public void createQuote() {
        // 이미 데이터가 있으면 중복 저장 방지
        if (quoteRepository.count() > 0) {
            quoteRepository.deleteAll();
        }

        List<Quote> quotes = List.of(
                Quote.builder().sentence("삶이 있는 한 희망은 있다").speaker("키케로").build(),
                Quote.builder().sentence("언제나 현재에 집중할수 있다면 행복할것이다.").speaker("파울로 코엘료").build(),
                Quote.builder().sentence("신은 용기있는자를 결코 버리지 않는다").speaker("켄러").build(),
                Quote.builder().sentence("단순하게 살아라. 현대인은 쓸데없는 절차와 일 때문에 얼마나 복잡한 삶을 살아가는가?").speaker("이드리스 샤흐").build(),
                Quote.builder().sentence("먼저핀꽃은 먼저진다 남보다 먼저 공을 세우려고 조급히 서둘것이 아니다").speaker("채근담").build(),
                Quote.builder().sentence("행복한 삶을 살기위해 필요한 것은 거의 없다.").speaker("마르쿠스 아우렐리우스 안토니우스").build(),
                Quote.builder().sentence("절대 어제를 후회하지 마라 . 인생은 오늘의 나 안에 있고 내일은 스스로 만드는 것이다").speaker("L.론허바드").build(),
                Quote.builder().sentence("어리석은 자는 멀리서 행복을 찾고, 현명한 자는 자신의 발치에서 행복을 키워간다").speaker("제임스 오펜하임").build(),
                Quote.builder().sentence("모든 인생은 실험이다 . 더많이 실험할수록 더나아진다").speaker("랄프 왈도 에머슨").build(),
                Quote.builder().sentence("한번의 실패와 영원한 실패를 혼동하지 마라").speaker("F.스콧 핏제랄드").build(),
                Quote.builder().sentence("내일은 내일의 태양이 뜬다").speaker("미상").build(),
                Quote.builder().sentence("피할수 없으면 즐겨라").speaker("로버트 엘리엇").build(),
                Quote.builder().sentence("절대 어제를 후회하지 마라. 인생은 오늘의 내 안에 있고 내일은 스스로 만드는것이다.").speaker("L.론허바드").build(),
                Quote.builder().sentence("계단을 밟아야 계단 위에 올라설수 있다,").speaker("터키속담").build(),
                Quote.builder().sentence("오랫동안 꿈을 그리는 사람은 마침내 그 꿈을 닮아 간다,").speaker("앙드레 말로").build(),
                Quote.builder().sentence("행복은 습관이다,그것을 몸에 지니라").speaker("허버드").build(),
                Quote.builder().sentence("성공의 비결은 단 한 가지, 잘할 수 있는 일에 광적으로 집중하는 것이다.").speaker("톰 모나건").build(),
                Quote.builder().sentence("자신감 있는 표정을 지으면 자신감이 생긴다").speaker("찰스다윈").build(),
                Quote.builder().sentence("절대 포기하지 말라.  당신 자신에게 기회를 주어라.").speaker("마이크 맥라렌").build(),
                Quote.builder().sentence("당신이 되고 싶은 무언가가 있다면, 그에 대해 자부심을 가져라. ").speaker("마이크 맥라렌").build(),
                Quote.builder().sentence("스스로가 형편없다고 생각하지 말라. 그래봐야 아무 것도 얻을 것이 없다.").speaker("마이크 맥라렌").build(),
                Quote.builder().sentence("꿈을 계속 간직하고 있으면 반드시 실현할 때가 온다").speaker("괴테").build(),
                Quote.builder().sentence("행복은 결코 많고 큰데만 있는 것이 아니다 작은 것을 가지고도 고마워 하고 만족할 줄 안다면 그는 행복한 사람이다.").speaker("법정스님").build(),
                Quote.builder().sentence("해야 할 것을 하라. 모든 것은 타인의 행복을 위해서, 동시에 특히 나의 행복을 위해서이다").speaker("톨스토이").build(),
                Quote.builder().sentence("사막이 아름다운 것은 어딘가에 샘이 숨겨져 있기 때문이다").speaker("생떽쥐베리").build(),
                Quote.builder().sentence("고개 숙이지 마십시오. 세상을 똑바로 정면으로 바라보십시오").speaker("헬렌 켈러").build(),
                Quote.builder().sentence("자신을 내보여라. 그러면 재능이 드러날 것이다.").speaker("발타사르 그라시안").build(),
                Quote.builder().sentence("자신의 본성이 어떤것이든 그에 충실하라 ").speaker("시드니 스미스").build(),
                Quote.builder().sentence("자신이 가진 재능의 끈을 놓아 버리지 마라.").speaker("시드니 스미스").build(),
                Quote.builder().sentence("본성이 이끄는 대로 따르면 성공할것이다").speaker("시드니 스미스").build(),
                Quote.builder().sentence("당신이 할수 있다고 믿든 할수 없다고 믿든 믿는 대로 될것이다").speaker("헨리 포드").build(),
                Quote.builder().sentence("단순하게 살라. 쓸데없는 절차와 일 때문에 얼마나 복잡한 삶을 살아가는가?").speaker("이드리스 샤흐").build(),
                Quote.builder().sentence("지금이야 말로 일할때다. 지금이야 말로 싸울때다. 지금이야 말로 나를 더 훌륭한 사람으로 만들때다 ").speaker("토마스 아켐피스").build(),
                Quote.builder().sentence("작은 기회로 부터 종종 위대한 업적이 시작된다").speaker("데모스테네스").build(),
                Quote.builder().sentence("인간의 삶 전체는 단지 한 순간에 불과하다 . 인생을 즐기자").speaker("플루타르코스").build(),
                Quote.builder().sentence("한 번 실패와 영원한 실패를 혼동하지 마라").speaker("F.스콧 핏제랄드").build(),
                Quote.builder().sentence("자신이 해야 할 일을 결정하는 사람은 세상에서 단 한 사람, 오직 나 자신뿐이다").speaker("오손 웰스").build(),
                Quote.builder().sentence("겨울이 오면 봄이 멀지 않으리").speaker("셸리").build(),
                Quote.builder().sentence("인생을 다시 산다면 다음번에는 더 많은 실수를 저지르리라").speaker("나딘 스테어").build(),
                Quote.builder().sentence("인생에서 원하는 것을 엇기 위한 첫번째 단계는 내가 무엇을 원하는지 결정하는 것이다 ").speaker("벤스타인").build(),
                Quote.builder().sentence("문제점을 찾지 말고 해결책을 찾으라").speaker("헨리포드").build(),
                Quote.builder().sentence("현재는 한없이 우울한것 모든건 하염없이 사라지나간다").speaker("푸쉬킨").build(),
                Quote.builder().sentence(".인생에 뜻을 세우는데 있어 늦은 때라곤 없다").speaker("볼드윈").build(),
                Quote.builder().sentence("두려움의 홍수에 버티기 위해서 끊임없이 용기의 둑을 쌓아야 한다.").speaker("마틴 루터 킹").build(),
                Quote.builder().sentence("이미끝나버린 일을 후회하기 보다는 하고 싶었던 일들을 하지못한 것을 후회하라.").speaker("탈무드").build(),
                Quote.builder().sentence("길을 잃는 다는 것은 곧 길을 알게 된다는 것이다").speaker("동아프리카속담").build()
        );

        quoteRepository.saveAll(quotes);
    }
}
