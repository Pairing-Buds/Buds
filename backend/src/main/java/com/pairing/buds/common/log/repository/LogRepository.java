package com.pairing.buds.common.log.repository;

import com.pairing.buds.common.log.entity.Log;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LogRepository extends JpaRepository<Log, Long> {

}
