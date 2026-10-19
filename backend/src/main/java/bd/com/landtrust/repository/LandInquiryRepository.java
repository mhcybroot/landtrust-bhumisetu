package bd.com.landtrust.repository;

import bd.com.landtrust.entity.LandInquiryEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LandInquiryRepository extends JpaRepository<LandInquiryEntity, Long> {
    List<LandInquiryEntity> findByBuyerIdOrderByCreatedAtDesc(Long buyerId);
    List<LandInquiryEntity> findAllByOrderByCreatedAtDesc();
}
