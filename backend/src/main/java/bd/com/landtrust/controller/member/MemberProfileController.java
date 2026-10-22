package bd.com.landtrust.controller.member;

import bd.com.landtrust.entity.FinancialTransactionEntity;
import bd.com.landtrust.entity.NotificationEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.FinancialTransactionRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.util.UserMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping({"/api/portal", "/api/member"})
public class MemberProfileController {

    private final UserRepository userRepository;
    private final FinancialTransactionRepository transactionRepository;
    private final NotificationRepository notificationRepository;
    private final PasswordEncoder passwordEncoder;

    public MemberProfileController(
            UserRepository userRepository,
            FinancialTransactionRepository transactionRepository,
            NotificationRepository notificationRepository,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.transactionRepository = transactionRepository;
        this.notificationRepository = notificationRepository;
        this.passwordEncoder = passwordEncoder;
    }

    private UserEntity currentUser(Authentication auth) {
        UserEntity u = (UserEntity) auth.getPrincipal();
        return userRepository.findById(u.getId()).orElse(u);
    }

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
                "user", UserMapper.sanitizeUser(user),
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

    @RequestMapping(value = "/notifications/{id}/read", method = {RequestMethod.PUT, RequestMethod.POST})
    public ResponseEntity<?> markNotificationRead(Authentication auth, @PathVariable Long id) {
        UserEntity user = currentUser(auth);
        Optional<NotificationEntity> notifOpt = notificationRepository.findById(id);
        if (notifOpt.isPresent() && notifOpt.get().getUserId().equals(user.getId())) {
            NotificationEntity n = notifOpt.get();
            n.setReadStatus(true);
            notificationRepository.save(n);
        }
        return ResponseEntity.ok(Map.of("message", "নোটিফিকেশন পঠিত হিসেবে চিহ্নিত হয়েছে।"));
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
                "user", UserMapper.sanitizeUser(user),
                "message", "সংশোধিত পেমেন্ট তথ্য সফলভাবে জমা হয়েছে! অ্যাডমিন যাচাই করে সক্রিয় করবেন।"
        ));
    }

    @RequestMapping(value = {"/account", "/account/delete", "/delete-account"}, method = {RequestMethod.DELETE, RequestMethod.POST})
    public ResponseEntity<?> deleteMyAccount(Authentication auth) {
        UserEntity user = currentUser(auth);
        user.setAccountStatus("DELETED");
        user.setFullName("মুছে ফেলা সদস্য (" + user.getId() + ")");
        user.setPhoneNumber("DEL_" + System.currentTimeMillis() + "_" + user.getPhoneNumber());
        user.setAddress("DELETED");
        userRepository.save(user);

        return ResponseEntity.ok(Map.of(
                "status", "SUCCESS",
                "message", "আপনার অ্যাকাউন্ট ও ব্যক্তিগত তথ্য সফলভাবে মুছে ফেলা হয়েছে।"
        ));
    }
}
