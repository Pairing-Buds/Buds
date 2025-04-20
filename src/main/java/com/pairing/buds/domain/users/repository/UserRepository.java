package com.pairing.buds.domain.users.repository;

import com.pairing.buds.domain.users.entity.Users;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserRepository extends JpaRepository<Users, Integer> {
}
