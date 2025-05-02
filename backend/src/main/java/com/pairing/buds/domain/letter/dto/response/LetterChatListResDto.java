package com.pairing.buds.domain.letter.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LetterChatListResDto {

    private Integer letterCnt;
    private List<ChatUserInfoResDto> chatList;

}
