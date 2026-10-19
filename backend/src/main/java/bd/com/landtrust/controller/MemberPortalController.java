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
    private final FinancialTransactionRepository transactionRepository;
    private final NotificationRepository notificationRepository;

    public MemberPortalController(
            UserRepository userRepository,
            LandListingRepository listingRepository,
            BuyerRequirementRepository requirementRepository,
            LandInquiryRepository inquiryRepository,
            ServiceProposalRepository proposalRepository,
            CommissionEntryRepository commissionRepository,
            FinancialTransactionRepository transactionRepository,
            NotificationRepository notificationRepository) {
        this.userRepository = userRepository;
        this.listingRepository = listingRepository;
        this.requirementRepository = requirementRepository;
        this.inquiryRepository = inquiryRepository;
        this.proposalRepository = proposalRepository;
        this.commissionRepository = commissionRepository;
        this.transactionRepository = transactionRepository;
        this.notificationRepository = notificationRepository;
    }

    private UserEntity currentUser(Authentication auth) {
        UserEntity u = (UserEntity) auth.getPrincipal();
        return userRepository.findById(u.getId()).orElse(u);
    }

    // ==================== NOTIFICATIONS & PAYMENT RESUBMISSION ====================

    @GetMapping("/notifications")
    public ResponseEntity<Map<String, Object>> getMyNotifications(Authentication auth) {
        UserEntity user = currentUser(auth);
        List<NotificationEntity> list = notificationRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        long unreadCount = notificationRepository.countByUserIdAndReadStatusFalse(user.getId());
        Map<String, Object> res = new LinkedHashMap<>();
        res.put("unreadCount", unreadCount);
        res.put("notifications", list);
        return ResponseEntity.ok(res);
    }

    @PutMapping("/notifications/read-all")
    public ResponseEntity<?> markNotificationsRead(Authentication auth) {
        UserEntity user = currentUser(auth);
        List<NotificationEntity> list = notificationRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        for (NotificationEntity n : list) {
            if (!n.isReadStatus()) {
                n.setReadStatus(true);
                notificationRepository.save(n);
            }
        }
        return ResponseEntity.ok(Map.of("message", "সকল নোটিফিকেশন পঠিত হিসেবে চিহ্নিত হয়েছে।"));
    }

    @PutMapping("/resubmit-payment")
    public ResponseEntity<?> resubmitPayment(Authentication auth, @RequestBody Map<String, String> body) {
        UserEntity user = currentUser(auth);
        String paymentMethod = body.getOrDefault("paymentMethod", user.getPaymentMethod());
        String senderPhone = body.getOrDefault("senderPhone", user.getSenderPhone()).trim();
        String transactionId = body.getOrDefault("transactionId", "").trim();

        if (transactionId.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "সঠিক ট্রানজেকশন আইডি (TrxID) প্রদান করুন।"));
        }

        user.setPaymentMethod(paymentMethod);
        user.setSenderPhone(senderPhone.isBlank() ? user.getPhoneNumber() : senderPhone);
        user.setTransactionId(transactionId);
        user.setAccountStatus("PAYMENT_SUBMITTED");
        user.setAdminNote("সদস্য পুনরায় সংশোধিত TrxID (" + transactionId + ") জমা দিয়েছেন — যাচাইয়ের অপেক্ষায়।");
        user = userRepository.save(user);

        List<FinancialTransactionEntity> userTxns = transactionRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
        boolean updatedExisting = false;
        for (FinancialTransactionEntity t : userTxns) {
            if ("REG_FEE_FUND".equals(t.getFundBucket()) && !"APPROVED".equals(t.getStatus())) {
                t.setPaymentMethod(paymentMethod);
                t.setSenderPhone(user.getSenderPhone());
                t.setTransactionId(transactionId);
                t.setStatus("PENDING_VERIFICATION");
                t.setDescription(user.getRole() + " নিবন্ধন ফি (পুনঃজমা: " + user.getFullName() + ")");
                transactionRepository.save(t);
                updatedExisting = true;
                break;
            }
        }

        if (!updatedExisting) {
            FinancialTransactionEntity txn = new FinancialTransactionEntity();
            txn.setUserId(user.getId());
            txn.setUserName(user.getFullName());
            txn.setUserRole(user.getRole());
            txn.setFundBucket("REG_FEE_FUND");
            txn.setTxnType("CREDIT");
            txn.setAmountBdt(user.getRegistrationFeeAmount() != null ? user.getRegistrationFeeAmount() : new BigDecimal("500"));
            txn.setPaymentMethod(paymentMethod);
            txn.setSenderPhone(user.getSenderPhone());
            txn.setTransactionId(transactionId);
            txn.setDescription(user.getRole() + " নিবন্ধন ফি (পুনঃজমা: " + user.getFullName() + ")");
            txn.setStatus("PENDING_VERIFICATION");
            transactionRepository.save(txn);
        }

        NotificationEntity n = new NotificationEntity();
        n.setUserId(user.getId());
        n.setTitle("সংশোধিত TrxID জমা হয়েছে");
        n.setMessage("আপনার নতুন TrxID (" + transactionId + ") যাচাইয়ের জন্য অ্যাডমিনের কাছে পাঠানো হয়েছে।");
        notificationRepository.save(n);

        return ResponseEntity.ok(Map.of(
                "user", PublicAndAuthController.sanitizeUser(user),
                "message", "সংশোধিত পেমেন্ট তথ্য সফলভাবে জমা হয়েছে! অ্যাডমিন যাচাই করে সক্রিয় করবেন।"
        ));
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

        String upazila = (String) body.getOrDefault("upazila", "নোয়াখালী সদর");
        String khatianNo = ((String) body.getOrDefault("khatianNo", "")).trim();
        String dagNo = ((String) body.getOrDefault("dagNo", "")).trim();

        LandListingEntity listing = new LandListingEntity();
        listing.setSellerId(user.getId());
        listing.setSellerName(user.getFullName());
        listing.setSellerPhone(user.getPhoneNumber());
        listing.setTitle((String) body.getOrDefault("title", "জমি বিক্রয়ের বিজ্ঞাপন"));
        listing.setDistrict((String) body.getOrDefault("district", "নোয়াখালী"));
        listing.setUpazila(upazila);
        listing.setAreaName((String) body.getOrDefault("areaName", ""));
        listing.setMouzaName((String) body.getOrDefault("mouzaName", ""));
        listing.setKhatianNo(khatianNo);
        listing.setDagNo(dagNo);
        listing.setMutationInfo((String) body.getOrDefault("mutationInfo", "নামজারি ও খাজনা হালনাগাদ"));
        listing.setLandType((String) body.getOrDefault("landType", "আবাসিক"));

        // Automatic Duplicate Khatian / Dag Detection within the same Upazila
        if (!khatianNo.isBlank() || !dagNo.isBlank()) {
            List<LandListingEntity> existingAll = listingRepository.findAll();
            for (LandListingEntity ex : existingAll) {
                if ("REJECTED".equals(ex.getListingStatus())) continue;
                if (upazila.equalsIgnoreCase(ex.getUpazila())) {
                    boolean khatianMatch = !khatianNo.isBlank() && ex.getKhatianNo() != null && khatianNo.equalsIgnoreCase(ex.getKhatianNo().trim());
                    boolean dagMatch = !dagNo.isBlank() && ex.getDagNo() != null && dagNo.equalsIgnoreCase(ex.getDagNo().trim());
                    if (khatianMatch || dagMatch) {
                        listing.setDuplicateSuspected(true);
                        listing.setDuplicateNote("সম্ভাব্য ডুপ্লিকেট: বিজ্ঞাপন #" + ex.getId() + " (" + ex.getTitle() + " - বিক্রেতা: " + ex.getSellerName() + ") এর খতিয়ান/দাগ নম্বরের সাথে মিল পাওয়া গেছে।");
                        break;
                    }
                }
            }
        }

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
        String imgUrl = (String) body.getOrDefault("imageUrl", "");
        listing.setImageUrl(imgUrl.isBlank() ? "https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800" : imgUrl);
        listing.setPrivateDocumentUrl((String) body.getOrDefault("privateDocumentUrl", ""));
        listing.setPrivateDocumentName((String) body.getOrDefault("privateDocumentName", ""));
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

        LandListingEntity land = listingOpt.get();
        LandInquiryEntity inquiry = new LandInquiryEntity();
        inquiry.setListingId(listingId);
        inquiry.setListingTitle(land.getTitle());
        inquiry.setBuyerId(user.getId());
        inquiry.setBuyerName(user.getFullName());
        inquiry.setBuyerPhone(user.getPhoneNumber());
        inquiry.setOfferedBudgetBdt(parseDecimal(body.get("offeredBudgetBdt"), land.getExpectedPriceBdt()));
        inquiry.setMessage((String) body.getOrDefault("message", "এই জমিটি পরিদর্শন ও ক্রয়ের ব্যাপারে আগ্রহী।"));
        inquiry.setStatus("PENDING");

        inquiry = inquiryRepository.save(inquiry);

        // Notify seller (without exposing buyer's phone number!)
        NotificationEntity sellerNotif = new NotificationEntity();
        sellerNotif.setUserId(land.getSellerId());
        sellerNotif.setTitle("আপনার জমিতে একজন ক্রেতা আগ্রহ প্রকাশ করেছেন!");
        sellerNotif.setMessage("‘" + land.getTitle() + "’ বিজ্ঞাপনে একজন যাচাইকৃত ক্রেতা ৳" + inquiry.getOfferedBudgetBdt() + " বাজেটে আগ্রহ প্রকাশ করেছেন। অ্যাডমিন মধ্যস্থতা করছেন।");
        notificationRepository.save(sellerNotif);

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
