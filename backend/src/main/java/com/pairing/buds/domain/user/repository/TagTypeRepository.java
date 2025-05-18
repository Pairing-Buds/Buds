package com.pairing.buds.domain.user.repository;

import com.pairing.buds.domain.user.entity.TagType;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TagTypeRepository extends JpaRepository<TagType, Integer> {
    Optional<TagType> findByTagName(String newTag);
}
