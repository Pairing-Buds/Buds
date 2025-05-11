package com.pairing.buds.domain.admin.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Common;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.admin.dto.req.ActiveUserReqDto;
import com.pairing.buds.domain.admin.dto.req.InActiveUserReqDto;
import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.admin.repository.AdminRepository;
import com.pairing.buds.domain.cs.dto.answer.req.CreateAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.DeleteAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.PatchAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.res.GetAnsweredQuestionListReqDto;
import com.pairing.buds.domain.cs.dto.answer.res.GetUnAnsweredQuestionListReqDto;
import com.pairing.buds.domain.cs.entity.Answer;
import com.pairing.buds.domain.cs.entity.Question;
import com.pairing.buds.domain.cs.entity.QuestionStatus;
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
public class AdminService {

    private final AnswerRepository answerRepository;
    private final AdminRepository adminRepository;
    private final UserRepository userRepository;
    private final QuestionRepository questionRepository;
    
    /** 문의 목록 조회 **/
    public List<GetAnsweredQuestionListReqDto> getAnsweredQuestionList(int adminId) {

        if(adminRepository.existsById(adminId)){
            throw new ApiException(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND);
        }
        return questionRepository.findAnsweredQuestionsByStatusOrderByCreatedAt(QuestionStatus.ANSWERED);
    }
    /** 미답변 문의 목록 조회 **/
    public List<GetUnAnsweredQuestionListReqDto> getUnAnsweredQuestionList(int adminId) {
        log.info("adminId : {}", adminId);

        if(adminRepository.existsById(adminId)){
            throw new ApiException(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND);
        }
        return questionRepository.findUnAnsweredQuestionsByStatusOrderByCreatedAt(QuestionStatus.UNANSWERED);
    }
    /** 특정 유저의 문의 조회 **/
    public Object getQuestionOfUser(int adminId, int userId) {
        if(adminRepository.existsById(adminId)){
            throw new ApiException(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND);
        }

//        answerRepository.find

        return null;
//        return questionRepository.findUnAnsweredQuestionsByUserId();
    }

    /** 답변 작성 **/
    public void createAnswer(int adminId, @Valid CreateAnswerReqDto dto) {
        // 변수
        int questionId = dto.getQuestionId();
        int userId = dto.getUserId();
        String content = dto.getContent();
        log.info("userId : {}, adminId : {}", userId, adminId);
        // 조회
        User user = userRepository.findById(userId).orElseThrow( () -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Admin admin = adminRepository.findById(adminId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND));
        Question question = questionRepository.findById(questionId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.LETTER_NOT_FOUND));
        // 답변 생성
        Answer answerToCreate = CreateAnswerReqDto.toAnswer(admin, user, content);
        // 기존 답변이 있다면 삭제 후 갱신
        if(question.getAnswer() != null){
            answerRepository.delete(question.getAnswer());
        }
        question.setAnswer(answerToCreate);
        // 저장
        answerRepository.save(answerToCreate);
        questionRepository.save(question);
    }

    /** 답변 수정 **/
    public void patchAnswer(int adminId, @Valid PatchAnswerReqDto dto) {
        int answerId = dto.getAnswerId();
        String content = dto.getContent();
        log.info("answerId : {}, adminId : {}", answerId, adminId);

        if(!adminRepository.existsById(adminId)) throw new ApiException(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND);
        Answer answer = answerRepository.findById(adminId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.ANSWER_NOT_FOUND));

        Answer answerToSave = PatchAnswerReqDto.patchAnswer(answer, content);
        answerRepository.save(answerToSave);
    }
    /** 회원 활성화 **/
    public void activeUser(int adminId, ActiveUserReqDto dto) {
        int userId = dto.getUserId();
        log.info("adminId : {}, userId : {}", adminId ,userId);

        if(!adminRepository.existsById(adminId)){ throw new ApiException(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND);}
        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        User activatedUser = ActiveUserReqDto.toActiveUser(user);
        userRepository.save(activatedUser);
    }
    /** 회원 비활성화 **/
    public void inactiveUser(int adminId, InActiveUserReqDto dto) {
        int userId = dto.getUserId();
        log.info("adminId : {}, userId : {}", adminId ,userId);

        if(adminRepository.existsById(adminId)){ throw new ApiException(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND);}
        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        User inActivatedUser = InActiveUserReqDto.toInActiveUser(user);
        userRepository.save(inActivatedUser);
    }



    /** 답변 삭제 **/
    public void deleteAnswer(int adminId, @Valid DeleteAnswerReqDto dto) {

        int answerId = dto.getAnswerId();
        log.info("answerId : {}", answerId);

        if(!adminRepository.existsById(adminId)) throw new ApiException(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND);
        Answer answerToDelete = answerRepository.findById(adminId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.ANSWER_NOT_FOUND));
        answerRepository.delete(answerToDelete); // 에러 시 OptimisticLockingFailureException 발생
    }



}
