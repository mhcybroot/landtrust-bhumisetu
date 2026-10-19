package bd.com.landtrust.repository;

import bd.com.landtrust.entity.ServiceProposalEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ServiceProposalRepository extends JpaRepository<ServiceProposalEntity, Long> {
    List<ServiceProposalEntity> findByUserIdOrderByCreatedAtDesc(Long userId);
    List<ServiceProposalEntity> findAllByOrderByCreatedAtDesc();
}
