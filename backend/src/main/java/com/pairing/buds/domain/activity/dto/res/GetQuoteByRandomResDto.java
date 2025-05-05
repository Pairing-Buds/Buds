package com.pairing.buds.domain.activity.dto.res;

import com.pairing.buds.domain.activity.entity.Quote;
import jakarta.validation.Valid;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class GetQuoteByRandomResDto {

    private int quoteId;

    private String sentence;

    private String speaker;

    public static GetQuoteByRandomResDto toDto(Quote quote){
        return GetQuoteByRandomResDto.builder()
                .quoteId(quote.getId())
                .sentence(quote.getSentence())
                .speaker(quote.getSpeaker())
                .build();
    }
}
