package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.LandListingEntity;
import bd.com.landtrust.repository.LandListingRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin")
public class AdminListingController {

    private final LandListingRepository listingRepository;
    private final NotificationRepository notificationRepository;

    public AdminListingController(
            LandListingRepository listingRepository,
            NotificationRepository notificationRepository) {
        this.listingRepository = listingRepository;
        this.notificationRepository = notificationRepository;
    }

    @GetMapping("/listings")
    public ResponseEntity<List<LandListingEntity>> getAllListingsForAdmin() {
        return ResponseEntity.ok(listingRepository.findAllByOrderByCreatedAtDesc());
    }

    @PutMapping("/listings/{id}/status")
    public ResponseEntity<?> updateListingStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<LandListingEntity> opt = listingRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        LandListingEntity listing = opt.get();
        if (body.containsKey("listingStatus")) {
            listing.setListingStatus(body.get("listingStatus"));
        }
        if (body.containsKey("verificationStatus")) {
            listing.setVerificationStatus(body.get("verificationStatus"));
        }
        if (body.containsKey("adminRemark")) {
            listing.setAdminRemark(body.get("adminRemark"));
        }
        listing = listingRepository.save(listing);

        CommonUtils.notifyUser(notificationRepository, listing.getSellerId(),
                "জমির বিজ্ঞাপনের স্ট্যাটাস আপডেট: " + listing.getTitle(),
                "বিজ্ঞাপনের বর্তমান অবস্থা: " + listing.getListingStatus() + " (ব্যাজ: " + listing.getVerificationStatus() + ")।"
                        + (listing.getAdminRemark() != null && !listing.getAdminRemark().isBlank() ? " নোট: " + listing.getAdminRemark() : ""));

        return ResponseEntity.ok(listing);
    }
}
