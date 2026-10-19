package bd.com.landtrust.controller;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
public class AdminController {

    private final UserRepository userRepository;
    private final SystemSettingRepository settingRepository;
    private final PaymentMethodRepository paymentMethodRepository;
    private final LocationRepository locationRepository;
    private final LandListingRepository listingRepository;
    private final BuyerRequirementRepository requirementRepository;
    private final LandInquiryRepository inquiryRepository;
    private final ServiceProposalRepository proposalRepository;
    private final CommissionEntryRepository commissionRepository;
    private final FinancialTransactionRepository transactionRepository;
    private final NotificationRepository notificationRepository;

    public AdminController(
            UserRepository userRepository,
            SystemSettingRepository settingRepository,
            PaymentMethodRepository paymentMethodRepository,
            LocationRepository locationRepository,
            LandListingRepository listingRepository,
            BuyerRequirementRepository requirementRepository,
            LandInquiryRepository inquiryRepository,
            ServiceProposalRepository proposalRepository,
            CommissionEntryRepository commissionRepository,
            FinancialTransactionRepository transactionRepository,
            NotificationRepository notificationRepository) {
        this.userRepository = userRepository;
        this.settingRepository = settingRepository;
        this.paymentMethodRepository = paymentMethodRepository;
        this.locationRepository = locationRepository;
        this.listingRepository = listingRepository;
        this.requirementRepository = requirementRepository;
        this.inquiryRepository = inquiryRepository;
        this.proposalRepository = proposalRepository;
        this.commissionRepository = commissionRepository;
        this.transactionRepository = transactionRepository;
        this.notificationRepository = notificationRepository;
    }

    private void notifyUser(Long userId, String title, String message) {
        if (userId == null) return;
        NotificationEntity n = new NotificationEntity();
        n.setUserId(userId);
        n.setTitle(title);
        n.setMessage(message);
        notificationRepository.save(n);
    }

    private SystemSettingEntity getSettings() {
        return settingRepository.findAll().stream().findFirst().orElseGet(() -> {
            SystemSettingEntity def = new SystemSettingEntity();
            return settingRepository.save(def);
        });
    }

