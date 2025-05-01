package com.pairing.buds.domain.user.service;

import com.pairing.buds.common.exception.ApiException;
import com.pairing.buds.common.response.Message;
import com.pairing.buds.common.response.StatusCode;
import com.pairing.buds.domain.user.dto.response.TagResDto;
import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.TagType;
import com.pairing.buds.domain.user.entity.User;
import com.pairing.buds.domain.user.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;

    /** 사용자 태그 조회 **/
    @Transactional
    public List<TagResDto> getUserTags(Integer userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        return user.getTags().stream()
                .map(tag -> TagResDto.builder()
                        .tagType(String.valueOf(tag.getTagName()))
                        .displayName(tag.getTagName().getDisplayName())
                        .build()
                )
                .collect(Collectors.toList());
    }

    /** 태그 업데이트(신규 저장 포함) **/
    @Transactional
    public void updateUserTags(Integer userId, List<TagType> selected) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ApiException(StatusCode.BAD_REQUEST, Message.USER_NOT_FOUND));

        // 기존 태그 제거
        user.getTags().clear();

        // 새로 선택된 enum 목록 Tag 엔티티 생성·추가
        for (TagType type : selected) {
            Tag tag = Tag.builder()
                    .user(user)
                    .tagName(type)
                    .build();
            user.getTags().add(tag);
        }

        userRepository.save(user);
    }

}
