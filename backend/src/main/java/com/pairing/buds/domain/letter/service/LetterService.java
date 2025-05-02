package com.pairing.buds.domain.letter.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.common.utils.BadWordFilter;
import com.pairing.buds.domain.letter.dto.req.AnswerLetterReqDto;
import com.pairing.buds.domain.letter.dto.req.GetLetterDetailReqDto;
import com.pairing.buds.domain.letter.dto.req.ScrapLetterCancelReqDto;
import com.pairing.buds.domain.letter.dto.req.ScrapLetterReqDto;
import com.pairing.buds.domain.letter.dto.res.GetLetterDetailResDto;
import com.pairing.buds.domain.letter.entity.Letter;
import com.pairing.buds.domain.letter.entity.LetterFavorite;
import com.pairing.buds.domain.letter.entity.LetterStatus;
import com.pairing.buds.domain.letter.repository.LetterFavoriteRepository;
import com.pairing.buds.domain.letter.repository.LetterRepository;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

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
    public GetLetterDetailResDto getLetterDetail(int userId, GetLetterDetailReqDto dto) {
        // 변수
        int letterId = dto.getLetterId();
        log.info("userId : {}, letterId : {}", userId, letterId);
        // 응답
        Letter letter = letterRepository.findById(letterId).orElseThrow((()-> new ApiException(StatusCode.NOT_FOUND, Message.LETTER_NOT_FOUND)));
        letter.setStatus(LetterStatus.READ);
        letterRepository.save(letter);
        return GetLetterDetailResDto.toDto(letter);
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

    /** 편지 스크랩 추가 **/
    @Transactional
    public void scrapLetter(int userId, ScrapLetterReqDto dto) {
        int letterId = dto.getLetterId();
        log.info("userId : {}, letterId : {}", userId, letterId);

        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Letter letter = letterRepository.findById(letterId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.LETTER_NOT_FOUND));

        LetterFavorite letterFavorite = new LetterFavorite();
        letterFavorite.setUser(user);
        letterFavorite.setLetter(letter);

        letterFavoriteRepository.save(letterFavorite);
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
