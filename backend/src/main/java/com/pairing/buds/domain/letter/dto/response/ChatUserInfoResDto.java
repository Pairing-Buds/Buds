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
    private String userName;
    private LocalDate lastLetterDate;
    private LetterStatus lastLetterStatus;
    private boolean isReceived;

}
