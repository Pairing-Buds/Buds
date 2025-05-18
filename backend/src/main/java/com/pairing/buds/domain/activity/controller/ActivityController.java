package com.pairing.buds.domain.activity.controller;

import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.ResponseDto;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.activity.dto.request.*;
import com.pairing.buds.domain.activity.service.ActivityService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/activities")
@RequiredArgsConstructor
public class ActivityController {

    private final ActivityService activityService;

    /** 취향이 맞는 친구 찾기 **/
    @GetMapping("/find-friend-by-tag")
    public ResponseDto findFriendByTag(
            @AuthenticationPrincipal int userId
//            @RequestParam("opponentId") int opponentId
    ){
        return new ResponseDto(StatusCode.OK, activityService.findFriendByTag(userId)); // opponentId 제거
    }
    /** 명언 조회 **/
    @GetMapping("/quote")
    public ResponseDto getQuoteByRandom(
            @AuthenticationPrincipal int userId
    ){
        return new ResponseDto(StatusCode.OK, activityService.getQuoteByRandom(userId));
    }


    /** 기상 시간 등록 **/
    @PostMapping("/wake")
    public ResponseDto createWakeTime(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody CreateWakeTimeReqDto dto){
        activityService.createWakeTime(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
    /** 기상 시간 인증 **/
    @PostMapping("/wake-verification")
    public ResponseDto wakeVerify(
            @AuthenticationPrincipal int userId){
        activityService.wakeVerify(userId);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
    /** 사용자 음성 텍스트 입력 **/
    @PostMapping("/sentence-voice")
    public ResponseDto activitySentenceVoice(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody ActivitySentenceVoiceReqDto dto){
        activityService.activitySentenceVoice(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
    /** 사용자 필사 활동 인증 (폐기) **/

    /** 만보기 리워드 신청 **/
    @PostMapping("/walk")
    public ResponseDto walkRewardReq(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody WalkRewardReqDto dto){
        activityService.walkRewardReq(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }
    /** 최초 페이지 인증 리워드 **/
    @PostMapping("/first-visit")
    public ResponseDto firstVisitReward(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody FirstVisitRewardReqDto dto){
        activityService.firstVisitReward(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 추천 장소 방문 리워드 **/
    @PostMapping("/visit-recommended-place")
    public ResponseDto visitRecommendedPlaceReward(
            @AuthenticationPrincipal int userId){
        activityService.visitRecommendedPlaceReward(userId);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }


    /** 기상 시간 수정 **/
    @PatchMapping("/wake")
    public ResponseDto updateWakeTime(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody UpdateWakeTimeReqDto dto){
            activityService.updateWakeTime(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 기상 시간 삭제 **/
    @DeleteMapping("/wake")
    public ResponseDto deleteWakeTime(
            @AuthenticationPrincipal int userId,
            @Valid @RequestBody DeleteWakeTimeReqDto dto){
        activityService.deleteWakeTime(userId, dto);
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

    /** 명언 저장 API**/
    @PostMapping("/quote")
    public ResponseDto createQuote(
            @AuthenticationPrincipal int userId){
        activityService.createQuote();
        return new ResponseDto(StatusCode.OK, Message.OK);
    }

}
