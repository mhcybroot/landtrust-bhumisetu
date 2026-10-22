package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.FinancialTransactionEntity;
import bd.com.landtrust.entity.LandListingEntity;
import bd.com.landtrust.repository.FinancialTransactionRepository;
import bd.com.landtrust.repository.LandListingRepository;
import bd.com.landtrust.repository.NotificationRepository;
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

    public AdminListingController(
            LandListingRepository listingRepository,
            NotificationRepository notificationRepository,
            FinancialTransactionRepository transactionRepository) {
        this.listingRepository = listingRepository;
        this.notificationRepository = notificationRepository;
        this.transactionRepository = transactionRepository;
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

        listing = listingRepository.save(listing);

        CommonUtils.notifyUser(notificationRepository, listing.getSellerId(),
                "জমির বিজ্ঞাপনের স্ট্যাটাস আপডেট: " + listing.getTitle(),
                "বিজ্ঞাপনের বর্তমান অবস্থা: " + listing.getListingStatus() + " (ব্যাজ: " + listing.getVerificationStatus() + ")।"
                        + (listing.getAdminRemark() != null && !listing.getAdminRemark().isBlank() ? " নোট: " + listing.getAdminRemark() : ""));

        return ResponseEntity.ok(listing);
    }
}
