package com.pairing.buds.domain.activity.repository;

import com.pairing.buds.domain.activity.entity.Activity;
import com.pairing.buds.domain.activity.entity.PageName;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface ActivityRepository extends JpaRepository<Activity, Integer> {
    @Modifying
    @Query(value = """
        INSERT IGNORE INTO user_page_visits(user_id, page_name)
        VALUES(:userId, :pageName)
    """, nativeQuery = true)
    int insertIgnore(@Param("userId") int userId, @Param("pageName") PageName pageName);

    default boolean isVisited(int userId, PageName pageName){
        return insertIgnore(userId, pageName) > 0;
    }
}
