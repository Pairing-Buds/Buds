package com.pairing.buds.domain.user.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.mail.MessagingException;
import jakarta.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;
    private final VerificationService verificationService;
    private final UserRepository userRepository;

    /** 인증 토큰 생성 -> Redis 저장 -> 메일 발송 -> 결과 반환 **/
    public void sendVerificationEmail(String email) {
        // 중복 확인
        if (userRepository.existsByUserEmail(email)) {
            throw new ApiException(StatusCode.CONFLICT, Message.DUPLICATE_EMAIL_EXCEPTION);
        }

        // 6자리 코드 생성 & redis에 저장
        String token = verificationService.createToken(email);

        // 메일 작성
        String subject = "[Buds] 이메일 인증 코드 안내";
        String html =
                "<div style=\"border:1px solid #ccc; padding:20px; text-align:center;\">"
                        + "  <p style=\"font-size:18px; font-weight:bold; margin:0 0 10px;\">"
                        + "    이메일 인증을 위해 아래 <span style=\"color:#2a9d8f;\">인증 코드</span>를 확인하세요."
                        + "  </p>"
                        + "  <div style=\"font-size:24px; font-weight:bold; letter-spacing:4px; margin:15px 0;\">"
                        +       token
                        + "  </div>"
                        + "  <p style=\"color:red; margin:10px 0 0; text-align:left;\">"
                        + "    ※ 이 코드는 발송 후 30분 동안만 유효합니다."
                        + "  </p>"
                        + "</div>";

        // 메일 발송
        try{
            MimeMessage msg = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(msg, "UTF-8");
            helper.setTo(email);
            helper.setSubject(subject);
            helper.setText(html, true);
            mailSender.send(msg);
        } catch (MessagingException e) {
            throw new ApiException(StatusCode.INTERNAL_SERVER_ERROR, Message.FAIL_TO_SEND_EMAIL);
        }
    }

}
