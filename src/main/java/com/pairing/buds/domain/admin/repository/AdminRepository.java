package com.pairing.buds.domain.admin.repository;

import com.pairing.buds.domain.admin.entity.Admin;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AdminRepository extends JpaRepository<Admin, Integer> {
}
