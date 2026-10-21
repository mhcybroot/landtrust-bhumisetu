package bd.com.landtrust.repository;

import bd.com.landtrust.entity.ChatMessageEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessageEntity, Long> {
    List<ChatMessageEntity> findByConversationIdOrderByCreatedAtAsc(Long conversationId);
}
