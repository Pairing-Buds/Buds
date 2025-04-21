package com.pairing.buds.domain.cs.repository;

import com.pairing.buds.domain.cs.entity.CSAnswer;
import org.springframework.data.jpa.repository.JpaRepository;

public interface CSRepository extends JpaRepository<CSAnswer, Integer> {
}
