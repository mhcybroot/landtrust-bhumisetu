package bd.com.landtrust.repository;

import bd.com.landtrust.entity.CommissionEntryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CommissionEntryRepository extends JpaRepository<CommissionEntryEntity, Long> {
    List<CommissionEntryEntity> findByOfficerIdOrderByCreatedAtDesc(Long officerId);
    List<CommissionEntryEntity> findByReferredUserIdOrderByCreatedAtDesc(Long referredUserId);
    List<CommissionEntryEntity> findAllByOrderByCreatedAtDesc();
}
