package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.CommissionEntryEntity;
import bd.com.landtrust.entity.FinancialTransactionEntity;
import bd.com.landtrust.entity.SystemSettingEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.*;
import bd.com.landtrust.util.CommissionHelper;
import bd.com.landtrust.util.CommonUtils;
import bd.com.landtrust.util.UserMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
public class AdminUserController {

    private final UserRepository userRepository;
    private final SystemSettingRepository settingRepository;
    private final CommissionEntryRepository commissionRepository;
    private final FinancialTransactionRepository transactionRepository;
    private final NotificationRepository notificationRepository;
    private final PasswordEncoder passwordEncoder;

    public AdminUserController(
            UserRepository userRepository,
            SystemSettingRepository settingRepository,
            CommissionEntryRepository commissionRepository,
            FinancialTransactionRepository transactionRepository,
            NotificationRepository notificationRepository,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.settingRepository = settingRepository;
        this.commissionRepository = commissionRepository;
        this.transactionRepository = transactionRepository;
        this.notificationRepository = notificationRepository;
        this.passwordEncoder = passwordEncoder;
    }

    private SystemSettingEntity getSettings() {
        return settingRepository.findAll().stream().findFirst().orElseGet(() -> {
            SystemSettingEntity def = new SystemSettingEntity();
            return settingRepository.save(def);
        });
    }

