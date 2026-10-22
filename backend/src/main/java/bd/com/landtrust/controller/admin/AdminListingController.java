package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.*;
import bd.com.landtrust.util.CommissionHelper;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin")
public class AdminListingController {

    private final LandListingRepository listingRepository;
    private final NotificationRepository notificationRepository;
    private final FinancialTransactionRepository transactionRepository;
    private final UserRepository userRepository;
    private final CommissionEntryRepository commissionRepository;
    private final SystemSettingRepository settingRepository;

    public AdminListingController(
            LandListingRepository listingRepository,
            NotificationRepository notificationRepository,
            FinancialTransactionRepository transactionRepository,
            UserRepository userRepository,
            CommissionEntryRepository commissionRepository,
            SystemSettingRepository settingRepository) {
        this.listingRepository = listingRepository;
        this.notificationRepository = notificationRepository;
        this.transactionRepository = transactionRepository;
        this.userRepository = userRepository;
        this.commissionRepository = commissionRepository;
        this.settingRepository = settingRepository;
    }

    private SystemSettingEntity getSettings() {
        return settingRepository.findAll().stream().findFirst().orElseGet(() -> {
            SystemSettingEntity def = new SystemSettingEntity();
            return settingRepository.save(def);
        });
    }

    @GetMapping("/listings")
    public ResponseEntity<List<LandListingEntity>> getAllListingsForAdmin() {
        return ResponseEntity.ok(listingRepository.findAllByOrderByCreatedAtDesc());
    }

    @RequestMapping(value = {"/listings/{id}/status", "/listings/{id}/verify", "/listings/{id}/approve"}, method = {RequestMethod.PUT, RequestMethod.POST})
    public ResponseEntity<?> updateListingStatus(@PathVariable Long id, @RequestBody(required = false) Map<String, String> body, jakarta.servlet.http.HttpServletRequest request) {
        Optional<LandListingEntity> opt = listingRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        LandListingEntity listing = opt.get();
        String oldPaymentStatus = listing.getPaymentStatus();
        Map<String, String> reqBody = body != null ? body : Map.of();

        if (request.getRequestURI().endsWith("/approve")) {
            listing.setListingStatus("APPROVED_PUBLISHED");
            listing.setPaymentStatus("APPROVED");
        }

        if (reqBody.containsKey("listingStatus")) {
            listing.setListingStatus(reqBody.get("listingStatus"));
        }
        if (reqBody.containsKey("verificationStatus")) {
            listing.setVerificationStatus(reqBody.get("verificationStatus"));
        } else if (reqBody.containsKey("status")) {
            listing.setVerificationStatus(reqBody.get("status"));
        }

        if (reqBody.containsKey("paymentStatus")) {
            listing.setPaymentStatus(reqBody.get("paymentStatus"));
        } else if ("APPROVED_PUBLISHED".equals(listing.getListingStatus())) {
            listing.setPaymentStatus("APPROVED");
        }

        if (reqBody.containsKey("adminRemark")) {
            listing.setAdminRemark(reqBody.get("adminRemark"));
        } else if (reqBody.containsKey("notes")) {
            listing.setAdminRemark(reqBody.get("notes"));
        }

        // If newly approved and has a fee charged, record financial transaction
        if ("APPROVED".equals(listing.getPaymentStatus()) && !"APPROVED".equals(oldPaymentStatus)) {
            BigDecimal fee = listing.getListingFeeChargedBdt();
            if (fee != null && fee.compareTo(BigDecimal.ZERO) > 0) {
                FinancialTransactionEntity txn = new FinancialTransactionEntity();
                txn.setUserId(listing.getSellerId());
                txn.setUserName(listing.getSellerName());
                txn.setUserRole("SELLER");
                txn.setFundBucket("LISTING_FEE_FUND");
                txn.setTxnType("LISTING_FEE");
                txn.setAmountBdt(fee);
                txn.setPaymentMethod(listing.getPaymentMethod() != null ? listing.getPaymentMethod() : "বিকাশ/নগদ");
                txn.setSenderPhone(listing.getSenderPhone() != null ? listing.getSenderPhone() : listing.getSellerPhone());
                txn.setTransactionId(listing.getTransactionId() != null ? listing.getTransactionId() : "LISTING-" + listing.getId());
                txn.setDescription("বিজ্ঞাপন রেজিস্ট্রেশন ফি (" + listing.getTitle() + " #" + listing.getId() + ")");
                txn.setStatus("APPROVED");
                transactionRepository.save(txn);
            }
        }

        // Award Listing Registration Commission to the referring Officer
        if ("APPROVED".equals(listing.getPaymentStatus()) && !listing.isListingCommissionAwarded()) {
            if (listing.getReferredOfficerId() != null) {
                Optional<UserEntity> officerOpt = userRepository.findById(listing.getReferredOfficerId());
                SystemSettingEntity settings = getSettings();
                BigDecimal commAmount = settings.getListingRegCommission() != null ? settings.getListingRegCommission() : new BigDecimal("100");
                if (officerOpt.isPresent() && commAmount.compareTo(BigDecimal.ZERO) > 0) {
                    UserEntity officer = officerOpt.get();
                    CommissionEntryEntity comm = new CommissionEntryEntity();
                    comm.setOfficerId(officer.getId());
                    comm.setOfficerName(officer.getFullName());
                    comm.setReferralCode(officer.getMyReferralCode());
                    comm.setReferredUserId(listing.getSellerId());
                    comm.setReferredUserName(listing.getSellerName());
                    comm.setReferredUserRole("SELLER");
                    comm.setCommissionType("LISTING_REGISTRATION_COMMISSION");
                    comm.setBaseDealAmountBdt(listing.getListingFeeChargedBdt() != null ? listing.getListingFeeChargedBdt() : BigDecimal.ZERO);
                    comm.setPercentageRate(BigDecimal.ZERO);
                    comm.setCommissionAmountBdt(commAmount);
                    comm.setStatus("APPROVED_PAYABLE");
                    comm.setAgentRole(officer.getRole());
                    comm.setTierLevel("DIRECT_FIELD");
                    comm.setNote("রেফারকৃত বিক্রেতার নতুন লিস্টিং (" + listing.getPropertyRegCode() + ") রেজিস্ট্রেশন কমিশন");
                    commissionRepository.save(comm);
                    listing.setListingCommissionAwarded(true);

                    CommissionHelper.syncOfficerCommissionTotals(userRepository, commissionRepository, officer.getId());
                    CommonUtils.notifyUser(notificationRepository, officer.getId(), "নতুন প্রপার্টি লিস্টিং কমিশন অনুমোদিত: ৳" + commAmount,
                            "আপনার রেফারকৃত বিক্রেতা " + listing.getSellerName() + " এর নতুন জমি/ফ্ল্যাট (" + listing.getPropertyRegCode() + ") নিবন্ধিত হওয়ায় ৳" + commAmount + " কমিশন আপনার ব্যালেন্সে যোগ হয়েছে।");
                }
            }
        }

        listing = listingRepository.save(listing);

        CommonUtils.notifyUser(notificationRepository, listing.getSellerId(),
                "জমির বিজ্ঞাপনের স্ট্যাটাস আপডেট: " + listing.getTitle(),
                "বিজ্ঞাপনের বর্তমান অবস্থা: " + listing.getListingStatus() + " (ব্যাজ: " + listing.getVerificationStatus() + ")।"
                        + (listing.getAdminRemark() != null && !listing.getAdminRemark().isBlank() ? " নোট: " + listing.getAdminRemark() : ""));

        return ResponseEntity.ok(listing);
    }
}
