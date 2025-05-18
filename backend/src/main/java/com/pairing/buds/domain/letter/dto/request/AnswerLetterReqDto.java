package com.pairing.buds.domain.letter.dto.request;

import com.pairing.buds.domain.letter.entity.Letter;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Valid
public class AnswerLetterReqDto {

    @NotNull
    @Positive
    private int letterId;

    @NotNull
    private String content;

    public static Letter toLetter(Letter letter, String content){
        Letter newLetter = new Letter();
        newLetter.setSender(letter.getReceiver());
        newLetter.setReceiver(letter.getSender());
        newLetter.setContent(content);
        newLetter.setIsAnswered(true);
        return newLetter;
    }
}