    @GetMapping("/users")
    public ResponseEntity<List<Map<String, Object>>> getAllUsers(@RequestParam(required = false) String role) {
        List<UserEntity> users = (role == null || role.isBlank())
                ? userRepository.findAllByOrderByCreatedAtDesc()
                : userRepository.findByRoleOrderByCreatedAtDesc(role.toUpperCase());

        return ResponseEntity.ok(users.stream()
                .map(UserMapper::sanitizeUser)
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
            CommonUtils.notifyUser(notificationRepository, user.getId(), "অভিনন্দন! আপনার অ্যাকাউন্ট সক্রিয় হয়েছে",
                    "আপনার নিবন্ধন ফি (TrxID: " + user.getTransactionId() + ") যাচাই সম্পন্ন হয়েছে। এখন আপনি পূর্ণ সুবিধা ব্যবহার করতে পারবেন।");
        } else if ("REJECTED".equals(newStatus)) {
            CommonUtils.notifyUser(notificationRepository, user.getId(), "পেমেন্ট যাচাই ব্যর্থ / সংশোধন প্রয়োজন",
                    "আপনার অ্যাকাউন্ট/TrxID বাতিল করা হয়েছে। কারণ: " + (adminNote != null ? adminNote : "TrxID মেলেনি") + "। ড্যাশবোর্ড থেকে সঠিক TrxID পুনরায় জমা দিন।");
        } else if ("SUSPENDED".equals(newStatus)) {
            CommonUtils.notifyUser(notificationRepository, user.getId(), "অ্যাকাউন্ট সাময়িকভাবে স্থগিত",
                    "অ্যাডমিন আপনার অ্যাকাউন্ট স্থগিত করেছেন। নোট: " + (adminNote != null ? adminNote : ""));
        }

        if ("ACTIVE".equals(newStatus)) {
            List<FinancialTransactionEntity> userTxns = transactionRepository.findByUserIdOrderByCreatedAtDesc(user.getId());
            for (FinancialTransactionEntity t : userTxns) {
                if ("REG_FEE_FUND".equals(t.getFundBucket()) && "PENDING_VERIFICATION".equals(t.getStatus())) {
                    t.setStatus("APPROVED");
                    transactionRepository.save(t);
                }
            }

            if (user.getReferredByOfficerId() != null) {
                boolean alreadyAwarded = commissionRepository.findByReferredUserIdOrderByCreatedAtDesc(user.getId())
                        .stream()
                        .anyMatch(c -> ("REFERRAL_VERIFIED_FIXED".equals(c.getCommissionType()) || "REGISTRATION_COMMISSION".equals(c.getCommissionType())) && !"CANCELLED".equals(c.getStatus()));

                if (!alreadyAwarded) {
                    Optional<UserEntity> officerOpt = userRepository.findById(user.getReferredByOfficerId());
                    SystemSettingEntity settings = getSettings();
                    if (officerOpt.isPresent()) {
                        UserEntity officer = officerOpt.get();
                        BigDecimal commAmount = BigDecimal.ZERO;
                        if ("BUYER".equals(user.getRole())) {
                            commAmount = settings.getBuyerRegCommission() != null ? settings.getBuyerRegCommission() : new BigDecimal("100");
                        } else if ("SELLER".equals(user.getRole())) {
                            boolean isPou = (user.getUpazila() != null && (user.getUpazila().contains("পৌরসভা") || user.getUpazila().contains("সিটি কর্পোরেশন"))) || "POURASHAVA".equalsIgnoreCase(user.getAgentTier());
                            commAmount = isPou ? (settings.getSellerRegCommissionPourashava() != null ? settings.getSellerRegCommissionPourashava() : new BigDecimal("200"))
                                               : (settings.getSellerRegCommissionUnion() != null ? settings.getSellerRegCommissionUnion() : new BigDecimal("100"));
                        } else {
                            commAmount = settings.getReferralVerifiedBonusFixed() != null ? settings.getReferralVerifiedBonusFixed() : new BigDecimal("100");
                        }

                        if (commAmount.compareTo(BigDecimal.ZERO) > 0) {
                            CommissionEntryEntity comm = new CommissionEntryEntity();
                            comm.setOfficerId(officer.getId());
                            comm.setOfficerName(officer.getFullName());
                            comm.setReferralCode(officer.getMyReferralCode());
                            comm.setReferredUserId(user.getId());
                            comm.setReferredUserName(user.getFullName());
                            comm.setReferredUserRole(user.getRole());
                            comm.setCommissionType("REGISTRATION_COMMISSION");
                            comm.setBaseDealAmountBdt(user.getRegistrationFeeAmount());
                            comm.setPercentageRate(BigDecimal.ZERO);
                            comm.setCommissionAmountBdt(commAmount);
                            comm.setStatus("APPROVED_PAYABLE");
                            comm.setAgentRole(officer.getRole());
                            comm.setTierLevel("DIRECT_FIELD");
                            comm.setNote("রেফারকৃত " + user.getRole() + " (" + user.getFullName() + ") নিবন্ধন কমিশন");
                            commissionRepository.save(comm);

                            CommissionHelper.syncOfficerCommissionTotals(userRepository, commissionRepository, officer.getId());
                            CommonUtils.notifyUser(notificationRepository, officer.getId(), "রেফারেল নিবন্ধন কমিশন অনুমোদিত: ৳" + commAmount,
                                    "আপনার রেফারকৃত সদস্য " + user.getFullName() + " এর অ্যাকাউন্ট অনুমোদিত হওয়ায় ৳" + commAmount + " কমিশন আপনার ব্যালেন্সে যোগ হয়েছে।");
                        }
                    }
                }
            }
        }

        return ResponseEntity.ok(UserMapper.sanitizeUser(user));
    }

