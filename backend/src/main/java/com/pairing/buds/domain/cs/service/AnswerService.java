package com.pairing.buds.domain.cs.service;

import com.pairing.buds.common.response.Common;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.admin.repository.AdminRepository;
import com.pairing.buds.domain.cs.dto.answer.req.CreateAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.DeleteAnswerReqDto;
import com.pairing.buds.domain.cs.dto.answer.req.PatchAnswerReqDto;
import com.pairing.buds.domain.cs.entity.Answer;
import com.pairing.buds.domain.cs.repository.AnswerRepository;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
@Slf4j
public class AnswerService {

    private final AnswerRepository answerRepository;
    private final AdminRepository adminRepository;
    private final UserRepository userRepository;

    /** 답변 작성 **/
    public void createAnswer(int adminId, @Valid CreateAnswerReqDto dto) {

        int userId = dto.getUserId();
        String content = dto.getContent();
        log.info("userId : {}", userId);

        User user = userRepository.findById(userId).orElseThrow( () -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND)));
        Admin admin = adminRepository.findById(adminId).orElseThrow(() -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND)));

        Answer answerToCreate = CreateAnswerReqDto.toAnswer(admin, user, content);
        answerRepository.save(answerToCreate);
    }
    
    /** 답변 수정 **/
    public void patchAnswer(int adminId, @Valid PatchAnswerReqDto dto) {
        int answerId = dto.getAnswerId();
        String content = dto.getContent();
        log.info("answerId : {}", answerId);

        if(!adminRepository.existsById(adminId)) throw new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND));
        Answer answer = answerRepository.findById(adminId).orElseThrow(() -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.ANSWER_NOT_FOUND)));
        
        Answer answerToSave = PatchAnswerReqDto.patchAnswer(answer, content);
        answerRepository.save(answerToSave);
    }

    /** 답변 삭제 **/
    public void deleteAnswer(int adminId, @Valid DeleteAnswerReqDto dto) {

        int answerId = dto.getAnswerId();
        log.info("answerId : {}", answerId);

        if(!adminRepository.existsById(adminId)) throw new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.ADMIN_NOT_FOUND));
        Answer answerToDelete = answerRepository.findById(adminId).orElseThrow(() -> new RuntimeException(Common.toString(StatusCode.NOT_FOUND, Message.ANSWER_NOT_FOUND)));
        answerRepository.delete(answerToDelete); // 에러 시 OptimisticLockingFailureException 발생
    }
}
