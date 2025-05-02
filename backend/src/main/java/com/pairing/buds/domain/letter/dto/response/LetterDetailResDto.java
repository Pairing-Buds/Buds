package com.pairing.buds.domain.letter.dto.response;

import com.pairing.buds.domain.letter.entity.LetterStatus;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LetterDetailResDto {

    private Integer letterId;
    private String senderName;
    private String content;
    private LocalDate createdAt;
    private boolean isReceived;
    private LetterStatus status;

}
