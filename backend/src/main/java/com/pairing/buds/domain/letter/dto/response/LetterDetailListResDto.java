package com.pairing.buds.domain.letter.dto.response;

import lombok.*;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LetterDetailListResDto {

    private Integer opponentId;
    private String opponentName;
    private int currentPage;
    private int totalPages;
    private List<LetterDetailResDto> letters;

}
