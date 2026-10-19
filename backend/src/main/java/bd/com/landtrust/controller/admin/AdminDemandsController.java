package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.BuyerRequirementEntity;
import bd.com.landtrust.entity.LandInquiryEntity;
import bd.com.landtrust.entity.LandListingEntity;
import bd.com.landtrust.repository.BuyerRequirementRepository;
import bd.com.landtrust.repository.LandInquiryRepository;
import bd.com.landtrust.repository.LandListingRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
public class AdminDemandsController {

    private final BuyerRequirementRepository requirementRepository;
    private final LandListingRepository listingRepository;
    private final LandInquiryRepository inquiryRepository;
    private final NotificationRepository notificationRepository;

    public AdminDemandsController(
            BuyerRequirementRepository requirementRepository,
            LandListingRepository listingRepository,
            LandInquiryRepository inquiryRepository,
            NotificationRepository notificationRepository) {
        this.requirementRepository = requirementRepository;
        this.listingRepository = listingRepository;
        this.inquiryRepository = inquiryRepository;
        this.notificationRepository = notificationRepository;
    }

    @GetMapping("/requirements")
    public ResponseEntity<List<BuyerRequirementEntity>> getAllRequirementsForAdmin() {
        return ResponseEntity.ok(requirementRepository.findAllByOrderByCreatedAtDesc());
    }

    @PutMapping("/requirements/{id}/status")
    public ResponseEntity<?> updateRequirementStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<BuyerRequirementEntity> opt = requirementRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        BuyerRequirementEntity req = opt.get();
        if (body.containsKey("status")) {
            req.setStatus(body.get("status"));
        }
        if (body.containsKey("adminRemark")) {
            req.setAdminRemark(body.get("adminRemark"));
        }
        req = requirementRepository.save(req);

        CommonUtils.notifyUser(notificationRepository, req.getBuyerId(),
                "জমির চাহিদাপত্রের স্ট্যাটাস আপডেট (" + req.getPreferredUpazila() + ")",
                "আপনার চাহিদাপত্রের বর্তমান অবস্থা: " + req.getStatus() + "।"
                        + (req.getAdminRemark() != null && !req.getAdminRemark().isBlank() ? " নোট: " + req.getAdminRemark() : ""));

        return ResponseEntity.ok(req);
    }

    @GetMapping("/inquiries")
    public ResponseEntity<List<Map<String, Object>>> getAllInquiries() {
        List<LandInquiryEntity> list = inquiryRepository.findAllByOrderByCreatedAtDesc();
        Map<Long, LandListingEntity> listingMap = listingRepository.findAll().stream()
                .collect(Collectors.toMap(LandListingEntity::getId, l -> l, (a, b) -> a));

        List<Map<String, Object>> result = new ArrayList<>();
        for (LandInquiryEntity inq : list) {
            Map<String, Object> m = new LinkedHashMap<>();
            m.put("id", inq.getId());
            m.put("listingId", inq.getListingId());
            m.put("listingTitle", inq.getListingTitle());
            m.put("buyerId", inq.getBuyerId());
            m.put("buyerName", inq.getBuyerName());
            m.put("buyerPhone", inq.getBuyerPhone());
            m.put("offeredBudgetBdt", inq.getOfferedBudgetBdt());
            m.put("message", inq.getMessage());
            m.put("status", inq.getStatus());
            m.put("adminNote", inq.getAdminNote());
            m.put("createdAt", inq.getCreatedAt());

            LandListingEntity land = listingMap.get(inq.getListingId());
            if (land != null) {
                m.put("sellerId", land.getSellerId());
                m.put("sellerName", land.getSellerName());
                m.put("sellerPhone", land.getSellerPhone());
                m.put("expectedPriceBdt", land.getExpectedPriceBdt());
                m.put("upazila", land.getUpazila());
            }
            result.add(m);
        }
        return ResponseEntity.ok(result);
    }

    @PutMapping("/inquiries/{id}/status")
    public ResponseEntity<?> updateInquiryStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<LandInquiryEntity> opt = inquiryRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        LandInquiryEntity inq = opt.get();
        if (body.containsKey("status")) inq.setStatus(body.get("status"));
        if (body.containsKey("adminNote")) inq.setAdminNote(body.get("adminNote"));
        inq = inquiryRepository.save(inq);

        CommonUtils.notifyUser(notificationRepository, inq.getBuyerId(),
                "জমিতে আগ্রহ প্রকাশের আপডেট: " + inq.getListingTitle(),
                "অবস্থা: " + inq.getStatus() + (inq.getAdminNote() != null && !inq.getAdminNote().isBlank() ? " | অ্যাডমিন নোট: " + inq.getAdminNote() : ""));

        return ResponseEntity.ok(inq);
    }
}
