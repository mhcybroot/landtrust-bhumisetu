package bd.com.landtrust.repository;

import bd.com.landtrust.entity.LandListingEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface LandListingRepository extends JpaRepository<LandListingEntity, Long> {
    List<LandListingEntity> findByListingStatusOrderByCreatedAtDesc(String listingStatus);
    List<LandListingEntity> findByListingStatusInOrderByCreatedAtDesc(List<String> statuses);
    List<LandListingEntity> findBySellerIdOrderByCreatedAtDesc(Long sellerId);
    List<LandListingEntity> findAllByOrderByCreatedAtDesc();

    Optional<LandListingEntity> findFirstByUpazilaIgnoreCaseAndListingStatusNotAndKhatianNoIgnoreCase(String upazila, String listingStatus, String khatianNo);
    Optional<LandListingEntity> findFirstByUpazilaIgnoreCaseAndListingStatusNotAndDagNoIgnoreCase(String upazila, String listingStatus, String dagNo);
}
