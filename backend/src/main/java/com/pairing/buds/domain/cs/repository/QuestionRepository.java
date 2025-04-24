package com.pairing.buds.domain.cs.repository;

import com.pairing.buds.domain.cs.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;

public interface QuestionRepository extends JpaRepository<Question, Integer> {
}
