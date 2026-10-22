package bd.com.landtrust.controller.publicapi;

import bd.com.landtrust.entity.BuyerRequirementEntity;
import bd.com.landtrust.entity.LandListingEntity;
import bd.com.landtrust.entity.LocationEntity;
import bd.com.landtrust.entity.PaymentMethodEntity;
import bd.com.landtrust.entity.SystemSettingEntity;
import bd.com.landtrust.repository.BuyerRequirementRepository;
import bd.com.landtrust.repository.LandListingRepository;
import bd.com.landtrust.repository.LocationRepository;
import bd.com.landtrust.repository.PaymentMethodRepository;
import bd.com.landtrust.repository.SystemSettingRepository;
import bd.com.landtrust.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/public")
public class PublicListingController {

    private final UserRepository userRepository;
    private final SystemSettingRepository settingRepository;
    private final PaymentMethodRepository paymentMethodRepository;
    private final LocationRepository locationRepository;
    private final LandListingRepository listingRepository;
    private final BuyerRequirementRepository requirementRepository;

    public PublicListingController(
            UserRepository userRepository,
            SystemSettingRepository settingRepository,
            PaymentMethodRepository paymentMethodRepository,
            LocationRepository locationRepository,
            LandListingRepository listingRepository,
            BuyerRequirementRepository requirementRepository) {
        this.userRepository = userRepository;
        this.settingRepository = settingRepository;
        this.paymentMethodRepository = paymentMethodRepository;
        this.locationRepository = locationRepository;
        this.listingRepository = listingRepository;
        this.requirementRepository = requirementRepository;
    }

    private SystemSettingEntity getSettings() {
        return settingRepository.findAll().stream().findFirst().orElseGet(() -> {
            SystemSettingEntity def = new SystemSettingEntity();
            return settingRepository.save(def);
        });
    }

    @GetMapping("/config")
    public ResponseEntity<Map<String, Object>> getPublicConfig() {
        SystemSettingEntity settings = getSettings();
        List<PaymentMethodEntity> paymentMethods = paymentMethodRepository.findByActiveTrue();
        List<LocationEntity> locations = locationRepository.findByActiveTrueOrderByDistrictNameBnAscUpazilaNameBnAsc();

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("settings", settings);
        response.put("paymentMethods", paymentMethods);
        response.put("locations", locations);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/listings")
    public ResponseEntity<List<Map<String, Object>>> getPublishedListings(
            @RequestParam(required = false) String district,
            @RequestParam(required = false) String upazila,
            @RequestParam(required = false) String landType,
            @RequestParam(required = false) BigDecimal maxBudget,
            @RequestParam(required = false) String verificationStatus,
            @RequestParam(required = false) String verification,
            @RequestParam(required = false) BigDecimal minArea,
            @RequestParam(required = false) BigDecimal maxArea,
            @RequestParam(required = false) String keyword) {

        String targetVerification = (verificationStatus != null && !verificationStatus.isBlank())
                ? verificationStatus
                : verification;

        List<LandListingEntity> all = listingRepository.findAllByOrderByCreatedAtDesc();
        List<Map<String, Object>> result = all.stream()
                .filter(l -> "APPROVED_PUBLISHED".equals(l.getListingStatus()) || "RESERVED".equals(l.getListingStatus()))
                .filter(l -> district == null || district.isBlank() || district.equalsIgnoreCase(l.getDistrict()))
                .filter(l -> upazila == null || upazila.isBlank() || upazila.equalsIgnoreCase(l.getUpazila()))
                .filter(l -> landType == null || landType.isBlank() || landType.equalsIgnoreCase(l.getLandType()))
                .filter(l -> maxBudget == null || l.getExpectedPriceBdt().compareTo(maxBudget) <= 0)
                .filter(l -> targetVerification == null || targetVerification.isBlank() || targetVerification.equalsIgnoreCase(l.getVerificationStatus()))
                .filter(l -> minArea == null || (l.getAreaDecimal() != null && l.getAreaDecimal().compareTo(minArea) >= 0))
                .filter(l -> maxArea == null || (l.getAreaDecimal() != null && l.getAreaDecimal().compareTo(maxArea) <= 0))
                .filter(l -> {
                    if (keyword == null || keyword.isBlank()) return true;
                    String kw = keyword.trim().toLowerCase();
                    return (l.getTitle() != null && l.getTitle().toLowerCase().contains(kw))
                            || (l.getAreaName() != null && l.getAreaName().toLowerCase().contains(kw))
                            || (l.getMouzaName() != null && l.getMouzaName().toLowerCase().contains(kw))
                            || (l.getUpazila() != null && l.getUpazila().toLowerCase().contains(kw))
                            || (l.getDistrict() != null && l.getDistrict().toLowerCase().contains(kw))
                            || (l.getDescription() != null && l.getDescription().toLowerCase().contains(kw));
                })
                .map(this::toPublicListingMap)
                .collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }

    @PostMapping("/listings/{id}/share")
    public ResponseEntity<?> recordListingShare(@PathVariable Long id, @RequestParam(required = false) String channel) {
        return ResponseEntity.ok(Map.of("status", "SUCCESS", "message", "শেয়ার সফল হয়েছে"));
    }

    private Map<String, Object> toPublicListingMap(LandListingEntity l) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", l.getId());
        m.put("title", l.getTitle());
        m.put("district", l.getDistrict());
        m.put("upazila", l.getUpazila());
        m.put("subArea", l.getSubArea());
        m.put("isFeatured", l.isFeatured());
        m.put("areaName", l.getAreaName());
        m.put("mouzaName", l.getMouzaName());
        m.put("landType", l.getLandType());
        m.put("areaDecimal", l.getAreaDecimal());
        m.put("expectedPriceBdt", l.getExpectedPriceBdt());
        m.put("pricePerDecimalBdt", l.getPricePerDecimalBdt());
        m.put("roadAccessInfo", l.getRoadAccessInfo());
        m.put("description", l.getDescription());
        m.put("imageUrl", l.getImageUrl());
        m.put("additionalImageUrls", l.getAdditionalImageUrls());
        m.put("videoUrl", l.getVideoUrl());
        m.put("mapLink", l.getMapLink());
        m.put("verificationStatus", l.getVerificationStatus());
        m.put("listingStatus", l.getListingStatus());
        m.put("createdAt", l.getCreatedAt());
        m.put("sellerContactNote", "প্ল্যাটফর্মের মাধ্যমে যাচাইকৃত সংযোগ (সরাসরি নম্বর গোপন রাখা হয়েছে)");
        return m;
    }

