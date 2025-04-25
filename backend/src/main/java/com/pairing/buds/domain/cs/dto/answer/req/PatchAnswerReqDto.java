package com.pairing.buds.domain.cs.dto.answer.req;

import com.pairing.buds.domain.cs.entity.Answer;
import jakarta.validation.Valid;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class PatchAnswerReqDto {

    private int answerId;

    private String content;

    public static Answer patchAnswer(Answer answer, String content){
        answer.setContent(content);
        return answer;
    }
}
