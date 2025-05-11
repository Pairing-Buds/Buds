package com.pairing.buds.domain.cs.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Common;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.cs.dto.question.request.CreateQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.request.DeleteQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.request.PatchQuestionReqDto;
import com.pairing.buds.domain.cs.dto.question.response.GetQuestionsResDto;
import com.pairing.buds.domain.cs.entity.Answer;
import com.pairing.buds.domain.cs.entity.Question;
import com.pairing.buds.domain.cs.repository.AnswerRepository;
import com.pairing.buds.domain.cs.repository.QuestionRepository;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class QuestionService {

    private final UserRepository userRepository;
    private final QuestionRepository questionRepository;
    private final AnswerRepository answerRepository;

    /** 문의 조회 **/
    public GetQuestionsResDto getQuestion(int userId) {
        List<Question> questions = questionRepository.findByUser_id(userId);
        return GetQuestionsResDto.toGetQuestionsResDto(questions);
    }

    /** 문의 생성 **/
    public void createQuestion(int userId, @Valid CreateQuestionReqDto dto) {
        // 변수
        String subject = dto.getSubject();
        String content = dto.getContent();
        // 유저 조회
        User user = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        // 임시 답변 생성
        Answer answer = new Answer();
        answer.setContent("문의를 확인 중입니다..");
//        answer.setUser(user);
//        answer.setAdmin(null);
        Answer tempAnswer = answerRepository.save(answer);
        // 질문 생성
        Question newQuestion = new Question();
        newQuestion.setUser(user);
        newQuestion.setSubject(subject);
        newQuestion.setContent(content);
        newQuestion.setAnswer(tempAnswer);
        // 저장
        Question createdQuestion = questionRepository.save(newQuestion);
    }

    /** 문의 수정 **/
    public void patchQuestion(int userId, @Valid PatchQuestionReqDto dto) {
        int questionId = dto.getQuestionId();
        String subject = dto.getSubject();
        String content = dto.getContent();
        // 문의글 유저와 요청한 유저 동일성 확인
        Question questionToPatch = questionRepository.findById(questionId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.QUESTION_NOT_FOUND));
        if(userId != questionToPatch.getUser().getId()){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }

        questionToPatch.setSubject(subject);
        questionToPatch.setContent(content);
        questionRepository.save(questionToPatch); // 에러 시 OptimisticLockingFailureException 발생
    }

    /** 문의 삭제 **/
    public void deleteQuestion(int userId, @Valid DeleteQuestionReqDto dto) {
        int questionId = dto.getQuestionId();
        // 문의글 유저와 요청한 유저 동일성 확인
        Question questionToDelete = questionRepository.findById(questionId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.QUESTION_NOT_FOUND)));
        if(userId != questionToDelete.getUser().getId()){
            throw new ApiException(StatusCode.BAD_REQUEST, Message.ARGUMENT_NOT_PROPER);
        }
        questionRepository.delete(questionToDelete); // 에러 시 OptimisticLockingFailureException 발생
    }
}