    // ==================== CENTRAL DASHBOARD & AUTO-MATCHING ====================

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getAdminDashboard() {
        List<UserEntity> users = userRepository.findAllByOrderByCreatedAtDesc();
        List<LandListingEntity> listings = listingRepository.findAllByOrderByCreatedAtDesc();
        List<BuyerRequirementEntity> requirements = requirementRepository.findAllByOrderByCreatedAtDesc();
        List<FinancialTransactionEntity> transactions = transactionRepository.findAllByOrderByCreatedAtDesc();
        List<CommissionEntryEntity> commissions = commissionRepository.findAllByOrderByCreatedAtDesc();
        SystemSettingEntity settings = getSettings();

        long totalBuyers = users.stream().filter(u -> "BUYER".equals(u.getRole())).count();
        long totalSellers = users.stream().filter(u -> "SELLER".equals(u.getRole())).count();
        long totalOfficers = users.stream().filter(u -> "MARKETING_OFFICER".equals(u.getRole())).count();
        long pendingUsers = users.stream().filter(u -> "PAYMENT_SUBMITTED".equals(u.getAccountStatus())).count();

        // 3-Fund Financial Calculations (No Lock on Reserve Fund! Only Advisory Display)
        BigDecimal regFeeCollected = sumTransactions(transactions, "REG_FEE_FUND", "CREDIT", "APPROVED");
        BigDecimal regFeePending = sumTransactions(transactions, "REG_FEE_FUND", "CREDIT", "PENDING_VERIFICATION");
        BigDecimal regFeeRefunded = sumTransactions(transactions, "REG_FEE_FUND", "REFUND", "APPROVED");

        BigDecimal serviceRevenue = sumTransactions(transactions, "SERVICE_REVENUE", "CREDIT", "APPROVED");
        BigDecimal operationalExpenses = sumTransactions(transactions, "OPERATIONAL_EXPENSE", "DEBIT", "APPROVED");

        BigDecimal totalCommissionEarned = commissions.stream()
                .filter(c -> !"CANCELLED".equals(c.getStatus()))
                .map(CommissionEntryEntity::getCommissionAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalCommissionPaid = commissions.stream()
                .filter(c -> "PAID".equals(c.getStatus()))
                .map(CommissionEntryEntity::getCommissionAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal pendingCommissionPayable = totalCommissionEarned.subtract(totalCommissionPaid);

        // Advisory Reserve calculation (purely recommendation, no fund locking!)
        BigDecimal netRegFee = regFeeCollected.subtract(regFeeRefunded);
        BigDecimal advisoryReserveAmount = netRegFee
                .multiply(settings.getAdvisoryReservePercent())
                .divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP);

        BigDecimal totalInflow = netRegFee.add(serviceRevenue);
        BigDecimal totalOutflow = operationalExpenses.add(totalCommissionPaid);
        BigDecimal netOperatingBalance = totalInflow.subtract(totalOutflow);

        // Auto-Matching Engine between Buyer Requirements and Land Listings
        List<Map<String, Object>> autoMatches = computeAutoMatches(listings, requirements);

        Map<String, Object> res = new LinkedHashMap<>();
        res.put("totalMembers", users.size());
        res.put("totalBuyers", totalBuyers);
        res.put("totalSellers", totalSellers);
        res.put("totalOfficers", totalOfficers);
        res.put("pendingUsers", pendingUsers);
        res.put("totalListings", listings.size());
        res.put("publishedListings", listings.stream().filter(l -> "APPROVED_PUBLISHED".equals(l.getListingStatus())).count());
        res.put("totalRequirements", requirements.size());
        res.put("totalInquiries", inquiryRepository.count());
        res.put("totalProposals", proposalRepository.count());

        // Financial Summary
        Map<String, Object> finance = new LinkedHashMap<>();
        finance.put("regFeeCollected", netRegFee);
        finance.put("regFeePending", regFeePending);
        finance.put("advisoryReservePercent", settings.getAdvisoryReservePercent());
        finance.put("advisoryReserveRecommendation", advisoryReserveAmount);
        finance.put("advisoryNote", "পরামর্শ: কোনো তহবিল লক করা নেই। তবে সম্ভাব্য রিফান্ড ও জরুরি প্রয়োজনে নিবন্ধন তহবিলের "
                + settings.getAdvisoryReservePercent() + "% (৳" + advisoryReserveAmount + ") হাতে রাখার পরামর্শ দেওয়া হলো।");
        finance.put("serviceRevenue", serviceRevenue);
        finance.put("totalCommissionEarned", totalCommissionEarned);
        finance.put("totalCommissionPaid", totalCommissionPaid);
        finance.put("pendingCommissionPayable", pendingCommissionPayable);
        finance.put("operationalExpenses", operationalExpenses);
        finance.put("netOperatingBalance", netOperatingBalance);

        res.put("finance", finance);
        res.put("autoMatches", autoMatches);
        res.put("settings", settings);
        return ResponseEntity.ok(res);
    }

    private BigDecimal sumTransactions(List<FinancialTransactionEntity> list, String bucket, String type, String status) {
        return list.stream()
                .filter(t -> bucket.equals(t.getFundBucket()) && type.equals(t.getTxnType()) && status.equals(t.getStatus()))
                .map(FinancialTransactionEntity::getAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private List<Map<String, Object>> computeAutoMatches(List<LandListingEntity> listings, List<BuyerRequirementEntity> reqs) {
        List<Map<String, Object>> matches = new ArrayList<>();
        for (BuyerRequirementEntity req : reqs) {
            if ("REJECTED".equals(req.getStatus()) || "SUSPENDED".equals(req.getStatus())) continue;
            for (LandListingEntity land : listings) {
                if ("REJECTED".equals(land.getListingStatus()) || "SUSPENDED".equals(land.getListingStatus()) || "SOLD".equals(land.getListingStatus())) {
                    continue;
                }
                int score = 0;
                List<String> reasons = new ArrayList<>();

                if (req.getPreferredDistrict() != null && req.getPreferredDistrict().equalsIgnoreCase(land.getDistrict())) {
                    score += 20;
                }
                if (req.getPreferredUpazila() != null && req.getPreferredUpazila().equalsIgnoreCase(land.getUpazila())) {
                    score += 35;
                    reasons.add("একই উপজেলা (" + land.getUpazila() + ")");
                }
                if (req.getLandType() != null && req.getLandType().equalsIgnoreCase(land.getLandType())) {
                    score += 25;
                    reasons.add("জমির ধরন মিলেছে (" + land.getLandType() + ")");
                }
                // Budget check (within +15% of maxBudget)
                if (req.getMaxBudgetBdt() != null && land.getExpectedPriceBdt() != null) {
                    BigDecimal maxWithTolerance = req.getMaxBudgetBdt().multiply(new BigDecimal("1.15"));
                    if (land.getExpectedPriceBdt().compareTo(maxWithTolerance) <= 0) {
                        score += 20;
                        reasons.add("বাজেটের মধ্যে (৳" + land.getExpectedPriceBdt() + ")");
                    }
                }

                if (score >= 55) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("matchScore", score);
                    m.put("reasons", String.join(" • ", reasons));
                    m.put("listingId", land.getId());
                    m.put("listingTitle", land.getTitle());
                    m.put("sellerName", land.getSellerName());
                    m.put("sellerPhone", land.getSellerPhone());
                    m.put("expectedPriceBdt", land.getExpectedPriceBdt());
                    m.put("areaDecimal", land.getAreaDecimal());
                    m.put("requirementId", req.getId());
                    m.put("buyerName", req.getBuyerName());
                    m.put("buyerPhone", req.getBuyerPhone());
                    m.put("buyerMaxBudgetBdt", req.getMaxBudgetBdt());
                    matches.add(m);
                }
            }
        }
        matches.sort((a, b) -> Integer.compare((int) b.get("matchScore"), (int) a.get("matchScore")));
        return matches;
    }

    // ==================== DYNAMIC SETTINGS & PAYMENT METHODS ====================

    @PutMapping("/settings")
    public ResponseEntity<SystemSettingEntity> updateSettings(@RequestBody Map<String, Object> body) {
        SystemSettingEntity s = getSettings();
        if (body.containsKey("buyerRegistrationFee")) s.setBuyerRegistrationFee(parseDecimal(body.get("buyerRegistrationFee"), s.getBuyerRegistrationFee()));
        if (body.containsKey("sellerRegistrationFee")) s.setSellerRegistrationFee(parseDecimal(body.get("sellerRegistrationFee"), s.getSellerRegistrationFee()));
        if (body.containsKey("officerRegistrationFee")) s.setOfficerRegistrationFee(parseDecimal(body.get("officerRegistrationFee"), s.getOfficerRegistrationFee()));
        if (body.containsKey("referralVerifiedBonusFixed")) s.setReferralVerifiedBonusFixed(parseDecimal(body.get("referralVerifiedBonusFixed"), s.getReferralVerifiedBonusFixed()));
        if (body.containsKey("dealClosureFixedCommission")) s.setDealClosureFixedCommission(parseDecimal(body.get("dealClosureFixedCommission"), s.getDealClosureFixedCommission()));
        if (body.containsKey("dealClosurePercentCommission")) s.setDealClosurePercentCommission(parseDecimal(body.get("dealClosurePercentCommission"), s.getDealClosurePercentCommission()));
        if (body.containsKey("advisoryReservePercent")) s.setAdvisoryReservePercent(parseDecimal(body.get("advisoryReservePercent"), s.getAdvisoryReservePercent()));
        if (body.containsKey("supportPhone")) s.setSupportPhone(String.valueOf(body.get("supportPhone")));
        if (body.containsKey("supportEmail")) s.setSupportEmail(String.valueOf(body.get("supportEmail")));
        if (body.containsKey("officeAddress")) s.setOfficeAddress(String.valueOf(body.get("officeAddress")));
        s.setUpdatedAt(LocalDateTime.now());
        return ResponseEntity.ok(settingRepository.save(s));
    }

    @GetMapping("/payment-methods")
    public ResponseEntity<List<PaymentMethodEntity>> getAllPaymentMethods() {
        return ResponseEntity.ok(paymentMethodRepository.findAll());
    }

    @PostMapping("/payment-methods")
    public ResponseEntity<PaymentMethodEntity> createPaymentMethod(@RequestBody PaymentMethodEntity pm) {
        return ResponseEntity.ok(paymentMethodRepository.save(pm));
    }

    @PutMapping("/payment-methods/{id}")
    public ResponseEntity<?> updatePaymentMethod(@PathVariable Long id, @RequestBody PaymentMethodEntity updated) {
        Optional<PaymentMethodEntity> opt = paymentMethodRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        PaymentMethodEntity pm = opt.get();
        pm.setProviderName(updated.getProviderName());
        pm.setAccountNumber(updated.getAccountNumber());
        pm.setAccountType(updated.getAccountType());
        pm.setInstructions(updated.getInstructions());
        pm.setActive(updated.isActive());
        return ResponseEntity.ok(paymentMethodRepository.save(pm));
    }

    @DeleteMapping("/payment-methods/{id}")
    public ResponseEntity<?> deletePaymentMethod(@PathVariable Long id) {
        paymentMethodRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "পেমেন্ট মাধ্যম মুছে ফেলা হয়েছে।"));
    }

