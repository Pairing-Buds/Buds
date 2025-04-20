package com.pairing.buds.domain.chat.repository;

import com.pairing.buds.domain.chat.entity.ChatRoom;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

// @Repository ?
public interface ChatRoomRepository extends JpaRepository<ChatRoom, Integer> {
}
