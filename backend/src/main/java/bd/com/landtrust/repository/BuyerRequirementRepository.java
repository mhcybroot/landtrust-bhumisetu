package bd.com.landtrust.repository;

import bd.com.landtrust.entity.BuyerRequirementEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BuyerRequirementRepository extends JpaRepository<BuyerRequirementEntity, Long> {
    List<BuyerRequirementEntity> findByBuyerIdOrderByCreatedAtDesc(Long buyerId);
    List<BuyerRequirementEntity> findByStatusInOrderByCreatedAtDesc(List<String> statuses);
    List<BuyerRequirementEntity> findAllByOrderByCreatedAtDesc();
}