    // ==================== USER MANAGEMENT (APPROVE / SUSPEND / REJECT ANYTIME) ====================

    @GetMapping("/users")
    public ResponseEntity<List<Map<String, Object>>> getAllUsers(@RequestParam(required = false) String role) {
        List<UserEntity> users = (role == null || role.isBlank())
                ? userRepository.findAllByOrderByCreatedAtDesc()
                : userRepository.findByRoleOrderByCreatedAtDesc(role.toUpperCase());

        return ResponseEntity.ok(users.stream()
                .map(PublicAndAuthController::sanitizeUser)
                .collect(Collectors.toList()));
    }

    @PutMapping("/users/{id}/status")
    public ResponseEntity<?> updateUserStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<UserEntity> userOpt = userRepository.findById(id);
        if (userOpt.isEmpty()) return ResponseEntity.notFound().build();

        UserEntity user = userOpt.get();
        String newStatus = body.getOrDefault("accountStatus", user.getAccountStatus()).toUpperCase();
        String adminNote = body.getOrDefault("adminNote", user.getAdminNote());

        user.setAccountStatus(newStatus);
        user.setAdminNote(adminNote);
        user = userRepository.save(user);

        if ("ACTIVE".equals(newStatus)) {
            notifyUser(user.getId(), "অভিনন্দন! আপনার অ্যাকাউন্ট সক্রিয় হয়েছে",
                    "আপনার নিবন্ধন ফি (TrxID: " + user.getTransactionId() + ") যাচাই সম্পন্ন হয়েছে। এখন আপনি পূর্ণ সুবিধা ব্যবহার করতে পারবেন।");
        } else if ("REJECTED".equals(newStatus)) {
            notifyUser(user.getId(), "পেমেন্ট যাচাই ব্যর্থ / সংশোধন প্রয়োজন",
                    "আপনার অ্যাকাউন্ট/TrxID বাতিল করা হয়েছে। কারণ: " + (adminNote != null ? adminNote : "TrxID মেলেনি") + "। ড্যাশবোর্ড থেকে সঠিক TrxID পুনরায় জমা দিন।");
        } else if ("SUSPENDED".equals(newStatus)) {
            notifyUser(user.getId(), "অ্যাকাউন্ট সাময়িকভাবে স্থগিত",
                    "অ্যাডমিন আপনার অ্যাকাউন্ট স্থগিত করেছেন। নোট: " + (adminNote != null ? adminNote : ""));
        }

