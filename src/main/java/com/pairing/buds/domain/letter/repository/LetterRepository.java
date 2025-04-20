package com.pairing.buds.domain.letter.repository;

import com.pairing.buds.domain.letter.entity.Letter;
import org.springframework.data.jpa.repository.JpaRepository;

public interface LetterRepository extends JpaRepository<Letter, Integer> {
}