    @PutMapping("/users/{id}/reset-password")
    public ResponseEntity<?> resetUserPassword(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<UserEntity> userOpt = userRepository.findById(id);
        if (userOpt.isEmpty()) return ResponseEntity.notFound().build();

        UserEntity user = userOpt.get();
        String newPassword = body.getOrDefault("newPassword", "123456").trim();
        if (newPassword.isBlank()) newPassword = "123456";

        user.setPasswordHash(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        CommonUtils.notifyUser(notificationRepository, user.getId(), "অ্যাডমিন কর্তৃক পাসওয়ার্ড রিসেট",
                "অ্যাডমিন আপনার অ্যাকাউন্টের পাসওয়ার্ড রিসেট করেছেন। ড্যাশবোর্ড থেকে আপনি পুনরায় পাসওয়ার্ড পরিবর্তন করতে পারবেন।");

        return ResponseEntity.ok(Map.of("message", user.getFullName() + " এর পাসওয়ার্ড সফলভাবে রিসেট করা হয়েছে।"));
    }

    @PostMapping("/users/{id}/refund")
    public ResponseEntity<?> refundUserRegistrationFee(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<UserEntity> userOpt = userRepository.findById(id);
        if (userOpt.isEmpty()) return ResponseEntity.notFound().build();

        UserEntity user = userOpt.get();
        BigDecimal refundAmount = CommonUtils.parseDecimal(body.get("amountBdt"),
                user.getRegistrationFeeAmount() != null ? user.getRegistrationFeeAmount() : new BigDecimal("500"));
        String refundRef = body.getOrDefault("paymentReference", "REFUND-" + System.currentTimeMillis() % 100000);
        String reason = body.getOrDefault("reason", "নিবন্ধন ফি রিফান্ড");

        FinancialTransactionEntity txn = new FinancialTransactionEntity();
        txn.setUserId(user.getId());
        txn.setUserName(user.getFullName());
        txn.setUserRole(user.getRole());
        txn.setFundBucket("REG_FEE_FUND");
        txn.setTxnType("REFUND");
        txn.setAmountBdt(refundAmount);
        txn.setPaymentMethod(user.getPaymentMethod() != null ? user.getPaymentMethod() : "বিকাশ/নগদ");
        txn.setSenderPhone(user.getSenderPhone() != null ? user.getSenderPhone() : user.getPhoneNumber());
        txn.setTransactionId(refundRef);
        txn.setDescription("নিবন্ধন ফি রিফান্ড (" + user.getFullName() + "): " + reason);
        txn.setStatus("APPROVED");
        transactionRepository.save(txn);

        CommonUtils.notifyUser(notificationRepository, user.getId(), "নিবন্ধন ফি রিফান্ড সম্পন্ন: ৳" + refundAmount,
                "আপনার ৳" + refundAmount + " নিবন্ধন ফি রিফান্ড করা হয়েছে (রেফারেন্স: " + refundRef + ")। কারণ: " + reason);

        return ResponseEntity.ok(txn);
    }

    @PostMapping("/users/{id}/notify")
    public ResponseEntity<?> sendUserNotification(
            @PathVariable Long id,
            @RequestBody Map<String, String> body) {
        Optional<UserEntity> userOpt = userRepository.findById(id);
        if (userOpt.isEmpty()) return ResponseEntity.notFound().build();

        String title = body.getOrDefault("title", "LandApp নোটিফিকেশন").trim();
        String message = body.getOrDefault("message", "").trim();
        if (message.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "মেসেজ খালি হতে পারে না"));
        }

        CommonUtils.notifyUser(notificationRepository, id, title, message);
        return ResponseEntity.ok(Map.of("message", "সদস্যের কাছে নোটিফিকেশন সফলভাবে পাঠানো হয়েছে!"));
    }

    @PostMapping("/notifications/broadcast")
    public ResponseEntity<?> broadcastNotification(@RequestBody Map<String, String> body) {
        String title = body.getOrDefault("title", "LandApp জরুরি ঘোষণা").trim();
        String message = body.getOrDefault("message", "").trim();
        String targetRole = body.getOrDefault("role", "").trim();

        if (message.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "মেসেজ খালি হতে পারে না"));
        }

        List<UserEntity> targets = (targetRole.isBlank() || "ALL".equalsIgnoreCase(targetRole))
                ? userRepository.findAll()
                : userRepository.findByRoleOrderByCreatedAtDesc(targetRole.toUpperCase());

        for (UserEntity u : targets) {
            CommonUtils.notifyUser(notificationRepository, u.getId(), title, message);
        }

        return ResponseEntity.ok(Map.of("message", targets.size() + " জন ব্যবহারকারীকে সফলভাবে নোটিফিকেশন পাঠানো হয়েছে!"));
    }
}