        // If user is activated (ACTIVE), approve their pending registration fee transaction
        if ("ACTIVE".equals(newStatus)) {
            List<FinancialTransactionEntity> userTxns = transactionRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
            for (FinancialTransactionEntity t : userTxns) {
                if ("REG_FEE_FUND".equals(t.getFundBucket()) && "PENDING_VERIFICATION".equals(t.getStatus())) {
                    t.setStatus("APPROVED");
                    transactionRepository.save(t);
                }
            }

            // If user was referred by a Marketing Officer, award the fixed verified referral bonus (if not already awarded)
            if (user.getReferredByOfficerId() != null) {
                boolean alreadyAwarded = commissionRepository.findByReferredUserIdOrderByCreatedAtDesc(user.getId())
                        .stream()
                        .anyMatch(c -> "REFERRAL_VERIFIED_FIXED".equals(c.getCommissionType()) && !"CANCELLED".equals(c.getStatus()));

                if (!alreadyAwarded) {
                    Optional<UserEntity> officerOpt = userRepository.findById(user.getReferredByOfficerId());
                    SystemSettingEntity settings = getSettings();
                    if (officerOpt.isPresent() && settings.getReferralVerifiedBonusFixed().compareTo(BigDecimal.ZERO) > 0) {
                        UserEntity officer = officerOpt.get();
                        CommissionEntryEntity comm = new CommissionEntryEntity();
                        comm.setOfficerId(officer.getId());
                        comm.setOfficerName(officer.getFullName());
                        comm.setReferralCode(officer.getMyReferralCode());
                        comm.setReferredUserId(user.getId());
                        comm.setReferredUserName(user.getFullName());
                        comm.setReferredUserRole(user.getRole());
                        comm.setCommissionType("REFERRAL_VERIFIED_FIXED");
                        comm.setBaseDealAmountBdt(user.getRegistrationFeeAmount());
                        comm.setPercentageRate(BigDecimal.ZERO);
                        comm.setCommissionAmountBdt(settings.getReferralVerifiedBonusFixed());
                        comm.setStatus("APPROVED_PAYABLE");
                        comm.setNote("রেফারকৃত " + user.getRole() + " (" + user.getFullName() + ") যাচাইকৃত নিবন্ধন সম্মানী");
                        commissionRepository.save(comm);

                        syncOfficerCommissionTotals(officer.getId());
                        notifyUser(officer.getId(), "রেফারেল নিবন্ধন সম্মানী অনুমোদিত!",
                                "আপনার রেফারকৃত সদস্য " + user.getFullName() + " যাচাইকৃত হওয়ায় আপনার তহবিলে ৳" + settings.getReferralVerifiedBonusFixed() + " সম্মানী যোগ হয়েছে।");
                    }
                }
            }
        }

