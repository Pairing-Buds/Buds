package com.pairing.buds.domain.cs.service;

import com.pairing.buds.common.response.Common;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.cs.dto.question.req.CreateQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.req.DeleteQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.req.PatchQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.res.GetQuestionResDto;
import com.pairing.buds.domain.cs.entity.Question;
import com.pairing.buds.domain.cs.repository.QuestionRepository;
import com.pairing.buds.domain.user.entity.User;
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
    public GetQuestionResDto getQuestion(int userId) {

        log.info("userId : {}", userId);

//        User user = questionRepository.findByUser(userId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND)));

//        return GetQuestionResDto.toDto(question);
    return null;
    }

    /** 문의 생성 **/
    public void createQuestion(int userId, @Valid CreateQuestionReqDto dto) {

        String subject = dto.getSubject();
        String content = dto.getContent();
        log.info("userId : {}, subject : {}, content : {}", userId, subject, content);

        User user = userRepository.findById(userId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND)));
        Question newQuestion = Question.builder()
                .user(user)
                .subject(subject)
                .content(content)
                .build();
    }

    /** 문의 수정 **/
    public void patchQuestion(int userId, @Valid PatchQuestionReqDto dto) {

        int questionId = dto.getQuestionId();
        String subject = dto.getSubject();
        String content = dto.getContent();
        log.info("questionId : {}", questionId);

        // 문의글 유저와 요청한 유저 동일성 확인
        Question questionToPatch = questionRepository.findById(questionId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.QUESTION_NOT_FOUND)));
        if(userId != questionToPatch.getUser().getId()){
            log.info("userId와 question의 userId 불일치");
            throw new RuntimeException(Common.toString(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER));
        }

        questionToPatch.setSubject(subject);
        questionToPatch.setContent(content);
        questionRepository.save(questionToPatch); // 에러 시 OptimisticLockingFailureException 발생
    }

    /** 문의 삭제 **/
    public void deleteQuestion(int userId, @Valid DeleteQuestionReqDto dto) {

        int questionId = dto.getQuestionId();
        log.info("questionId : {}", questionId);

        // 문의글 유저와 요청한 유저 동일성 확인
        Question questionToDelete = questionRepository.findById(questionId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.QUESTION_NOT_FOUND)));
        if(userId != questionToDelete.getUser().getId()){
            log.info("userId와 question의 userId 불일치");
            throw new RuntimeException(Common.toString(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER));
        }

        questionRepository.delete(questionToDelete); // 에러 시 OptimisticLockingFailureException 발생
    }
}
