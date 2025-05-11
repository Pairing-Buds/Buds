package com.pairing.buds.domain.letter.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.common.utils.BadWordFilter;
import com.pairing.buds.domain.letter.dto.req.AnswerLetterReqDto;
import com.pairing.buds.domain.letter.dto.req.ScrapLetterCancelReqDto;
import com.pairing.buds.domain.letter.dto.req.ScrapLetterReqDto;
import com.pairing.buds.domain.letter.dto.request.SendLetterReqDto;
import com.pairing.buds.domain.letter.dto.res.GetLetterDetailResDto;
import com.pairing.buds.domain.letter.dto.response.ChatUserInfoResDto;
import com.pairing.buds.domain.letter.dto.response.LetterChatListResDto;
import com.pairing.buds.domain.letter.dto.response.LetterDetailListResDto;
import com.pairing.buds.domain.letter.dto.response.LetterDetailResDto;
import com.pairing.buds.domain.letter.entity.Letter;
import com.pairing.buds.domain.letter.entity.LetterFavorite;
import com.pairing.buds.domain.letter.entity.LetterFavoriteId;
import com.pairing.buds.domain.letter.entity.LetterStatus;
import com.pairing.buds.domain.letter.repository.LetterFavoriteRepository;
import com.pairing.buds.domain.letter.repository.LetterRepository;
import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.TagType;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class LetterService {

    private final LetterRepository letterRepository;
    private final UserRepository userRepository;
    private final LetterFavoriteRepository letterFavoriteRepository;
    private final BadWordFilter badWordFilter;

    /** 특정 편지 상세 조회 **/
    @Transactional
    public GetLetterDetailResDto getLetterDetail(int userId, int letterId) {
        // 변수
        log.info("userId : {}, letterId : {}", userId, letterId);
        // 응답
        Letter letter = letterRepository.findById(letterId).orElseThrow((()-> new ApiException(StatusCode.NOT_FOUND, Message.LETTER_NOT_FOUND)));
        letter.setStatus(LetterStatus.READ);
        letterRepository.save(letter);
        return GetLetterDetailResDto.toDto(letter);
    }


    /** 편지 채팅 리스트 조회 **/
    public LetterChatListResDto getLetterChatList(Integer userId) {
        User loginUser = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        // userId 기준 수*발신 편지 조회
        List<Letter> letters = letterRepository.findAllBySenderIdOrReceiverIdOrderByIdDesc(userId, userId);

        // 상대방별로 주고받은 편지 중 최신 편지 1개 남기기 (LinkedHashMap -> 최신순 유지)
        Map<Integer, Letter> latestLetterMap = new LinkedHashMap<>();

        for (Letter letter : letters) {
            User opponent = letter.getSender().getId().equals(userId) ? letter.getReceiver() : letter.getSender();
            Integer opponentId = opponent.getId();

            // 이미 있으면 스킵
            if (!latestLetterMap.containsKey(opponentId)) {
                latestLetterMap.put(opponentId, letter);
            }
        }

        List<ChatUserInfoResDto> chatUsers = latestLetterMap.values().stream()
                .map(letter -> {
                    User opponent = letter.getSender().getId().equals(userId) ? letter.getReceiver() : letter.getSender();
                    boolean isReceived = letter.getReceiver().getId().equals(userId);

                    return new ChatUserInfoResDto(
                            opponent.getId(),
                            letter.getId(),
                            opponent.getUserName(),
                            letter.getCreatedAt().toLocalDate(),
                            letter.getStatus(),
                            isReceived
                    );
                })
                .toList();

        return new LetterChatListResDto(loginUser.getLetterCnt(), chatUsers);
    }

    /** 특정 사용자와의 편지 상세 목록 조회 **/
    public LetterDetailListResDto getLetterDetailList(Integer userId, Integer opponentId, int page, int size) {
        User loginUser = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        User opponent = userRepository.findById(opponentId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        // 두 사용자간 편지 페이지 조회 (최신순)
        Page<Letter> letterPage = letterRepository.findLettersBetweenUsers(userId, opponentId, PageRequest.of(page, size));

        List<LetterDetailResDto> letters = letterPage.getContent().stream()
                .map(letter -> {
                    boolean isReceived = letter.getReceiver().getId().equals(userId);
                    return new LetterDetailResDto(
                            letter.getId(),
                            letter.getSender().getUserName(),
                            letter.getCreatedAt().toLocalDate(),
                            isReceived,
                            letter.getStatus()
                    );
                })
                .toList();

        return new LetterDetailListResDto(
                opponent.getId(),
                opponent.getUserName(),
                letterPage.getNumber(),
                letterPage.getTotalPages(),
                letters
        );
    }

    /** 최근 수신 편지 1건 조회 **/
    public LetterDetailResDto getLatestReceivedLetter(Integer userId) {
        User loginUser = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        // 가장 최근 편지 한 건 조회
        Letter letter = letterRepository.findFirstByReceiver_IdOrderByCreatedAtDesc(loginUser.getId())
                .orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.LETTER_NOT_FOUND));

        // 상태 읽음으로 변경
        letter.setStatus(LetterStatus.READ);
        letterRepository.save(letter);

        return new LetterDetailResDto(
                letter.getId(),
                letter.getSender().getUserName(),
                letter.getCreatedAt().toLocalDate(),
                true,
                letter.getStatus()
        );
    }

    /** 편지 스크랩 추가 **/
    @Transactional
    public void scrapLetter(int userId, ScrapLetterReqDto dto) {
        int letterId = dto.getLetterId();
        log.info("userId : {}, letterId : {}", userId, letterId);

        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Letter letter = letterRepository.findById(letterId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.LETTER_NOT_FOUND));

        LetterFavorite letterFavorite = new LetterFavorite();
        letterFavorite.setId(new LetterFavoriteId(userId, letterId));
        letterFavorite.setUser(user);
        letterFavorite.setLetter(letter);

        letterFavoriteRepository.save(letterFavorite);
    }

    /** 답장 작성 **/
    @Transactional
    public void answerLetter(int userId, AnswerLetterReqDto dto) {
        int letterId = dto.getLetterId();
        String content = dto.getContent();
        log.info("userId : {}, letterId : {} ",userId ,letterId);

        if(badWordFilter.isBadWord(content)){ throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);}

        Letter letter = letterRepository.findById(letterId).orElseThrow(()-> new ApiException(StatusCode.NOT_FOUND, Message.LETTER_NOT_FOUND));

        Letter answeredLetter = AnswerLetterReqDto.toLetter(letter, content);
        letterRepository.save(answeredLetter);
    }

    /**
     * 편지 랜덤 발송
     * - 상대와의 편지 목록 중 최근 편지가 내가 보낸 것 & 1개월 이내
     * - 해당되는 경우
     * 대화 없음	포함됨
     * 최근 편지가 상대방 → 나	포함됨
     * 최근 편지가 나 → 상대방인데 1개월 이후	포함됨
     * 최근 편지가 나 → 상대방인데 1개월 이내	제외됨
     **/
    @Transactional
    public void sendLetter(Integer userId, SendLetterReqDto dto) {
        User sender = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        if (sender.getLetterCnt() <= 0) {
            throw new ApiException(StatusCode.BAD_REQUEST, Message.OUT_OF_LETTER_TOKEN);
        }

        List<User> candidates;
        LocalDateTime oneMonthAgo = LocalDateTime.now().minusMonths(1); // 최근 1개월 이내
        Pageable page = PageRequest.of(0, 5); // 5명 선택

        if(dto.getIsTagBased()) {
            // 태그 기반 랜덤 발송(1개 이상 일치하는 경우 후보)
            List<TagType> senderTags = sender.getTags().stream()
                    .map(Tag::getTagName)
                    .toList();

            // sender가 태그를 선택하지 않은 경우
            if (senderTags.isEmpty()) {
                throw new ApiException(StatusCode.BAD_REQUEST, Message.TAGS_NOT_SELECTED);
            }

            candidates = userRepository.findRandomReceiverByTags(
                    sender.getId(),
                    senderTags,
                    oneMonthAgo,
                    page
            );

        } else {
            // 일반 랜덤 발송
            candidates = userRepository.findRandomReceiver(
                    sender.getId(),
                    oneMonthAgo,
                    page
            );
        }

        if (candidates.isEmpty()) {
            throw new ApiException(StatusCode.BAD_REQUEST, Message.RECEIVER_NOT_FOUND);
        }

        for (User candidate : candidates) {
            log.info("랜덤 테스트, Random User Id {}", candidate.getId());
        }

        User receiver = candidates.get(0);

        Letter letter = new Letter();
        letter.setSender(sender);
        letter.setReceiver(receiver);
        letter.setContent(dto.getContent());
        letter.setIsTagBased(dto.getIsTagBased());

        sender.setLetterCnt(sender.getLetterCnt() - 1);

        userRepository.save(sender);
        letterRepository.save(letter);
    }

    /** 편지 스크랩 취소 **/
    @Transactional
    public void scrapLetterCancel(int userId, ScrapLetterCancelReqDto dto) {
        int letterId = dto.getLetterId();
        log.info("userId : {}, letterId : {}", userId, letterId);

        // 편지 조회
        LetterFavorite letterFavorite = letterFavoriteRepository.findByUserIdAndLetterId(userId, letterId).orElseThrow(
                () -> new ApiException(StatusCode.NOT_FOUND, Message.LETTER_FAVORITE_NOT_FOUND)
        );
        letterFavoriteRepository.delete(letterFavorite);
    }

}