        return ResponseEntity.ok(PublicAndAuthController.sanitizeUser(user));
    }

    // ==================== LAND LISTINGS (APPROVE / SUSPEND / REJECT AT ANY STAGE) ====================

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

        notifyUser(listing.getSellerId(),
                "জমির বিজ্ঞাপনের স্ট্যাটাস আপডেট: " + listing.getTitle(),
                "বিজ্ঞাপনের বর্তমান অবস্থা: " + listing.getListingStatus() + " (ব্যাজ: " + listing.getVerificationStatus() + ")।"
                        + (listing.getAdminRemark() != null && !listing.getAdminRemark().isBlank() ? " নোট: " + listing.getAdminRemark() : ""));

        return ResponseEntity.ok(listing);
    }

    // ==================== BUYER REQUIREMENTS (APPROVE / SUSPEND / REJECT AT ANY STAGE) ====================

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

        notifyUser(req.getBuyerId(),
                "জমির চাহিদাপত্রের স্ট্যাটাস আপডেট (" + req.getPreferredUpazila() + ")",
                "আপনার চাহিদাপত্রের বর্তমান অবস্থা: " + req.getStatus() + "।"
                        + (req.getAdminRemark() != null && !req.getAdminRemark().isBlank() ? " নোট: " + req.getAdminRemark() : ""));

        return ResponseEntity.ok(req);
    }

    // ==================== MEDIATED INQUIRIES ====================

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

        notifyUser(inq.getBuyerId(),
                "জমিতে আগ্রহ প্রকাশের আপডেট: " + inq.getListingTitle(),
                "অবস্থা: " + inq.getStatus() + (inq.getAdminNote() != null && !inq.getAdminNote().isBlank() ? " | অ্যাডমিন নোট: " + inq.getAdminNote() : ""));

        return ResponseEntity.ok(inq);
    }

    // ==================== SPECIAL SERVICE PROPOSALS ====================

    @GetMapping("/proposals")
    public ResponseEntity<List<ServiceProposalEntity>> getAllProposals() {
        return ResponseEntity.ok(proposalRepository.findAllByOrderByCreatedAtDesc());
    }

    @PutMapping("/proposals/{id}")
    public ResponseEntity<?> updateProposalByAdmin(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Optional<ServiceProposalEntity> opt = proposalRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        ServiceProposalEntity p = opt.get();
        if (body.containsKey("status")) {
            p.setStatus(String.valueOf(body.get("status")));
        }
        if (body.containsKey("adminCounterFeeBdt")) {
            p.setAdminCounterFeeBdt(parseDecimal(body.get("adminCounterFeeBdt"), p.getAdminCounterFeeBdt()));
        }
        if (body.containsKey("finalAgreedFeeBdt")) {
            p.setFinalAgreedFeeBdt(parseDecimal(body.get("finalAgreedFeeBdt"), p.getFinalAgreedFeeBdt()));
        }
        if (body.containsKey("adminNote")) {
            p.setAdminNote(String.valueOf(body.get("adminNote")));
        }

        p = proposalRepository.save(p);

        notifyUser(p.getUserId(),
                "বিশেষ সেবা প্রস্তাবের আপডেট: " + p.getProposalTitle(),
                "প্রস্তাবের বর্তমান অবস্থা: " + p.getStatus()
                        + (p.getAdminCounterFeeBdt() != null ? " | পাল্টা প্রস্তাবিত ফি: ৳" + p.getAdminCounterFeeBdt() : "")
                        + (p.getAdminNote() != null && !p.getAdminNote().isBlank() ? " | নোট: " + p.getAdminNote() : ""));

        // If marked COMPLETED, optionally record service revenue if not already recorded
        if ("COMPLETED".equals(p.getStatus())) {
            BigDecimal revenue = p.getFinalAgreedFeeBdt() != null ? p.getFinalAgreedFeeBdt() : p.getCustomerProposedFeeBdt();
            if (revenue != null && revenue.compareTo(BigDecimal.ZERO) > 0) {
                FinancialTransactionEntity txn = new FinancialTransactionEntity();
                txn.setUserId(p.getUserId());
                txn.setUserName(p.getUserName());
                txn.setUserRole(p.getUserRole());
                txn.setFundBucket("SERVICE_REVENUE");
                txn.setTxnType("CREDIT");
                txn.setAmountBdt(revenue);
                txn.setPaymentMethod("AGREED_CONTRACT");
                txn.setTransactionId("DEAL-" + p.getId());
                txn.setDescription("বিশেষ সেবার পারিশ্রমিক: " + p.getProposalTitle());
                txn.setStatus("APPROVED");
                transactionRepository.save(txn);
            }
        }
        return ResponseEntity.ok(p);
    }

    // ==================== DUAL COMMISSION ENGINE (FIXED & PERCENTAGE DECIDED BY ADMIN) ====================

    @GetMapping("/commissions")
    public ResponseEntity<List<CommissionEntryEntity>> getAllCommissions() {
        return ResponseEntity.ok(commissionRepository.findAllByOrderByCreatedAtDesc());
    }

    @PostMapping("/commissions/award")
    public ResponseEntity<?> awardCommissionByAdmin(@RequestBody Map<String, Object> body) {
        Long referredUserId = Long.valueOf(String.valueOf(body.get("referredUserId")));
        Optional<UserEntity> referredOpt = userRepository.findById(referredUserId);
        if (referredOpt.isEmpty() || referredOpt.get().getReferredByOfficerId() == null) {
            return ResponseEntity.badRequest().body(Map.of("message", "এই সদস্য কোনো মার্কেটিং অফিসারের রেফারেলে যুক্ত হননি।"));
        }

        UserEntity referredUser = referredOpt.get();
        Optional<UserEntity> officerOpt = userRepository.findById(referredUser.getReferredByOfficerId());
        if (officerOpt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "মার্কেটিং অফিসার খুঁজে পাওয়া যায়নি।"));
        }
        UserEntity officer = officerOpt.get();

        // commissionType: REFERRAL_VERIFIED_FIXED, DEAL_CLOSURE_FIXED, DEAL_CLOSURE_PERCENT
        String commissionType = String.valueOf(body.getOrDefault("commissionType", "DEAL_CLOSURE_FIXED"));
        BigDecimal baseDealAmount = parseDecimal(body.get("baseDealAmountBdt"), BigDecimal.ZERO);
        BigDecimal percentageRate = parseDecimal(body.get("percentageRate"), BigDecimal.ZERO);
        BigDecimal customFixedAmount = parseDecimal(body.get("commissionAmountBdt"), BigDecimal.ZERO);
        String note = String.valueOf(body.getOrDefault("note", "অ্যাডমিন কর্তৃক অনুমোদিত কমিশন"));

        BigDecimal finalCommission;
        if ("DEAL_CLOSURE_PERCENT".equals(commissionType)) {
            finalCommission = baseDealAmount.multiply(percentageRate).divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP);
        } else {
            finalCommission = customFixedAmount;
        }

        CommissionEntryEntity entry = new CommissionEntryEntity();
        entry.setOfficerId(officer.getId());
        entry.setOfficerName(officer.getFullName());
        entry.setReferralCode(officer.getMyReferralCode());
        entry.setReferredUserId(referredUser.getId());
        entry.setReferredUserName(referredUser.getFullName());
        entry.setReferredUserRole(referredUser.getRole());
        entry.setCommissionType(commissionType);
        entry.setBaseDealAmountBdt(baseDealAmount);
        entry.setPercentageRate(percentageRate);
        entry.setCommissionAmountBdt(finalCommission);
        entry.setStatus("APPROVED_PAYABLE");
        entry.setNote(note);

        entry = commissionRepository.save(entry);
        syncOfficerCommissionTotals(officer.getId());

        notifyUser(officer.getId(),
                "নতুন কমিশন অনুমোদিত হয়েছে: ৳" + finalCommission,
                "রেফারকৃত সদস্য " + referredUser.getFullName() + " এর বিপরীতে ৳" + finalCommission + " কমিশন অনুমোদিত হয়েছে (" + note + ")।");

        return ResponseEntity.ok(entry);
    }

    @PutMapping("/commissions/{id}/pay")
    public ResponseEntity<?> payCommission(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<CommissionEntryEntity> opt = commissionRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        CommissionEntryEntity entry = opt.get();
        if ("PAID".equals(entry.getStatus())) {
            return ResponseEntity.badRequest().body(Map.of("message", "এই সম্মানী ইতোমধ্যে পরিশোধ করা হয়েছে।"));
        }

        String paymentRef = body.getOrDefault("paymentReference", "PAID-BY-ADMIN");
        entry.setStatus("PAID");
        entry.setPaymentReference(paymentRef);
        entry.setPaidAt(LocalDateTime.now());
        entry = commissionRepository.save(entry);

        // Record in Financial Ledger under OFFICER_COMMISSION
        FinancialTransactionEntity txn = new FinancialTransactionEntity();
        txn.setUserId(entry.getOfficerId());
        txn.setUserName(entry.getOfficerName());
        txn.setUserRole("MARKETING_OFFICER");
        txn.setFundBucket("OFFICER_COMMISSION");
        txn.setTxnType("DEBIT");
        txn.setAmountBdt(entry.getCommissionAmountBdt());
        txn.setPaymentMethod("ADMIN_PAYOUT");
        txn.setTransactionId(paymentRef);
        txn.setDescription("মার্কেটিং অফিসার সম্মানী পরিশোধ (" + entry.getOfficerName() + " - রেফারেল: " + entry.getReferredUserName() + ")");
        txn.setStatus("APPROVED");
        transactionRepository.save(txn);

        syncOfficerCommissionTotals(entry.getOfficerId());

        notifyUser(entry.getOfficerId(),
                "কমিশন পরিশোধ সম্পন্ন: ৳" + entry.getCommissionAmountBdt(),
                "আপনার ৳" + entry.getCommissionAmountBdt() + " সম্মানী পরিশোধ করা হয়েছে। রেফারেন্স: " + paymentRef);

        return ResponseEntity.ok(entry);
    }

    private void syncOfficerCommissionTotals(Long officerId) {
        userRepository.findById(officerId).ifPresent(officer -> {
            List<CommissionEntryEntity> all = commissionRepository.findByOfficerIdOrderByCreatedAtDesc(officerId);
            BigDecimal earned = all.stream()
                    .filter(c -> !"CANCELLED".equals(c.getStatus()))
                    .map(CommissionEntryEntity::getCommissionAmountBdt)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            BigDecimal paid = all.stream()
                    .filter(c -> "PAID".equals(c.getStatus()))
                    .map(CommissionEntryEntity::getCommissionAmountBdt)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            officer.setTotalEarnedCommission(earned);
            officer.setTotalPaidCommission(paid);
            userRepository.save(officer);
        });
    }

    // ==================== FINANCIAL LEDGER TRANSACTIONS ====================

    @GetMapping("/transactions")
    public ResponseEntity<List<FinancialTransactionEntity>> getAllTransactions() {
        return ResponseEntity.ok(transactionRepository.findAllByOrderByCreatedAtDesc());
    }

    @PostMapping("/transactions")
    public ResponseEntity<FinancialTransactionEntity> createManualTransaction(@RequestBody Map<String, Object> body) {
        FinancialTransactionEntity t = new FinancialTransactionEntity();
        t.setUserName(String.valueOf(body.getOrDefault("userName", "অ্যাডমিন এন্ট্রি")));
        t.setUserRole(String.valueOf(body.getOrDefault("userRole", "ADMIN")));
        t.setFundBucket(String.valueOf(body.getOrDefault("fundBucket", "OPERATIONAL_EXPENSE")));
        t.setTxnType(String.valueOf(body.getOrDefault("txnType", "DEBIT")));
        t.setAmountBdt(parseDecimal(body.get("amountBdt"), BigDecimal.ZERO));
        t.setPaymentMethod(String.valueOf(body.getOrDefault("paymentMethod", "ক্যাশ / ব্যাংক")));
        t.setTransactionId(String.valueOf(body.getOrDefault("transactionId", "EXP-" + System.currentTimeMillis() % 100000)));
        t.setDescription(String.valueOf(body.getOrDefault("description", "পরিচালন ব্যয়")));
        t.setStatus("APPROVED");
        return ResponseEntity.ok(transactionRepository.save(t));
    }

    @PutMapping("/transactions/{id}/status")
    public ResponseEntity<?> updateTransactionStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<FinancialTransactionEntity> opt = transactionRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        FinancialTransactionEntity t = opt.get();
        t.setStatus(body.getOrDefault("status", t.getStatus()));
        return ResponseEntity.ok(transactionRepository.save(t));
    }

    // ==================== MULTI-DISTRICT / UPAZILA EXPANSION ====================

    @GetMapping("/locations")
    public ResponseEntity<List<LocationEntity>> getAllLocations() {
        return ResponseEntity.ok(locationRepository.findByActiveTrueOrderByDistrictNameBnAscUpazilaNameBnAsc());
    }

    @PostMapping("/locations")
    public ResponseEntity<LocationEntity> addLocation(@RequestBody LocationEntity loc) {
        loc.setActive(true);
        return ResponseEntity.ok(locationRepository.save(loc));
    }

    @DeleteMapping("/locations/{id}")
    public ResponseEntity<?> deleteLocation(@PathVariable Long id) {
        locationRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "উপজেলা মুছে ফেলা হয়েছে।"));
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
