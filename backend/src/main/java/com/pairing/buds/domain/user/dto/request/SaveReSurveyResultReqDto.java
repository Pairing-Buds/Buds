package com.pairing.buds.domain.user.dto.request;

import com.pairing.buds.domain.user.entity.User;
import jakarta.validation.Valid;
import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@NoArgsConstructor
@AllArgsConstructor
@Valid
@Getter
@Setter
public class SaveReSurveyResultReqDto {
    
    /**
     * 설문조사 결과는 각 항목 별로 0 ~ 40점
     * **/

    @PositiveOrZero
    @NotNull
    private int seclusionScore;

    @PositiveOrZero
    @NotNull
    private int opennessScore;

    @PositiveOrZero
    @NotNull
    private int sociabilityScore;

    @PositiveOrZero
    @NotNull
    private int routineScore;

    @PositiveOrZero
    @NotNull
    private int quietnessScore;

    @PositiveOrZero
    @NotNull
    private int expressionScore;


    public static User toUser(User user, SaveReSurveyResultReqDto dto){
        user.setSeclusionScore(dto.getSeclusionScore());
        user.setSociabilityScore(dto.getSociabilityScore());
        user.setRoutineScore(dto.getRoutineScore());
        user.setOpennessScore(dto.getOpennessScore());
        user.setQuietnessScore(dto.getQuietnessScore());
        user.setExpressionScore(dto.getExpressionScore());
        return user;
    }
}
