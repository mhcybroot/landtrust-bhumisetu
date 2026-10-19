package bd.com.landtrust.repository;

import bd.com.landtrust.entity.NotificationEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface NotificationRepository extends JpaRepository<NotificationEntity, Long> {
    List<NotificationEntity> findByUserIdOrderByCreatedAtDesc(Long userId);
    long countByUserIdAndReadStatusFalse(Long userId);
}
