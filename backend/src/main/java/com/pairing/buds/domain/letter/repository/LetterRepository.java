package com.pairing.buds.domain.letter.repository;

import com.pairing.buds.domain.letter.entity.Letter;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface LetterRepository extends JpaRepository<Letter, Integer> {

    List<Letter> findAllBySenderIdOrReceiverIdOrderByIdDesc(Integer senderId, Integer receiverId);

    @Query("""
        SELECT l
        FROM Letter l
        WHERE ((l.sender.id = :userId AND l.receiver.id = :opponentId)
           OR (l.sender.id = :opponentId AND l.receiver.id = :userId))
        ORDER BY l.id DESC
        """)
    Page<Letter> findLettersBetweenUsers(@Param("userId") Integer userId,
                                         @Param("opponentId") Integer opponentId,
                                         Pageable pageable);

    Optional<Letter> findFirstByReceiver_IdOrderByCreatedAtDescIdDesc(Integer receiverId);


//    void findIfAnswerEnable();

    Optional<Letter> findTop1BySender_IdAndReceiver_IdOrderByCreatedAtDesc(int senderId, int receiverId);
}
