package com.pairing.buds.domain.cs.service;

import com.pairing.buds.common.response.Common;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.cs.dto.req.CreateQuestionReqDto;
import com.pairing.buds.domain.cs.dto.res.GetQuestionResDto;
import com.pairing.buds.domain.cs.entity.Question;
import com.pairing.buds.domain.cs.repository.QuestionRepository;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class QuestionService {

    private final UserRepository userRepository;
    private final QuestionRepository questionRepository;

    /** 문의 조회 **/
    public GetQuestionResDto getQuestion(int questionId, int userId) {

        log.info("questionId : {}, userId : {}", questionId, userId);

        Question question = questionRepository.findById(questionId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.QUESTION_NOT_FOUND)));

        return GetQuestionResDto.toDto(question);
    }
    
    /** 문의 생성 **/
    public void createQuestion(int userId, @Valid CreateQuestionReqDto dto) {

        log.info("");
    }
}
