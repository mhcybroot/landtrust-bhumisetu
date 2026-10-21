package bd.com.landtrust.repository;

import bd.com.landtrust.entity.ChatConversationEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface ChatConversationRepository extends JpaRepository<ChatConversationEntity, Long> {
    List<ChatConversationEntity> findByUserIdOrderByLastMessageAtDesc(Long userId);
    List<ChatConversationEntity> findAllByOrderByLastMessageAtDesc();
    Optional<ChatConversationEntity> findByUserIdAndListingId(Long userId, Long listingId);
    long countByUnreadAdminCountGreaterThan(int val);
}
