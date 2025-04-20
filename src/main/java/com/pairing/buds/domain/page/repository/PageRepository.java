package com.pairing.buds.domain.page.repository;

import com.pairing.buds.domain.page.entity.Page;
import org.springframework.data.jpa.repository.JpaRepository;

// @Repository
public interface PageRepository extends JpaRepository<Page, Integer> {
}
