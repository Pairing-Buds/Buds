package com.pairing.buds;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.admin.dto.request.InActiveUserReqDto;
import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.admin.repository.AdminRepository;
import com.pairing.buds.domain.admin.service.AdminService;
import com.pairing.buds.domain.user.entity.SignupStatus;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.entity.UserCharacter;
import com.pairing.buds.domain.user.entity.UserRole;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootTest
@Transactional
public class InActiveUserTest {

    @Autowired
    private AdminService adminService;
    @Autowired
    private AdminRepository adminRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private PasswordEncoder encoder;

    private User user;
    private int adminId;
    private int userId;



    @BeforeEach
    void setUp() {
        User u = new User();
        u.setUserEmail("user@buds.co.kr");
        u.setPassword(encoder.encode("1234"));
        u.setRole(UserRole.USER);
        u.setIsActive(false);
        u.setLetterCnt(0);
        u.setUserName("asdf");
        u.setExpressionScore(10);
        u.setUserCharacter(UserCharacter.GECKO);
        u.setIsCompleted(SignupStatus.DONE);
        u.setSeclusionScore(10);
        u.setSociabilityScore(10);
        u.setOpennessScore(10);
        u.setQuietnessScore(10);
        u.setRoutineScore(10);

        user = userRepository.save(u);
        userId = user.getId();

        Admin ad = new Admin();
        ad.setEmail("admin@buds.co.kr");
        ad.setRole(UserRole.ADMIN);
        ad.setPassword(encoder.encode("1234"));
        Admin admin = adminRepository.save(ad);
        adminId = admin.getId();
    }



    @Test
    @DisplayName("비활성화 : 정상 케이스")
    void inactivate_user_success() {
        InActiveUserReqDto dto = new InActiveUserReqDto();
        dto.setUserId(userId);

        ApiException apiException = Assertions.assertThrows(ApiException.class, () -> adminService.inactiveUser(adminId, dto));
        Assertions.assertEquals(StatusCode.NOT_FOUND, apiException.getCode());
        Assertions.assertEquals(Message.ADMIN_NOT_FOUND, apiException.getMessageEnum());

        User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
        Assertions.assertFalse(user.getIsActive());
    }

    @Test
    @DisplayName("비활성화 : 비정상 케이스")
    void inactivate_user_fail() {
        InActiveUserReqDto dto = new InActiveUserReqDto();
        dto.setUserId(1234124);

        ApiException apiException = Assertions.assertThrows(ApiException.class, () -> adminService.inactiveUser(adminId, dto));

//        ApiException ex = Assertions.assertThrows(ApiException.class, () ->  userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND)));
        Assertions.assertEquals(StatusCode.NOT_FOUND, apiException.getCode());
        Assertions.assertEquals(Message.ADMIN_NOT_FOUND, apiException.getMessageEnum());
    }
}
