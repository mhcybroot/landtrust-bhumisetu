package bd.com.landtrust.controller;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.*;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
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
    private final PasswordEncoder passwordEncoder;

    public MemberPortalController(
            UserRepository userRepository,
            LandListingRepository listingRepository,
            BuyerRequirementRepository requirementRepository,
            LandInquiryRepository inquiryRepository,
            ServiceProposalRepository proposalRepository,
            CommissionEntryRepository commissionRepository,
            FinancialTransactionRepository transactionRepository,
            NotificationRepository notificationRepository,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.listingRepository = listingRepository;
        this.requirementRepository = requirementRepository;
        this.inquiryRepository = inquiryRepository;
        this.proposalRepository = proposalRepository;
        this.commissionRepository = commissionRepository;
        this.transactionRepository = transactionRepository;
        this.notificationRepository = notificationRepository;
        this.passwordEncoder = passwordEncoder;
    }

    private UserEntity currentUser(Authentication auth) {
        UserEntity u = (UserEntity) auth.getPrincipal();
        return userRepository.findById(u.getId()).orElse(u);
    }

    // ==================== PROFILE EDIT & PASSWORD CHANGE ====================

    @PutMapping("/profile")
    public ResponseEntity<?> updateMyProfile(Authentication auth, @RequestBody Map<String, String> body) {
        UserEntity user = currentUser(auth);
        String fullName = body.getOrDefault("fullName", user.getFullName()).trim();
        String district = body.getOrDefault("district", user.getDistrict()).trim();
        String upazila = body.getOrDefault("upazila", user.getUpazila()).trim();
        String address = body.getOrDefault("address", user.getAddress()).trim();

        if (!fullName.isBlank()) user.setFullName(fullName);
        if (!district.isBlank()) user.setDistrict(district);
        if (!upazila.isBlank()) user.setUpazila(upazila);
        user.setAddress(address);
        user = userRepository.save(user);

        return ResponseEntity.ok(Map.of(
                "user", PublicAndAuthController.sanitizeUser(user),
                "message", "প্রোফাইল তথ্য সফলভাবে আপডেট হয়েছে!"
        ));
    }

    @PutMapping("/change-password")
    public ResponseEntity<?> changeMyPassword(Authentication auth, @RequestBody Map<String, String> body) {
        UserEntity user = currentUser(auth);
        String currentPassword = body.getOrDefault("currentPassword", "");
        String newPassword = body.getOrDefault("newPassword", "").trim();

        if (newPassword.length() < 4) {
            return ResponseEntity.badRequest().body(Map.of("message", "নতুন পাসওয়ার্ড কমপক্ষে ৪ অক্ষরের হতে হবে।"));
        }
        if (!passwordEncoder.matches(currentPassword, user.getPasswordHash())) {
            return ResponseEntity.badRequest().body(Map.of("message", "বর্তমান পাসওয়ার্ড সঠিক নয়।"));
        }

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        NotificationEntity n = new NotificationEntity();
        n.setUserId(user.getId());
        n.setTitle("পাসওয়ার্ড পরিবর্তন সম্পন্ন");
        n.setMessage("আপনার অ্যাকাউন্টের পাসওয়ার্ড সফলভাবে পরিবর্তন করা হয়েছে।");
        notificationRepository.save(n);

        return ResponseEntity.ok(Map.of("message", "পাসওয়ার্ড সফলভাবে পরিবর্তন হয়েছে!"));
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
        listing.setAdditionalImageUrls((String) body.getOrDefault("additionalImageUrls", ""));
        listing.setVideoUrl((String) body.getOrDefault("videoUrl", ""));
        listing.setMapLink((String) body.getOrDefault("mapLink", ""));
        listing.setPrivateDocumentUrl((String) body.getOrDefault("privateDocumentUrl", ""));
        listing.setPrivateDocumentName((String) body.getOrDefault("privateDocumentName", ""));
        listing.setProposedServiceFeeBdt(proposedFee);
        listing.setVerificationStatus("SUBMITTED");
        listing.setListingStatus("SUBMITTED");

        listing = listingRepository.save(listing);
        return ResponseEntity.ok(listing);
    }

    @PutMapping("/listings/{id}")
    public ResponseEntity<?> updateMyListing(Authentication auth, @PathVariable Long id, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        Optional<LandListingEntity> opt = listingRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getSellerId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }

        LandListingEntity listing = opt.get();
        if (body.containsKey("title")) listing.setTitle(String.valueOf(body.get("title")));
        if (body.containsKey("district")) listing.setDistrict(String.valueOf(body.get("district")));
        if (body.containsKey("upazila")) listing.setUpazila(String.valueOf(body.get("upazila")));
        if (body.containsKey("areaName")) listing.setAreaName(String.valueOf(body.get("areaName")));
        if (body.containsKey("mouzaName")) listing.setMouzaName(String.valueOf(body.get("mouzaName")));
        if (body.containsKey("khatianNo")) listing.setKhatianNo(String.valueOf(body.get("khatianNo")));
        if (body.containsKey("dagNo")) listing.setDagNo(String.valueOf(body.get("dagNo")));
        if (body.containsKey("mutationInfo")) listing.setMutationInfo(String.valueOf(body.get("mutationInfo")));
        if (body.containsKey("landType")) listing.setLandType(String.valueOf(body.get("landType")));
        if (body.containsKey("areaDecimal")) {
            listing.setAreaDecimal(parseDecimal(body.get("areaDecimal"), listing.getAreaDecimal()));
        }
        if (body.containsKey("expectedPriceBdt")) {
            listing.setExpectedPriceBdt(parseDecimal(body.get("expectedPriceBdt"), listing.getExpectedPriceBdt()));
        }
        if (listing.getAreaDecimal() != null && listing.getAreaDecimal().compareTo(BigDecimal.ZERO) > 0 && listing.getExpectedPriceBdt() != null) {
            listing.setPricePerDecimalBdt(listing.getExpectedPriceBdt().divide(listing.getAreaDecimal(), 0, RoundingMode.HALF_UP));
        }
        if (body.containsKey("proposedServiceFeeBdt")) {
            listing.setProposedServiceFeeBdt(parseDecimal(body.get("proposedServiceFeeBdt"), listing.getProposedServiceFeeBdt()));
        }
        if (body.containsKey("roadAccessInfo")) listing.setRoadAccessInfo(String.valueOf(body.get("roadAccessInfo")));
        if (body.containsKey("description")) listing.setDescription(String.valueOf(body.get("description")));
        if (body.containsKey("imageUrl") && !String.valueOf(body.get("imageUrl")).isBlank()) {
            listing.setImageUrl(String.valueOf(body.get("imageUrl")));
        }
        if (body.containsKey("additionalImageUrls")) {
            listing.setAdditionalImageUrls(String.valueOf(body.get("additionalImageUrls")));
        }
        if (body.containsKey("videoUrl")) listing.setVideoUrl(String.valueOf(body.get("videoUrl")));
        if (body.containsKey("mapLink")) listing.setMapLink(String.valueOf(body.get("mapLink")));
        if (body.containsKey("privateDocumentUrl") && !String.valueOf(body.get("privateDocumentUrl")).isBlank()) {
            listing.setPrivateDocumentUrl(String.valueOf(body.get("privateDocumentUrl")));
        }
        if (body.containsKey("privateDocumentName") && !String.valueOf(body.get("privateDocumentName")).isBlank()) {
            listing.setPrivateDocumentName(String.valueOf(body.get("privateDocumentName")));
        }

        return ResponseEntity.ok(listingRepository.save(listing));
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

    @PutMapping("/requirements/{id}")
    public ResponseEntity<?> updateMyRequirement(Authentication auth, @PathVariable Long id, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        Optional<BuyerRequirementEntity> opt = requirementRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getBuyerId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }

        BuyerRequirementEntity req = opt.get();
        if (body.containsKey("preferredDistrict")) req.setPreferredDistrict(String.valueOf(body.get("preferredDistrict")));
        if (body.containsKey("preferredUpazila")) req.setPreferredUpazila(String.valueOf(body.get("preferredUpazila")));
        if (body.containsKey("preferredArea")) req.setPreferredArea(String.valueOf(body.get("preferredArea")));
        if (body.containsKey("landType")) req.setLandType(String.valueOf(body.get("landType")));
        if (body.containsKey("minAreaDecimal")) req.setMinAreaDecimal(parseDecimal(body.get("minAreaDecimal"), req.getMinAreaDecimal()));
        if (body.containsKey("maxAreaDecimal")) req.setMaxAreaDecimal(parseDecimal(body.get("maxAreaDecimal"), req.getMaxAreaDecimal()));
        if (body.containsKey("minBudgetBdt")) req.setMinBudgetBdt(parseDecimal(body.get("minBudgetBdt"), req.getMinBudgetBdt()));
        if (body.containsKey("maxBudgetBdt")) req.setMaxBudgetBdt(parseDecimal(body.get("maxBudgetBdt"), req.getMaxBudgetBdt()));
        if (body.containsKey("purpose")) req.setPurpose(String.valueOf(body.get("purpose")));
        if (body.containsKey("purchaseTimeline")) req.setPurchaseTimeline(String.valueOf(body.get("purchaseTimeline")));
        if (body.containsKey("proposedServiceFeeBdt")) req.setProposedServiceFeeBdt(parseDecimal(body.get("proposedServiceFeeBdt"), req.getProposedServiceFeeBdt()));
        if (body.containsKey("specialRequirements")) req.setSpecialRequirements(String.valueOf(body.get("specialRequirements")));
        if (body.containsKey("status")) req.setStatus(String.valueOf(body.get("status")));

        return ResponseEntity.ok(requirementRepository.save(req));
    }

    @PutMapping("/requirements/{id}/fulfill")
    public ResponseEntity<?> fulfillMyRequirement(Authentication auth, @PathVariable Long id) {
        UserEntity user = currentUser(auth);
        Optional<BuyerRequirementEntity> opt = requirementRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getBuyerId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }
        BuyerRequirementEntity req = opt.get();
        req.setStatus("FULFILLED");
        return ResponseEntity.ok(requirementRepository.save(req));
    }

    @PostMapping("/requirements/{id}/seller-offer")
    public ResponseEntity<?> submitSellerOfferForRequirement(Authentication auth, @PathVariable Long id, @RequestBody Map<String, Object> body) {
        UserEntity seller = currentUser(auth);
        Optional<BuyerRequirementEntity> opt = requirementRepository.findById(id);
        if (opt.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "চাহিদাপত্র খুঁজে পাওয়া যায়নি।"));
        }
        BuyerRequirementEntity req = opt.get();
        String landDetails = String.valueOf(body.getOrDefault("landDetails", "")).trim();
        BigDecimal askingPrice = parseDecimal(body.get("askingPriceBdt"), req.getMaxBudgetBdt());
        BigDecimal proposedFee = parseDecimal(body.get("proposedServiceFeeBdt"), new BigDecimal("50000"));

        // Create a mediated ServiceProposal so Admin & Seller can track it, and notify the Buyer!
        ServiceProposalEntity p = new ServiceProposalEntity();
        p.setUserId(seller.getId());
        p.setUserName(seller.getFullName());
        p.setUserPhone(seller.getPhoneNumber());
        p.setUserRole(seller.getRole());
        p.setProposalTitle("ক্রেতার চাহিদা #" + req.getId() + " (" + req.getPreferredUpazila() + " - " + req.getLandType() + ") এর বিপরীতে জমির প্রস্তাব");
        p.setScopeDescription("ক্রেতা: " + req.getBuyerName() + " | বিক্রেতার প্রস্তাবিত মূল্য: ৳" + askingPrice + " | জমির বিবরণ: " + landDetails);
        p.setCustomerProposedFeeBdt(proposedFee);
        p.setTimelineTerms(req.getPurchaseTimeline());
        p.setPaymentTerms("চুক্তি ও দলিল সম্পাদনের পর পরিশোধযোগ্য");
        p.setStatus("CUSTOMER_PROPOSED");
        proposalRepository.save(p);

        // Notify the Buyer (preserving seller privacy)
        NotificationEntity buyerNotif = new NotificationEntity();
        buyerNotif.setUserId(req.getBuyerId());
        buyerNotif.setTitle("আপনার জমির চাহিদার বিপরীতে একটি জমির প্রস্তাব এসেছে!");
        buyerNotif.setMessage(req.getPreferredUpazila() + " এলাকায় আপনার " + req.getLandType() + " জমির চাহিদার বিপরীতে একজন বিক্রেতা ৳" + askingPrice + " মূল্যে জমির প্রস্তাব পাঠিয়েছেন। ভূমি সেতু অ্যাডমিন যাচাই করে আপনার সাথে যোগাযোগ করবেন।");
        notificationRepository.save(buyerNotif);

        return ResponseEntity.ok(Map.of(
                "message", "আপনার জমির প্রস্তাবটি সফলভাবে অ্যাডমিন মধ্যস্থতা প্যানেলে জমা হয়েছে এবং ক্রেতাকে নোটিফিকেশন পাঠানো হয়েছে!"
        ));
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

    @PostMapping("/officer-payout-request")
    public ResponseEntity<?> requestOfficerPayout(Authentication auth, @RequestBody Map<String, String> body) {
        UserEntity officer = currentUser(auth);
        String paymentMethod = body.getOrDefault("paymentMethod", "বিকাশ (bKash)");
        String accountNumber = body.getOrDefault("accountNumber", officer.getPhoneNumber()).trim();
        String note = body.getOrDefault("note", "").trim();

        List<CommissionEntryEntity> payableList = commissionRepository.findByOfficerIdOrderByCreatedAtDesc(officer.getId())
                .stream()
                .filter(c -> "APPROVED_PAYABLE".equals(c.getStatus()))
                .toList();

        if (payableList.isEmpty()) {
            return ResponseEntity.badRequest().body(Map.of("message", "বর্তমানে আপনার কোনো বকেয়া প্রাপ্য সম্মানী নেই।"));
        }

        String reqTag = " [পেআউট অনুরোধ: " + paymentMethod + " - " + accountNumber + (note.isBlank() ? "" : " (" + note + ")") + "]";
        for (CommissionEntryEntity c : payableList) {
            String existingNote = c.getNote() != null ? c.getNote() : "";
            if (!existingNote.contains("[পেআউট অনুরোধ:")) {
                c.setNote(existingNote + reqTag);
                commissionRepository.save(c);
            }
        }

        NotificationEntity n = new NotificationEntity();
        n.setUserId(officer.getId());
        n.setTitle("সম্মানী উত্তোলনের অনুরোধ জমা হয়েছে");
        n.setMessage("আপনার প্রাপ্য সম্মানী " + paymentMethod + " (" + accountNumber + ") নম্বরে পাঠানোর অনুরোধ অ্যাডমিনের কাছে পাঠানো হয়েছে।");
        notificationRepository.save(n);

        return ResponseEntity.ok(Map.of("message", "আপনার সম্মানী উত্তোলনের অনুরোধ সফলভাবে অ্যাডমিনের কাছে পাঠানো হয়েছে!"));
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
