package bd.com.landtrust.controller;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.*;
import bd.com.landtrust.security.JwtService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api")
public class PublicAndAuthController {

    private final UserRepository userRepository;
    private final SystemSettingRepository settingRepository;
    private final PaymentMethodRepository paymentMethodRepository;
    private final LocationRepository locationRepository;
    private final LandListingRepository listingRepository;
    private final BuyerRequirementRepository requirementRepository;
    private final FinancialTransactionRepository transactionRepository;
    private final NotificationRepository notificationRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public PublicAndAuthController(
            UserRepository userRepository,
            SystemSettingRepository settingRepository,
            PaymentMethodRepository paymentMethodRepository,
            LocationRepository locationRepository,
            LandListingRepository listingRepository,
            BuyerRequirementRepository requirementRepository,
            FinancialTransactionRepository transactionRepository,
            NotificationRepository notificationRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService) {
        this.userRepository = userRepository;
        this.settingRepository = settingRepository;
        this.paymentMethodRepository = paymentMethodRepository;
        this.locationRepository = locationRepository;
        this.listingRepository = listingRepository;
        this.requirementRepository = requirementRepository;
        this.transactionRepository = transactionRepository;
        this.notificationRepository = notificationRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    private SystemSettingEntity getSettings() {
        return settingRepository.findAll().stream().findFirst().orElseGet(() -> {
            SystemSettingEntity def = new SystemSettingEntity();
            return settingRepository.save(def);
        });
    }

    @GetMapping("/public/config")
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

    @GetMapping("/public/listings")
    public ResponseEntity<List<Map<String, Object>>> getPublishedListings(
            @RequestParam(required = false) String district,
            @RequestParam(required = false) String upazila,
            @RequestParam(required = false) String landType,
            @RequestParam(required = false) BigDecimal maxBudget) {

        List<LandListingEntity> all = listingRepository.findAllByOrderByCreatedAtDesc();
        List<Map<String, Object>> result = all.stream()
                .filter(l -> "APPROVED_PUBLISHED".equals(l.getListingStatus()) || "RESERVED".equals(l.getListingStatus()))
                .filter(l -> district == null || district.isBlank() || district.equalsIgnoreCase(l.getDistrict()))
                .filter(l -> upazila == null || upazila.isBlank() || upazila.equalsIgnoreCase(l.getUpazila()))
                .filter(l -> landType == null || landType.isBlank() || landType.equalsIgnoreCase(l.getLandType()))
                .filter(l -> maxBudget == null || l.getExpectedPriceBdt().compareTo(maxBudget) <= 0)
                .map(this::toPublicListingMap)
                .collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }

    private Map<String, Object> toPublicListingMap(LandListingEntity l) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", l.getId());
        m.put("title", l.getTitle());
        m.put("district", l.getDistrict());
        m.put("upazila", l.getUpazila());
        m.put("areaName", l.getAreaName());
        m.put("mouzaName", l.getMouzaName());
        m.put("landType", l.getLandType());
        m.put("areaDecimal", l.getAreaDecimal());
        m.put("expectedPriceBdt", l.getExpectedPriceBdt());
        m.put("pricePerDecimalBdt", l.getPricePerDecimalBdt());
        m.put("roadAccessInfo", l.getRoadAccessInfo());
        m.put("description", l.getDescription());
        m.put("imageUrl", l.getImageUrl());
        m.put("verificationStatus", l.getVerificationStatus());
        m.put("listingStatus", l.getListingStatus());
        m.put("createdAt", l.getCreatedAt());
        // Privacy enforcement: Direct seller contact & sensitive deed numbers hidden publicly
        m.put("sellerContactNote", "প্ল্যাটফর্মের মাধ্যমে যাচাইকৃত সংযোগ (সরাসরি নম্বর গোপন রাখা হয়েছে)");
        return m;
    }

    @GetMapping("/public/requirements")
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

    @GetMapping("/public/stats")
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

