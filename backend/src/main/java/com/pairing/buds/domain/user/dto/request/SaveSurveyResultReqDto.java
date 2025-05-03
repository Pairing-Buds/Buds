package com.pairing.buds.domain.user.dto.request;

import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.Column;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class SaveSurveyResultReqDto {

    @Positive
    @NotNull
    private int seclusionScore;

    @Positive
    @NotNull
    private int opennessScore;

    @Positive
    @NotNull
    private int sociabilityScore;

    @Positive
    @NotNull
    private int routineScore;

    @Positive
    @NotNull
    private int quietnessScore;

    @Positive
    @NotNull
    private int expressionScore;

    public static User toUser(User user, SaveSurveyResultReqDto dto){
        user.setSeclusionScore(dto.getSeclusionScore());
        user.setSociabilityScore(dto.getSociabilityScore());
        user.setRoutineScore(dto.getRoutineScore());
        user.setOpennessScore(dto.getOpennessScore());
        user.setQuietnessScore(dto.getQuietnessScore());
        user.setExpressionScore(dto.getExpressionScore());
        return user;
    }

}
