package com.pairing.buds.domain.letter.repository;

import com.pairing.buds.domain.letter.entity.Letter;
import com.pairing.buds.domain.letter.entity.LetterFavorite;
import com.pairing.buds.domain.letter.entity.LetterFavoriteId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LetterFavoriteRepository extends JpaRepository<LetterFavorite, LetterFavoriteId> {
    Optional<LetterFavorite> findByUserIdAndLetterId(int userId, int letterId);
}
