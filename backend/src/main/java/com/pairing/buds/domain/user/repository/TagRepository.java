package com.pairing.buds.domain.user.repository;

import com.pairing.buds.domain.user.entity.Tag;
import com.pairing.buds.domain.user.entity.User;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Set;

@Repository
public interface TagRepository extends JpaRepository<Tag, Integer> {

    @Query("""
        SELECT DISTINCT u2
          FROM User u2
          JOIN u2.tags t2
         WHERE t2.tagType IN (
               SELECT t1.tagType
                 FROM User u1
                 JOIN u1.tags t1
                WHERE u1.id = :userId
               )
           AND u2.id <> :userId
    """)
         // -- ORDER BY u2.id
    List<User> findTop10RecommendedUsers(
            @Param("userId") Integer userId,
            Pageable pageable
    );
}
