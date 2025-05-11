package com.pairing.buds.domain.cs.repository;

import com.pairing.buds.domain.cs.entity.Answer;
import com.pairing.buds.domain.cs.entity.Question;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AnswerRepository extends JpaRepository<Answer, Integer> {
}
