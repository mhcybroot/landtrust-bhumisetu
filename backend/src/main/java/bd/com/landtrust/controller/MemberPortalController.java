package bd.com.landtrust.controller;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

@RestController
@RequestMapping("/api/portal")
public class MemberPortalController {

    private final UserRepository userRepository;
    private final LandListingRepository listingRepository;
    private final BuyerRequirementRepository requirementRepository;
    private final LandInquiryRepository inquiryRepository;
    private final ServiceProposalRepository proposalRepository;
    private final CommissionEntryRepository commissionRepository;

    public MemberPortalController(
            UserRepository userRepository,
            LandListingRepository listingRepository,
            BuyerRequirementRepository requirementRepository,
            LandInquiryRepository inquiryRepository,
            ServiceProposalRepository proposalRepository,
            CommissionEntryRepository commissionRepository) {
        this.userRepository = userRepository;
        this.listingRepository = listingRepository;
        this.requirementRepository = requirementRepository;
        this.inquiryRepository = inquiryRepository;
        this.proposalRepository = proposalRepository;
        this.commissionRepository = commissionRepository;
    }

    private UserEntity currentUser(Authentication auth) {
        UserEntity u = (UserEntity) auth.getPrincipal();
        return userRepository.findById(u.getId()).orElse(u);
    }

    // ==================== SELLER ENDPOINTS ====================

    @GetMapping("/my-listings")
    public ResponseEntity<List<LandListingEntity>> getMyListings(Authentication auth) {
        UserEntity user = currentUser(auth);
        return ResponseEntity.ok(listingRepository.findBySellerIdOrderByCreatedAtDesc(user.getId()));
    }

    @PostMapping("/listings")
    public ResponseEntity<?> createListing(Authentication auth, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);

        LandListingEntity listing = new LandListingEntity();
        listing.setSellerId(user.getId());
        listing.setSellerName(user.getFullName());
        listing.setSellerPhone(user.getPhoneNumber());
        listing.setTitle((String) body.getOrDefault("title", "জমি বিক্রয়ের বিজ্ঞাপন"));
        listing.setDistrict((String) body.getOrDefault("district", "নোয়াখালী"));
        listing.setUpazila((String) body.getOrDefault("upazila", "নোয়াখালী সদর"));
        listing.setAreaName((String) body.getOrDefault("areaName", ""));
        listing.setMouzaName((String) body.getOrDefault("mouzaName", ""));
        listing.setKhatianNo((String) body.getOrDefault("khatianNo", ""));
        listing.setDagNo((String) body.getOrDefault("dagNo", ""));
        listing.setMutationInfo((String) body.getOrDefault("mutationInfo", "নামজারি ও খাজনা হালনাগাদ"));
        listing.setLandType((String) body.getOrDefault("landType", "আবাসিক"));

        BigDecimal areaDecimal = parseDecimal(body.get("areaDecimal"), new BigDecimal("10"));
        BigDecimal expectedPrice = parseDecimal(body.get("expectedPriceBdt"), new BigDecimal("1000000"));
        BigDecimal proposedFee = parseDecimal(body.get("proposedServiceFeeBdt"), BigDecimal.ZERO);

        listing.setAreaDecimal(areaDecimal);
        listing.setExpectedPriceBdt(expectedPrice);
        if (areaDecimal.compareTo(BigDecimal.ZERO) > 0) {
            listing.setPricePerDecimalBdt(expectedPrice.divide(areaDecimal, 0, RoundingMode.HALF_UP));
        } else {
            listing.setPricePerDecimalBdt(expectedPrice);
        }
        listing.setRoadAccessInfo((String) body.getOrDefault("roadAccessInfo", "১২ ফুট পাকা রাস্তা সংলগ্ন"));
        listing.setDescription((String) body.getOrDefault("description", ""));
        listing.setImageUrl((String) body.getOrDefault("imageUrl", "https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800"));
        listing.setProposedServiceFeeBdt(proposedFee);
        listing.setVerificationStatus("SUBMITTED");
        listing.setListingStatus("SUBMITTED");

