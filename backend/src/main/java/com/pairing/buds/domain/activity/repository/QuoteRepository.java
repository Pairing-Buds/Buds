package com.pairing.buds.domain.activity.repository;

import com.pairing.buds.domain.activity.entity.Quote;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface QuoteRepository extends JpaRepository<Quote, Integer> {


}
