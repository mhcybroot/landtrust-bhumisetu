package bd.com.landtrust.controller.member;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.BuyerRequirementRepository;
import bd.com.landtrust.repository.LandInquiryRepository;
import bd.com.landtrust.repository.LandListingRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.repository.ServiceProposalRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/portal")
public class MemberBuyerController {

    private final UserRepository userRepository;
    private final LandListingRepository listingRepository;
    private final BuyerRequirementRepository requirementRepository;
    private final LandInquiryRepository inquiryRepository;
    private final ServiceProposalRepository proposalRepository;
    private final NotificationRepository notificationRepository;

    public MemberBuyerController(
            UserRepository userRepository,
            LandListingRepository listingRepository,
            BuyerRequirementRepository requirementRepository,
            LandInquiryRepository inquiryRepository,
            ServiceProposalRepository proposalRepository,
            NotificationRepository notificationRepository) {
        this.userRepository = userRepository;
        this.listingRepository = listingRepository;
        this.requirementRepository = requirementRepository;
        this.inquiryRepository = inquiryRepository;
        this.proposalRepository = proposalRepository;
        this.notificationRepository = notificationRepository;
    }

    private UserEntity currentUser(Authentication auth) {
        UserEntity u = (UserEntity) auth.getPrincipal();
        return userRepository.findById(u.getId()).orElse(u);
    }

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
        req.setMinAreaDecimal(CommonUtils.parseDecimal(body.get("minAreaDecimal"), new BigDecimal("5")));
        req.setMaxAreaDecimal(CommonUtils.parseDecimal(body.get("maxAreaDecimal"), new BigDecimal("20")));
        req.setMinBudgetBdt(CommonUtils.parseDecimal(body.get("minBudgetBdt"), new BigDecimal("1000000")));
        req.setMaxBudgetBdt(CommonUtils.parseDecimal(body.get("maxBudgetBdt"), new BigDecimal("3000000")));
        req.setPurpose((String) body.getOrDefault("purpose", "বাড়ি নির্মাণ"));
        req.setPurchaseTimeline((String) body.getOrDefault("purchaseTimeline", "১-৩ মাসের মধ্যে"));
        req.setProposedServiceFeeBdt(CommonUtils.parseDecimal(body.get("proposedServiceFeeBdt"), BigDecimal.ZERO));
        req.setSpecialRequirements((String) body.getOrDefault("specialRequirements", ""));
        req.setStatus("SUBMITTED");

        return ResponseEntity.ok(requirementRepository.save(req));
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
        if (body.containsKey("minAreaDecimal")) req.setMinAreaDecimal(CommonUtils.parseDecimal(body.get("minAreaDecimal"), req.getMinAreaDecimal()));
        if (body.containsKey("maxAreaDecimal")) req.setMaxAreaDecimal(CommonUtils.parseDecimal(body.get("maxAreaDecimal"), req.getMaxAreaDecimal()));
        if (body.containsKey("minBudgetBdt")) req.setMinBudgetBdt(CommonUtils.parseDecimal(body.get("minBudgetBdt"), req.getMinBudgetBdt()));
        if (body.containsKey("maxBudgetBdt")) req.setMaxBudgetBdt(CommonUtils.parseDecimal(body.get("maxBudgetBdt"), req.getMaxBudgetBdt()));
        if (body.containsKey("purpose")) req.setPurpose(String.valueOf(body.get("purpose")));
        if (body.containsKey("purchaseTimeline")) req.setPurchaseTimeline(String.valueOf(body.get("purchaseTimeline")));
        if (body.containsKey("proposedServiceFeeBdt")) req.setProposedServiceFeeBdt(CommonUtils.parseDecimal(body.get("proposedServiceFeeBdt"), req.getProposedServiceFeeBdt()));
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
        BigDecimal askingPrice = CommonUtils.parseDecimal(body.get("askingPriceBdt"), req.getMaxBudgetBdt());
        BigDecimal proposedFee = CommonUtils.parseDecimal(body.get("proposedServiceFeeBdt"), new BigDecimal("50000"));

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

        CommonUtils.notifyUser(notificationRepository, req.getBuyerId(),
                "আপনার জমির চাহিদার বিপরীতে একটি জমির প্রস্তাব এসেছে!",
                req.getPreferredUpazila() + " এলাকায় আপনার " + req.getLandType() + " জমির চাহিদার বিপরীতে একজন বিক্রেতা ৳" + askingPrice + " মূল্যে জমির প্রস্তাব পাঠিয়েছেন। ভূমি সেতু অ্যাডমিন যাচাই করে আপনার সাথে যোগাযোগ করবেন।");

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
        inquiry.setOfferedBudgetBdt(CommonUtils.parseDecimal(body.get("offeredBudgetBdt"), land.getExpectedPriceBdt()));
        inquiry.setMessage((String) body.getOrDefault("message", "এই জমিটি পরিদর্শন ও ক্রয়ের ব্যাপারে আগ্রহী।"));
        inquiry.setStatus("PENDING");

        inquiry = inquiryRepository.save(inquiry);

        CommonUtils.notifyUser(notificationRepository, land.getSellerId(),
                "আপনার জমিতে একজন ক্রেতা আগ্রহ প্রকাশ করেছেন!",
                "‘" + land.getTitle() + "’ বিজ্ঞাপনে একজন যাচাইকৃত ক্রেতা ৳" + inquiry.getOfferedBudgetBdt() + " বাজেটে আগ্রহ প্রকাশ করেছেন। অ্যাডমিন মধ্যস্থতা করছেন।");

        return ResponseEntity.ok(inquiry);
    }

    @GetMapping("/my-inquiries")
    public ResponseEntity<List<LandInquiryEntity>> getMyInquiries(Authentication auth) {
        UserEntity user = currentUser(auth);
        return ResponseEntity.ok(inquiryRepository.findByBuyerIdOrderByCreatedAtDesc(user.getId()));
    }
}
