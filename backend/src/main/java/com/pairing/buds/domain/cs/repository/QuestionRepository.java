package com.pairing.buds.domain.cs.repository;

import com.pairing.buds.domain.cs.dto.answer.res.GetAnsweredQuestionListReqDto;
import com.pairing.buds.domain.cs.dto.answer.res.GetUnAnsweredQuestionListReqDto;
import com.pairing.buds.domain.cs.entity.Question;
import com.pairing.buds.domain.cs.entity.QuestionStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface QuestionRepository extends JpaRepository<Question, Integer> {

    @Query(value = """
            SELECT new com.pairing.buds.domain.cs.dto.answer.res.GetAnsweredQuestionListReqDto(
                q.user.id,
                MAX(q.createdAt)
            )
            FROM Question q
            WHERE q.status = :questionStatus
            GROUP BY q.user.id
            ORDER BY MAX(q.createdAt) DESC
            """
    )
    List<GetAnsweredQuestionListReqDto> findAnsweredQuestionsByStatusOrderByCreatedAt(@Param("questionStatus") QuestionStatus questionStatus);

    @Query(value = """
            SELECT new com.pairing.buds.domain.cs.dto.answer.res.GetUnAnsweredQuestionListReqDto(
                q.user.id,
                MAX(q.createdAt)
            )
            FROM Question q
            WHERE q.status = :questionStatus
            GROUP BY q.user.id
            ORDER BY MAX(q.createdAt) DESC
            """
            )
    List<GetUnAnsweredQuestionListReqDto> findUnAnsweredQuestionsByStatusOrderByCreatedAt(@Param("questionStatus") QuestionStatus questionStatus);
}
