package com.pairing.buds.domain.letter.dto.response;

import com.pairing.buds.domain.letter.entity.LetterStatus;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LatestLetterDetailResDto {

    private Integer letterId;
    private String senderName;
    private LocalDate createdAt;
    private String content;
    private boolean isReceived;
    private LetterStatus status;

}
