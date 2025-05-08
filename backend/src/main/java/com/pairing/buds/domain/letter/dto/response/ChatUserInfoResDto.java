package com.pairing.buds.domain.letter.dto.response;

import com.pairing.buds.domain.letter.entity.LetterStatus;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatUserInfoResDto {

    private Integer userId;
    private Integer recentLetterId;         // 제일 최신 편지의 id
    private String userName;
    private LocalDate lastLetterDate;
    private LetterStatus lastLetterStatus;  // 가장 최신 편지의 읽음/읽지 않음 상태
    private boolean isReceived;             // 가장 최신 편지가 내가 받은 편지인지 보낸 편지인지 표시

}