    @PostMapping("/auth/register")
    public ResponseEntity<?> register(@RequestBody Map<String, Object> body) {
        String fullName = (String) body.getOrDefault("fullName", "");
        String phoneNumber = ((String) body.getOrDefault("phoneNumber", "")).trim();
        String password = (String) body.getOrDefault("password", "");
        String role = ((String) body.getOrDefault("role", "BUYER")).toUpperCase();
        String district = (String) body.getOrDefault("district", "নোয়াখালী");
        String upazila = (String) body.getOrDefault("upazila", "নোয়াখালী সদর");
        String address = (String) body.getOrDefault("address", "");
        String referralCodeInput = ((String) body.getOrDefault("referralCode", "")).trim();
        String paymentMethod = (String) body.getOrDefault("paymentMethod", "বিকাশ (bKash)");
        String senderPhone = (String) body.getOrDefault("senderPhone", phoneNumber);
        String transactionId = ((String) body.getOrDefault("transactionId", "")).trim();

        if (fullName.isBlank() || phoneNumber.isBlank() || password.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "নাম, মোবাইল নম্বর এবং পাসওয়ার্ড আবশ্যক।"));
        }

        if (!List.of("BUYER", "SELLER", "MARKETING_OFFICER").contains(role)) {
            return ResponseEntity.badRequest().body(Map.of("message", "সঠিক সদস্যের ধরন নির্বাচন করুন।"));
        }

        if (userRepository.findByPhoneNumber(phoneNumber).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "এই মোবাইল নম্বর দিয়ে ইতোমধ্যে নিবন্ধন করা হয়েছে।"));
        }

        SystemSettingEntity settings = getSettings();
        BigDecimal feeAmount = switch (role) {
            case "SELLER" -> settings.getSellerRegistrationFee();
            case "MARKETING_OFFICER" -> settings.getOfficerRegistrationFee();
            default -> settings.getBuyerRegistrationFee();
        };

        UserEntity user = new UserEntity();
        user.setFullName(fullName);
        user.setPhoneNumber(phoneNumber);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setRole(role);
        user.setAccountStatus("PAYMENT_SUBMITTED");
        user.setDistrict(district);
        user.setUpazila(upazila);
        user.setAddress(address);
        user.setRegistrationFeeAmount(feeAmount);
        user.setPaymentMethod(paymentMethod);
        user.setSenderPhone(senderPhone);
        user.setTransactionId(transactionId.isBlank() ? "PENDING-TRX" : transactionId);

        // Check if a valid referral code was used by Buyer or Seller
        if (!referralCodeInput.isBlank() && ("BUYER".equals(role) || "SELLER".equals(role))) {
            Optional<UserEntity> officerOpt = userRepository.findByMyReferralCodeIgnoreCase(referralCodeInput);
            if (officerOpt.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("message", "প্রদত্ত রেফারেল কোডটি সঠিক নয়।"));
            }
            UserEntity officer = officerOpt.get();
            user.setReferredByOfficerId(officer.getId());
            user.setReferredByCode(officer.getMyReferralCode());
            user.setReferredByOfficerName(officer.getFullName());
        }

        // If registering as a Marketing Officer, generate a unique referral code
        if ("MARKETING_OFFICER".equals(role)) {
            long count = userRepository.findByRoleOrderByCreatedAtDesc("MARKETING_OFFICER").size() + 1001;
            String code = "LT-NOA-" + count;
            while (userRepository.findByMyReferralCodeIgnoreCase(code).isPresent()) {
                count++;
                code = "LT-NOA-" + count;
            }
            user.setMyReferralCode(code);
        }

        user = userRepository.save(user);

        // Create a FinancialTransaction in REG_FEE_FUND for Admin verification
        FinancialTransactionEntity txn = new FinancialTransactionEntity();
        txn.setUserId(user.getId());
        txn.setUserName(user.getFullName());
        txn.setUserRole(user.getRole());
        txn.setFundBucket("REG_FEE_FUND");
        txn.setTxnType("CREDIT");
        txn.setAmountBdt(feeAmount);
        txn.setPaymentMethod(paymentMethod);
        txn.setSenderPhone(senderPhone);
        txn.setTransactionId(user.getTransactionId());
        txn.setDescription(role + " নিবন্ধন ফি (" + user.getFullName() + ")");
        txn.setStatus("PENDING_VERIFICATION");
        transactionRepository.save(txn);

        NotificationEntity n = new NotificationEntity();
        n.setUserId(user.getId());
        n.setTitle("ভূমি সেতুতে স্বাগতম!");
        n.setMessage("আপনার নিবন্ধন ও TrxID (" + user.getTransactionId() + ") জমা হয়েছে। অ্যাডমিন যাচাই করে আপনার অ্যাকাউন্ট সক্রিয় করবেন।");
        notificationRepository.save(n);

        if (user.getReferredByOfficerId() != null) {
            NotificationEntity on = new NotificationEntity();
            on.setUserId(user.getReferredByOfficerId());
            on.setTitle("নতুন রেফারেল সদস্য যুক্ত হয়েছেন");
            on.setMessage(user.getFullName() + " (" + user.getRole() + ") আপনার রেফারেল কোড ব্যবহার করে নিবন্ধন করেছেন।");
            notificationRepository.save(on);
        }

        String token = jwtService.generateToken(user);
        return ResponseEntity.ok(Map.of(
                "token", token,
                "user", sanitizeUser(user),
                "message", "নিবন্ধন সফল হয়েছে! অ্যাডমিন আপনার পেমেন্ট (TrxID) যাচাই করে অ্যাকাউন্ট সক্রিয় করবেন।"
        ));
    }

    @PostMapping("/auth/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        String phoneNumber = body.getOrDefault("phoneNumber", "").trim();
        String password = body.getOrDefault("password", "");

        Optional<UserEntity> userOpt = userRepository.findByPhoneNumber(phoneNumber);
        if (userOpt.isEmpty() || !passwordEncoder.matches(password, userOpt.get().getPasswordHash())) {
            return ResponseEntity.status(401).body(Map.of("message", "মোবাইল নম্বর বা পাসওয়ার্ড সঠিক নয়।"));
        }

        UserEntity user = userOpt.get();
        // Only block SUSPENDED users from logging in; REJECTED users are allowed to log in to view adminNote and resubmit corrected TrxID
        if ("SUSPENDED".equals(user.getAccountStatus())) {
            return ResponseEntity.status(403).body(Map.of(
                    "message", "আপনার অ্যাকাউন্টটি বর্তমানে স্থগিত (Suspended) অবস্থায় রয়েছে। অ্যাডমিনের সাথে যোগাযোগ করুন।"
            ));
        }

        String token = jwtService.generateToken(user);
        return ResponseEntity.ok(Map.of(
                "token", token,
                "user", sanitizeUser(user)
        ));
    }

    @GetMapping("/user/me")
    public ResponseEntity<?> getCurrentUser(Authentication auth) {
        if (auth == null || !(auth.getPrincipal() instanceof UserEntity user)) {
            return ResponseEntity.status(401).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }
        UserEntity fresh = userRepository.findById(user.getId()).orElse(user);
        return ResponseEntity.ok(sanitizeUser(fresh));
    }

    public static Map<String, Object> sanitizeUser(UserEntity u) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", u.getId());
        m.put("fullName", u.getFullName());
        m.put("phoneNumber", u.getPhoneNumber());
        m.put("role", u.getRole());
        m.put("accountStatus", u.getAccountStatus());
        m.put("district", u.getDistrict());
        m.put("upazila", u.getUpazila());
        m.put("address", u.getAddress());
        m.put("myReferralCode", u.getMyReferralCode());
        m.put("referredByOfficerId", u.getReferredByOfficerId());
        m.put("referredByCode", u.getReferredByCode());
        m.put("referredByOfficerName", u.getReferredByOfficerName());
        m.put("registrationFeeAmount", u.getRegistrationFeeAmount());
        m.put("paymentMethod", u.getPaymentMethod());
        m.put("senderPhone", u.getSenderPhone());
        m.put("transactionId", u.getTransactionId());
        m.put("totalEarnedCommission", u.getTotalEarnedCommission());
        m.put("totalPaidCommission", u.getTotalPaidCommission());
        m.put("adminNote", u.getAdminNote());
        m.put("createdAt", u.getCreatedAt());
        return m;
    }
}
