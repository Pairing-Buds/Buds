package com.pairing.buds;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.admin.dto.req.ActiveUserReqDto;
import com.pairing.buds.domain.admin.dto.req.InActiveUserReqDto;
import com.pairing.buds.domain.admin.entity.Admin;
import com.pairing.buds.domain.admin.repository.AdminRepository;
import com.pairing.buds.domain.admin.service.AdminService;
import com.pairing.buds.domain.user.entity.SignupStatus;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.entity.UserCharacter;
import com.pairing.buds.domain.user.entity.UserRole;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.persistence.Column;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.transaction.Transactional;
import jakarta.validation.constraints.AssertTrue;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

@SpringBootTest
@Transactional
class BudsApplicationTests {

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
	@DisplayName("활성화 : 정상 케이스")
	void activate_user_success() {
		ActiveUserReqDto dto = new ActiveUserReqDto();
		dto.setUserId(userId);

		adminService.activeUser(adminId, dto);

		User user = userRepository.findById(userId).orElseThrow(() -> new ApiException(StatusCode.NOT_FOUND, Message.USER_NOT_FOUND));
		Assertions.assertTrue(user.getIsActive());
	}
	




}
