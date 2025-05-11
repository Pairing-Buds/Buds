package com.pairing.buds.domain.user.dto.request;

import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.TagType;
import com.pairing.buds.domain.user.entity.User;
import jakarta.persistence.Column;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.PositiveOrZero;
import lombok.*;

import java.util.List;
import java.util.Set;
import java.util.stream.Collectors;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Valid
public class SaveSurveyResultReqDto {

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

    private Set<TagType> tags;

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
