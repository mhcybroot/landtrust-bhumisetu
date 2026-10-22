package bd.com.landtrust.repository;

import bd.com.landtrust.entity.NrbServiceRequestEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NrbServiceRequestRepository extends JpaRepository<NrbServiceRequestEntity, Long> {
    List<NrbServiceRequestEntity> findByUserIdOrderByCreatedAtDesc(Long userId);
    List<NrbServiceRequestEntity> findAllByOrderByCreatedAtDesc();
    List<NrbServiceRequestEntity> findByAssignedAgentIdOrderByCreatedAtDesc(Long assignedAgentId);
}
