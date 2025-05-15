package com.pairing.buds.domain.letter.repository;

import com.pairing.buds.domain.letter.entity.Letter;
import com.pairing.buds.domain.letter.entity.LetterFavorite;
import com.pairing.buds.domain.letter.entity.LetterFavoriteId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LetterFavoriteRepository extends JpaRepository<LetterFavorite, LetterFavoriteId> {
    Optional<LetterFavorite> findByUserIdAndLetterId(int userId, int letterId);

    /** 즐겨찾기 한 편지 조회 **/
//    List<LetterFavorite> findAllByUser_Id(Integer userId);

    /** 즐겨찾기 한 편지 최신순 정렬 **/
    List<LetterFavorite> findAllByUser_IdOrderByCreatedAtDesc(Integer userId);
}