    @GetMapping("/requirements")
    public ResponseEntity<List<Map<String, Object>>> getPublicBuyerRequirements(
            @RequestParam(required = false) String upazila,
            @RequestParam(required = false) String landType) {

        List<BuyerRequirementEntity> activeReqs = requirementRepository
                .findByStatusInOrderByCreatedAtDesc(List.of("ACTIVE", "MATCHED"));

        List<Map<String, Object>> result = activeReqs.stream()
                .filter(r -> upazila == null || upazila.isBlank() || upazila.equalsIgnoreCase(r.getPreferredUpazila()))
                .filter(r -> landType == null || landType.isBlank() || landType.equalsIgnoreCase(r.getLandType()))
                .map(r -> {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("id", r.getId());
                    m.put("buyerName", r.getBuyerName());
                    m.put("preferredDistrict", r.getPreferredDistrict());
                    m.put("preferredUpazila", r.getPreferredUpazila());
                    m.put("preferredArea", r.getPreferredArea());
                    m.put("landType", r.getLandType());
                    m.put("minAreaDecimal", r.getMinAreaDecimal());
                    m.put("maxAreaDecimal", r.getMaxAreaDecimal());
                    m.put("minBudgetBdt", r.getMinBudgetBdt());
                    m.put("maxBudgetBdt", r.getMaxBudgetBdt());
                    m.put("purpose", r.getPurpose());
                    m.put("purchaseTimeline", r.getPurchaseTimeline());
                    m.put("specialRequirements", r.getSpecialRequirements());
                    m.put("status", r.getStatus());
                    m.put("createdAt", r.getCreatedAt());
                    return m;
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }

    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getPublicStats() {
        long publishedListings = listingRepository.findAll().stream()
                .filter(l -> "APPROVED_PUBLISHED".equals(l.getListingStatus()) || "RESERVED".equals(l.getListingStatus()))
                .count();
        long activeBuyers = requirementRepository.findAll().stream()
                .filter(r -> "ACTIVE".equals(r.getStatus()) || "MATCHED".equals(r.getStatus()))
                .count();
        long officers = userRepository.findByRoleOrderByCreatedAtDesc("MARKETING_OFFICER").size();
        long upazilas = locationRepository.findByActiveTrueOrderByDistrictNameBnAscUpazilaNameBnAsc().size();

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("publishedListings", publishedListings);
        stats.put("activeBuyerRequirements", activeBuyers);
        stats.put("marketingOfficers", officers);
        stats.put("coveredUpazilas", upazilas);
        return ResponseEntity.ok(stats);
    }

    @PostMapping("/request-account-deletion")
    public ResponseEntity<?> requestAccountDeletion(@RequestBody Map<String, String> body) {
        String phone = body.getOrDefault("phoneNumber", "").trim();
        String reason = body.getOrDefault("reason", "").trim();
        String comments = body.getOrDefault("comments", "").trim();

        if (phone.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "মোবাইল নম্বর আবশ্যক।"));
        }

        Optional<bd.com.landtrust.entity.UserEntity> userOpt = userRepository.findByPhoneNumber(phone);
        if (userOpt.isPresent()) {
            bd.com.landtrust.entity.UserEntity u = userOpt.get();
            u.setAccountStatus("DELETION_REQUESTED");
            u.setAdminNote("ইউজার ওয়েবফর্ম থেকে অ্যাকাউন্ট মোছার অনুরোধ করেছেন। কারণ: " + reason + " | মন্তব্য: " + comments);
            userRepository.save(u);
        }

        return ResponseEntity.ok(Map.of(
                "status", "SUCCESS",
                "message", "আপনার অ্যাকাউন্ট ও ডেটা মুছে ফেলার অনুরোধ সফলভাবে গৃহীত হয়েছে। আমাদের টিম আগামী ৪৮ ঘণ্টার মধ্যে ডেটা স্থায়ীভাবে মুছে ফেলবে।"
        ));
    }
}
