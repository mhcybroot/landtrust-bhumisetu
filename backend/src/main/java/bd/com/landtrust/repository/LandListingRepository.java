package bd.com.landtrust.repository;

import bd.com.landtrust.entity.LandListingEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LandListingRepository extends JpaRepository<LandListingEntity, Long> {
    List<LandListingEntity> findByListingStatusOrderByCreatedAtDesc(String listingStatus);
    List<LandListingEntity> findBySellerIdOrderByCreatedAtDesc(Long sellerId);
    List<LandListingEntity> findAllByOrderByCreatedAtDesc();
}
