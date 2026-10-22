package bd.com.landtrust.controller.member;

import bd.com.landtrust.entity.CommissionEntryEntity;
import bd.com.landtrust.entity.NotificationEntity;
import bd.com.landtrust.entity.ServiceProposalEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.CommissionEntryRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.repository.ServiceProposalRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.util.CommonUtils;
import bd.com.landtrust.util.UserMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping({"/api/portal", "/api/member"})
public class MemberOfficerController {

    private final UserRepository userRepository;
    private final CommissionEntryRepository commissionRepository;
    private final ServiceProposalRepository proposalRepository;
    private final NotificationRepository notificationRepository;

    public MemberOfficerController(
            UserRepository userRepository,
            CommissionEntryRepository commissionRepository,
            ServiceProposalRepository proposalRepository,
            NotificationRepository notificationRepository) {
        this.userRepository = userRepository;
        this.commissionRepository = commissionRepository;
        this.proposalRepository = proposalRepository;
        this.notificationRepository = notificationRepository;
    }

    private UserEntity currentUser(Authentication auth) {
        UserEntity u = (UserEntity) auth.getPrincipal();
        return userRepository.findById(u.getId()).orElse(u);
    }

    @GetMapping({"/officer-dashboard", "/officer/dashboard"})
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
        response.put("officer", UserMapper.sanitizeUser(officer));
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

    @PostMapping({"/officer-payout-request", "/officer/payout-request"})
    public ResponseEntity<?> requestOfficerPayout(Authentication auth, @RequestBody Map<String, String> body) {
        UserEntity officer = currentUser(auth);
        if (!"ACTIVE".equals(officer.getAccountStatus())) {
            return ResponseEntity.status(403).body(Map.of(
                    "message", "আপনার অ্যাকাউন্টটি সক্রিয় (ACTIVE) নয়। পেআউট অনুরোধ করতে অ্যাকাউন্টটি সক্রিয় হওয়া আবশ্যক।",
                    "accountStatus", officer.getAccountStatus()
            ));
        }
        if (!List.of("MARKETING_OFFICER", "UPAZILA_AGENT", "DISTRICT_AGENT", "ADMIN").contains(officer.getRole())) {
            return ResponseEntity.status(403).body(Map.of("message", "শুধুমাত্র মার্কেটিং অফিসার ও অনুমোদিত এজেন্টগণ এই অনুরোধ করতে পারেন।"));
        }
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

        CommonUtils.notifyUser(notificationRepository, officer.getId(),
                "সম্মানী উত্তোলনের অনুরোধ জমা হয়েছে",
                "আপনার প্রাপ্য সম্মানী " + paymentMethod + " (" + accountNumber + ") নম্বরে পাঠানোর অনুরোধ অ্যাডমিনের কাছে পাঠানো হয়েছে।");

        return ResponseEntity.ok(Map.of("message", "আপনার সম্মানী উত্তোলনের অনুরোধ সফলভাবে অ্যাডমিনের কাছে পাঠানো হয়েছে!"));
    }

    @GetMapping({"/my-proposals", "/proposals"})
    public ResponseEntity<List<ServiceProposalEntity>> getMyProposals(Authentication auth) {
        UserEntity user = currentUser(auth);
        return ResponseEntity.ok(proposalRepository.findByUserIdOrderByCreatedAtDesc(user.getId()));
    }

    @PostMapping("/proposals")
    public ResponseEntity<?> createProposal(Authentication auth, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        if (!"ACTIVE".equals(user.getAccountStatus())) {
            return ResponseEntity.status(403).body(Map.of(
                    "message", "আপনার অ্যাকাউন্টটি সক্রিয় (ACTIVE) নয়। প্রস্তাব তৈরি করতে অ্যাকাউন্টটি সক্রিয় হওয়া আবশ্যক।",
                    "accountStatus", user.getAccountStatus()
            ));
        }
        ServiceProposalEntity p = new ServiceProposalEntity();
        p.setUserId(user.getId());
        p.setUserName(user.getFullName());
        p.setUserPhone(user.getPhoneNumber());
        p.setUserRole(user.getRole());
        p.setProposalTitle((String) body.getOrDefault("proposalTitle", "বিশেষ ক্রয়/বিক্রয় সহায়তা প্রস্তাব"));
        p.setScopeDescription((String) body.getOrDefault("scopeDescription", ""));
        p.setCustomerProposedFeeBdt(CommonUtils.parseDecimal(body.get("customerProposedFeeBdt"), new BigDecimal("100000")));
        p.setTimelineTerms((String) body.getOrDefault("timelineTerms", "৩ মাস"));
        p.setPaymentTerms((String) body.getOrDefault("paymentTerms", "চুক্তি ও দলিল সম্পাদনের পর পরিশোধযোগ্য"));
        p.setStatus("CUSTOMER_PROPOSED");
        return ResponseEntity.ok(proposalRepository.save(p));
    }

    @RequestMapping(value = {"/proposals/{id}/accept-counter", "/proposals/{id}/respond"}, method = {RequestMethod.PUT, RequestMethod.POST})
    public ResponseEntity<?> acceptCounterOffer(Authentication auth, @PathVariable Long id, @RequestBody(required = false) Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        Optional<ServiceProposalEntity> opt = proposalRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getUserId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }
        ServiceProposalEntity p = opt.get();
        if ("COMPLETED".equals(p.getStatus()) || "CANCELLED".equals(p.getStatus())) {
            return ResponseEntity.badRequest().body(Map.of("message", "এই প্রস্তাবটি ইতোমধ্যে সমাপ্ত বা বাতিল করা হয়েছে।"));
        }

        String action = body != null && body.containsKey("action") ? String.valueOf(body.get("action")) : "ACCEPT";
        if ("REJECT".equalsIgnoreCase(action) || "DECLINE".equalsIgnoreCase(action)) {
            p.setStatus("CANCELLED");
        } else {
            if (p.getAdminCounterFeeBdt() != null) {
                p.setFinalAgreedFeeBdt(p.getAdminCounterFeeBdt());
            } else {
                p.setFinalAgreedFeeBdt(p.getCustomerProposedFeeBdt());
            }
            p.setStatus("MUTUALLY_AGREED");
        }
        return ResponseEntity.ok(proposalRepository.save(p));
    }
}
