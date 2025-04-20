package com.pairing.buds.domain.survey.repository;

import com.pairing.buds.domain.survey.entity.Survey;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SurveyRepository extends JpaRepository<Survey, Integer> {
}