        listing = listingRepository.save(listing);
        return ResponseEntity.ok(listing);
    }

    @PutMapping("/listings/{id}/close")
    public ResponseEntity<?> closeMyListing(Authentication auth, @PathVariable Long id) {
        UserEntity user = currentUser(auth);
        Optional<LandListingEntity> opt = listingRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getSellerId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }
        LandListingEntity l = opt.get();
        l.setListingStatus("SOLD");
        listingRepository.save(l);
        return ResponseEntity.ok(l);
    }

    // ==================== BUYER ENDPOINTS ====================

    @GetMapping("/my-requirements")
    public ResponseEntity<List<BuyerRequirementEntity>> getMyRequirements(Authentication auth) {
        UserEntity user = currentUser(auth);
        return ResponseEntity.ok(requirementRepository.findByBuyerIdOrderByCreatedAtDesc(user.getId()));
    }

    @PostMapping("/requirements")
    public ResponseEntity<?> createRequirement(Authentication auth, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);

        BuyerRequirementEntity req = new BuyerRequirementEntity();
        req.setBuyerId(user.getId());
        req.setBuyerName(user.getFullName());
        req.setBuyerPhone(user.getPhoneNumber());
        req.setPreferredDistrict((String) body.getOrDefault("preferredDistrict", "নোয়াখালী"));
        req.setPreferredUpazila((String) body.getOrDefault("preferredUpazila", "নোয়াখালী সদর"));
        req.setPreferredArea((String) body.getOrDefault("preferredArea", ""));
        req.setLandType((String) body.getOrDefault("landType", "আবাসিক"));
        req.setMinAreaDecimal(parseDecimal(body.get("minAreaDecimal"), new BigDecimal("5")));
        req.setMaxAreaDecimal(parseDecimal(body.get("maxAreaDecimal"), new BigDecimal("20")));
        req.setMinBudgetBdt(parseDecimal(body.get("minBudgetBdt"), new BigDecimal("1000000")));
        req.setMaxBudgetBdt(parseDecimal(body.get("maxBudgetBdt"), new BigDecimal("3000000")));
        req.setPurpose((String) body.getOrDefault("purpose", "বাড়ি নির্মাণ"));
        req.setPurchaseTimeline((String) body.getOrDefault("purchaseTimeline", "১-৩ মাসের মধ্যে"));
        req.setProposedServiceFeeBdt(parseDecimal(body.get("proposedServiceFeeBdt"), BigDecimal.ZERO));
        req.setSpecialRequirements((String) body.getOrDefault("specialRequirements", ""));
        req.setStatus("SUBMITTED");

        req = requirementRepository.save(req);
        return ResponseEntity.ok(req);
    }

    @PostMapping("/inquiries")
    public ResponseEntity<?> createInquiry(Authentication auth, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        Long listingId = Long.valueOf(String.valueOf(body.get("listingId")));
        Optional<LandListingEntity> listingOpt = listingRepository.findById(listingId);
        if (listingOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "জমির বিজ্ঞাপন পাওয়া যায়নি।"));
        }

        LandInquiryEntity inquiry = new LandInquiryEntity();
        inquiry.setListingId(listingId);
        inquiry.setListingTitle(listingOpt.get().getTitle());
        inquiry.setBuyerId(user.getId());
        inquiry.setBuyerName(user.getFullName());
        inquiry.setBuyerPhone(user.getPhoneNumber());
        inquiry.setOfferedBudgetBdt(parseDecimal(body.get("offeredBudgetBdt"), listingOpt.get().getExpectedPriceBdt()));
        inquiry.setMessage((String) body.getOrDefault("message", "এই জমিটি পরিদর্শন ও ক্রয়ের ব্যাপারে আগ্রহী।"));
        inquiry.setStatus("PENDING");

        inquiry = inquiryRepository.save(inquiry);
        return ResponseEntity.ok(inquiry);
    }

    @GetMapping("/my-inquiries")
    public ResponseEntity<List<LandInquiryEntity>> getMyInquiries(Authentication auth) {
        UserEntity user = currentUser(auth);
        return ResponseEntity.ok(inquiryRepository.findByBuyerIdOrderByCreatedAtDesc(user.getId()));
    }

    // ==================== MARKETING OFFICER PORTAL (REFERRAL & COMMISSION) ====================

    @GetMapping("/officer-dashboard")
    public ResponseEntity<Map<String, Object>> getOfficerDashboard(Authentication auth) {
        UserEntity officer = currentUser(auth);
        List<UserEntity> referredUsers = userRepository.findByReferredByOfficerIdOrderByCreatedAtDesc(officer.getId());
        List<CommissionEntryEntity> commissions = commissionRepository.findByOfficerIdOrderByCreatedAtDesc(officer.getId());

        // Map each referred user with their name, role, status, and total commission earned from them
        List<Map<String, Object>> referredUsersView = new ArrayList<>();
        for (UserEntity ru : referredUsers) {
            BigDecimal earnedFromUser = commissions.stream()
                    .filter(c -> c.getReferredUserId().equals(ru.getId()) && !"CANCELLED".equals(c.getStatus()))
                    .map(CommissionEntryEntity::getCommissionAmountBdt)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);

            Map<String, Object> item = new LinkedHashMap<>();
            item.put("userId", ru.getId());
            item.put("fullName", ru.getFullName());
            item.put("role", ru.getRole());
            item.put("phoneNumber", ru.getPhoneNumber());
            item.put("district", ru.getDistrict());
            item.put("upazila", ru.getUpazila());
            item.put("accountStatus", ru.getAccountStatus());
            item.put("createdAt", ru.getCreatedAt());
            item.put("commissionEarnedFromUser", earnedFromUser);
            referredUsersView.add(item);
        }

        BigDecimal totalEarned = commissions.stream()
                .filter(c -> !"CANCELLED".equals(c.getStatus()))
                .map(CommissionEntryEntity::getCommissionAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalPaid = commissions.stream()
                .filter(c -> "PAID".equals(c.getStatus()))
                .map(CommissionEntryEntity::getCommissionAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal pendingPayable = totalEarned.subtract(totalPaid);

        long verifiedCount = referredUsers.stream()
                .filter(u -> "ACTIVE".equals(u.getAccountStatus()))
                .count();

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("officer", PublicAndAuthController.sanitizeUser(officer));
        response.put("referralCode", officer.getMyReferralCode());
        response.put("totalReferredCount", referredUsers.size());
        response.put("verifiedReferredCount", verifiedCount);
        response.put("totalEarnedCommission", totalEarned);
        response.put("totalPaidCommission", totalPaid);
        response.put("pendingPayableCommission", pendingPayable);
        response.put("referredUsers", referredUsersView);
        response.put("commissions", commissions);
        return ResponseEntity.ok(response);
    }

    // ==================== SPECIAL SERVICE PROPOSALS ====================

    @GetMapping("/my-proposals")
    public ResponseEntity<List<ServiceProposalEntity>> getMyProposals(Authentication auth) {
        UserEntity user = currentUser(auth);
        return ResponseEntity.ok(proposalRepository.findByUserIdOrderByCreatedAtDesc(user.getId()));
    }

    @PostMapping("/proposals")
    public ResponseEntity<ServiceProposalEntity> createProposal(Authentication auth, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        ServiceProposalEntity p = new ServiceProposalEntity();
        p.setUserId(user.getId());
        p.setUserName(user.getFullName());
        p.setUserPhone(user.getPhoneNumber());
        p.setUserRole(user.getRole());
        p.setProposalTitle((String) body.getOrDefault("proposalTitle", "বিশেষ ক্রয়/বিক্রয় সহায়তা প্রস্তাব"));
        p.setScopeDescription((String) body.getOrDefault("scopeDescription", ""));
        p.setCustomerProposedFeeBdt(parseDecimal(body.get("customerProposedFeeBdt"), new BigDecimal("100000")));
        p.setTimelineTerms((String) body.getOrDefault("timelineTerms", "৩ মাস"));
        p.setPaymentTerms((String) body.getOrDefault("paymentTerms", "চুক্তি ও দলিল সম্পাদনের পর পরিশোধযোগ্য"));
        p.setStatus("CUSTOMER_PROPOSED");
        return ResponseEntity.ok(proposalRepository.save(p));
    }

    @PutMapping("/proposals/{id}/accept-counter")
    public ResponseEntity<?> acceptCounterOffer(Authentication auth, @PathVariable Long id) {
        UserEntity user = currentUser(auth);
        Optional<ServiceProposalEntity> opt = proposalRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getUserId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }
        ServiceProposalEntity p = opt.get();
        if (p.getAdminCounterFeeBdt() != null) {
            p.setFinalAgreedFeeBdt(p.getAdminCounterFeeBdt());
        } else {
            p.setFinalAgreedFeeBdt(p.getCustomerProposedFeeBdt());
        }
        p.setStatus("MUTUALLY_AGREED");
        return ResponseEntity.ok(proposalRepository.save(p));
    }

    private BigDecimal parseDecimal(Object val, BigDecimal fallback) {
        if (val == null) return fallback;
        try {
            return new BigDecimal(String.valueOf(val).trim());
        } catch (Exception e) {
            return fallback;
        }
    }
}
