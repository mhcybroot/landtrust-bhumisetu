package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.*;
import bd.com.landtrust.service.SystemSettingService;
import bd.com.landtrust.util.CommissionHelper;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.*;

@RestController
@RequestMapping("/api/admin")
public class AdminFinanceController {

    private final UserRepository userRepository;
    private final ServiceProposalRepository proposalRepository;
    private final CommissionEntryRepository commissionRepository;
    private final FinancialTransactionRepository transactionRepository;
    private final NotificationRepository notificationRepository;
    private final SystemSettingService settingService;

    public AdminFinanceController(
            UserRepository userRepository, ServiceProposalRepository proposalRepository,
            CommissionEntryRepository commissionRepository, FinancialTransactionRepository transactionRepository,
            NotificationRepository notificationRepository, SystemSettingService settingService) {
        this.userRepository = userRepository;
        this.proposalRepository = proposalRepository;
        this.commissionRepository = commissionRepository;
        this.transactionRepository = transactionRepository;
        this.notificationRepository = notificationRepository;
        this.settingService = settingService;
    }

    private SystemSettingEntity getSettings() {
        return settingService.getSettings();
    }

    @GetMapping("/proposals")
    public ResponseEntity<List<ServiceProposalEntity>> getAllProposals() {
        return ResponseEntity.ok(proposalRepository.findAllByOrderByCreatedAtDesc());
    }

    @Transactional
    @RequestMapping(value = {"/proposals/{id}", "/proposals/{id}/respond"}, method = {RequestMethod.PUT, RequestMethod.POST})
    public ResponseEntity<?> updateProposalByAdmin(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Optional<ServiceProposalEntity> opt = proposalRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        ServiceProposalEntity p = opt.get();
        if (body.containsKey("status")) {
            p.setStatus(String.valueOf(body.get("status")));
        } else if (body.containsKey("action")) {
            String act = String.valueOf(body.get("action"));
            if ("ACCEPT".equalsIgnoreCase(act) || "APPROVE".equalsIgnoreCase(act) || "AGREE".equalsIgnoreCase(act)) {
                p.setStatus("MUTUALLY_AGREED");
            } else if ("REJECT".equalsIgnoreCase(act)) {
                p.setStatus("REJECTED");
            } else if ("COMPLETE".equalsIgnoreCase(act)) {
                p.setStatus("COMPLETED");
            } else {
                p.setStatus(act);
            }
        }
        if (body.containsKey("adminCounterFeeBdt")) {
            p.setAdminCounterFeeBdt(CommonUtils.parseDecimal(body.get("adminCounterFeeBdt"), p.getAdminCounterFeeBdt()));
        }
        if (body.containsKey("finalAgreedFeeBdt")) {
            p.setFinalAgreedFeeBdt(CommonUtils.parseDecimal(body.get("finalAgreedFeeBdt"), p.getFinalAgreedFeeBdt()));
        }
        if (body.containsKey("adminNote")) {
            p.setAdminNote(String.valueOf(body.get("adminNote")));
        } else if (body.containsKey("notes")) {
            p.setAdminNote(String.valueOf(body.get("notes")));
        }

        p = proposalRepository.save(p);
        CommonUtils.notifyUser(notificationRepository, p.getUserId(), "বিশেষ সেবা প্রস্তাবের আপডেট: " + p.getProposalTitle(),
                "অবস্থা: " + p.getStatus() + (p.getAdminCounterFeeBdt() != null ? " | পাল্টা ফি: ৳" + p.getAdminCounterFeeBdt() : "")
                        + (p.getAdminNote() != null && !p.getAdminNote().isBlank() ? " | নোট: " + p.getAdminNote() : ""));

        if ("COMPLETED".equals(p.getStatus())) {
            BigDecimal revenue = p.getFinalAgreedFeeBdt() != null ? p.getFinalAgreedFeeBdt() : p.getCustomerProposedFeeBdt();
            if (revenue != null && revenue.compareTo(BigDecimal.ZERO) > 0) {
                String dealTrxId = "DEAL-" + p.getId();
                boolean alreadyRecorded = transactionRepository.existsByTransactionId(dealTrxId);
                if (!alreadyRecorded) {
                    recordTxn(p.getUserId(), p.getUserName(), p.getUserRole(), "SERVICE_REVENUE", "CREDIT", revenue, "AGREED_CONTRACT", dealTrxId, "বিশেষ সেবার পারিশ্রমিক: " + p.getProposalTitle());
                }
            }
        }
        return ResponseEntity.ok(p);
    }

    @GetMapping("/commissions")
    public ResponseEntity<List<CommissionEntryEntity>> getAllCommissions() {
        return ResponseEntity.ok(commissionRepository.findAllByOrderByCreatedAtDesc());
    }

    @Transactional
    @PostMapping("/commissions/award")
    public ResponseEntity<?> awardCommissionByAdmin(@RequestBody Map<String, Object> body) {
        Object refIdObj = body.get("referredUserId");
        if (refIdObj == null || String.valueOf(refIdObj).isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "রেফারকৃত সদস্য আইডি আবশ্যক।"));
        }
        Long referredUserId;
        try {
            referredUserId = Long.valueOf(String.valueOf(refIdObj).trim());
        } catch (NumberFormatException e) {
            return ResponseEntity.badRequest().body(Map.of("message", "রেফারকৃত সদস্য আইডি সঠিক নয়।"));
        }

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

        String commissionType = String.valueOf(body.getOrDefault("commissionType", "DEAL_CLOSURE_FIXED"));
        BigDecimal baseDealAmount = CommonUtils.parseDecimal(body.get("baseDealAmountBdt"), BigDecimal.ZERO);
        BigDecimal percentageRate = CommonUtils.parseDecimal(body.get("percentageRate"), BigDecimal.ZERO);
        BigDecimal customFixedAmount = CommonUtils.parseDecimal(body.get("commissionAmountBdt"), BigDecimal.ZERO);
        String note = String.valueOf(body.getOrDefault("note", "অ্যাডমিন কর্তৃক অনুমোদিত কমিশন"));

        BigDecimal finalCommission = "DEAL_CLOSURE_PERCENT".equals(commissionType)
                ? baseDealAmount.multiply(percentageRate).divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP)
                : customFixedAmount;

        SystemSettingEntity settings = getSettings();
        BigDecimal fieldSharePct = settings.getDealClosureFieldSharePercent() != null ? settings.getDealClosureFieldSharePercent() : new BigDecimal("70");
        BigDecimal upazilaSharePct = settings.getDealClosureUpazilaSharePercent() != null ? settings.getDealClosureUpazilaSharePercent() : new BigDecimal("20");
        BigDecimal districtSharePct = settings.getDealClosureDistrictSharePercent() != null ? settings.getDealClosureDistrictSharePercent() : new BigDecimal("10");

        boolean isDealClosure = commissionType.startsWith("DEAL_CLOSURE");
        BigDecimal officerShare = isDealClosure
                ? finalCommission.multiply(fieldSharePct).divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP)
                : finalCommission;

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
        entry.setCommissionAmountBdt(officerShare);
        entry.setStatus("APPROVED_PAYABLE");
        entry.setAgentRole(officer.getRole());
        entry.setTierLevel("DIRECT_FIELD");
        entry.setNote(note + (isDealClosure ? " (মাঠ পর্যায় " + fieldSharePct + "%)" : ""));

        entry = commissionRepository.save(entry);
        CommissionHelper.syncOfficerCommissionTotals(userRepository, commissionRepository, officer.getId());
        CommonUtils.notifyUser(notificationRepository, officer.getId(), "নতুন কমিশন অনুমোদিত: ৳" + officerShare,
                "রেফারকৃত সদস্য " + referredUser.getFullName() + " এর বিপরীতে ৳" + officerShare + " কমিশন অনুমোদিত (" + note + ")।");

        if (isDealClosure) {
            Optional<UserEntity> upzAgentOpt = Optional.empty();
            if (officer.getSupervisorAgentId() != null) {
                upzAgentOpt = userRepository.findById(officer.getSupervisorAgentId());
            }
            if (upzAgentOpt.isEmpty() && officer.getDistrict() != null && officer.getUpazila() != null) {
                upzAgentOpt = userRepository.findFirstByRoleAndDistrictAndUpazilaAndAccountStatus("UPAZILA_AGENT", officer.getDistrict(), officer.getUpazila(), "ACTIVE");
            }
            if (upzAgentOpt.isPresent()) {
                UserEntity upzAgent = upzAgentOpt.get();
                BigDecimal upzShare = finalCommission.multiply(upazilaSharePct).divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP);
                CommissionEntryEntity upzEntry = new CommissionEntryEntity();
                upzEntry.setOfficerId(upzAgent.getId());
                upzEntry.setOfficerName(upzAgent.getFullName());
                upzEntry.setReferralCode(upzAgent.getMyReferralCode());
                upzEntry.setReferredUserId(referredUser.getId());
                upzEntry.setReferredUserName(referredUser.getFullName());
                upzEntry.setReferredUserRole(referredUser.getRole());
                upzEntry.setCommissionType("UPAZILA_OVERRIDE");
                upzEntry.setBaseDealAmountBdt(baseDealAmount);
                upzEntry.setPercentageRate(upazilaSharePct);
                upzEntry.setCommissionAmountBdt(upzShare);
                upzEntry.setStatus("APPROVED_PAYABLE");
                upzEntry.setAgentRole("UPAZILA_AGENT");
                upzEntry.setTierLevel("UPAZILA_OVERRIDE");
                upzEntry.setNote("উপজেলা এজেন্ট সুপারভাইজরি কমিশন (" + upazilaSharePct + "%)");
                commissionRepository.save(upzEntry);
                CommissionHelper.syncOfficerCommissionTotals(userRepository, commissionRepository, upzAgent.getId());
                CommonUtils.notifyUser(notificationRepository, upzAgent.getId(), "নতুন উপজেলা ওভাররাইড কমিশন: ৳" + upzShare,
                        "অধীনস্থ অফিসার " + officer.getFullName() + " এর ডিল ক্লোজিংয়ের বিপরীতে ৳" + upzShare + " কমিশন প্রাপ্ত হয়েছে।");
            }

            Optional<UserEntity> distAgentOpt = Optional.empty();
            if (upzAgentOpt.isPresent() && upzAgentOpt.get().getSupervisorAgentId() != null) {
                distAgentOpt = userRepository.findById(upzAgentOpt.get().getSupervisorAgentId());
            }
            if (distAgentOpt.isEmpty() && officer.getSupervisorAgentId() != null) {
                distAgentOpt = userRepository.findById(officer.getSupervisorAgentId()).filter(u -> "DISTRICT_AGENT".equals(u.getRole()));
            }
            if (distAgentOpt.isEmpty() && officer.getDistrict() != null) {
                distAgentOpt = userRepository.findFirstByRoleAndDistrictAndAccountStatus("DISTRICT_AGENT", officer.getDistrict(), "ACTIVE");
            }
            if (distAgentOpt.isPresent()) {
                UserEntity distAgent = distAgentOpt.get();
                BigDecimal distShare = finalCommission.multiply(districtSharePct).divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP);
                CommissionEntryEntity distEntry = new CommissionEntryEntity();
                distEntry.setOfficerId(distAgent.getId());
                distEntry.setOfficerName(distAgent.getFullName());
                distEntry.setReferralCode(distAgent.getMyReferralCode());
                distEntry.setReferredUserId(referredUser.getId());
                distEntry.setReferredUserName(referredUser.getFullName());
                distEntry.setReferredUserRole(referredUser.getRole());
                distEntry.setCommissionType("DISTRICT_OVERRIDE");
                distEntry.setBaseDealAmountBdt(baseDealAmount);
                distEntry.setPercentageRate(districtSharePct);
                distEntry.setCommissionAmountBdt(distShare);
                distEntry.setStatus("APPROVED_PAYABLE");
                distEntry.setAgentRole("DISTRICT_AGENT");
                distEntry.setTierLevel("DISTRICT_OVERRIDE");
                distEntry.setNote("জেলা প্রধান প্রতিনিধি আঞ্চলিক ওভাররাইড (" + districtSharePct + "%)");
                commissionRepository.save(distEntry);
                CommissionHelper.syncOfficerCommissionTotals(userRepository, commissionRepository, distAgent.getId());
                CommonUtils.notifyUser(notificationRepository, distAgent.getId(), "নতুন জেলা ওভাররাইড কমিশন: ৳" + distShare,
                        "আঞ্চলিক ডিল ক্লোজিংয়ের বিপরীতে ৳" + distShare + " কমিশন প্রাপ্ত হয়েছে।");
            }
        }

        return ResponseEntity.ok(entry);
    }

    @Transactional
    @RequestMapping(value = "/commissions/{id}/pay", method = {RequestMethod.PUT, RequestMethod.POST})
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

        recordTxn(entry.getOfficerId(), entry.getOfficerName(), "MARKETING_OFFICER", "OFFICER_COMMISSION", "DEBIT", entry.getCommissionAmountBdt(), "ADMIN_PAYOUT", paymentRef, "মার্কেটিং অফিসার সম্মানী পরিশোধ (" + entry.getOfficerName() + ")");
        CommissionHelper.syncOfficerCommissionTotals(userRepository, commissionRepository, entry.getOfficerId());
        CommonUtils.notifyUser(notificationRepository, entry.getOfficerId(), "কমিশন পরিশোধ সম্পন্ন: ৳" + entry.getCommissionAmountBdt(),
                "আপনার ৳" + entry.getCommissionAmountBdt() + " সম্মানী পরিশোধ করা হয়েছে। রেফারেন্স: " + paymentRef);

        return ResponseEntity.ok(entry);
    }

    @GetMapping({"/transactions", "/finance/transactions"})
    public ResponseEntity<List<FinancialTransactionEntity>> getAllTransactions() {
        return ResponseEntity.ok(transactionRepository.findAllByOrderByCreatedAtDesc());
    }

    @Transactional
    @PostMapping({"/transactions", "/finance/expenses"})
    public ResponseEntity<FinancialTransactionEntity> createManualTransaction(@RequestBody Map<String, Object> body) {
        FinancialTransactionEntity t = new FinancialTransactionEntity();
        t.setUserName(String.valueOf(body.getOrDefault("userName", "অ্যাডমিন এন্ট্রি")));
        t.setUserRole(String.valueOf(body.getOrDefault("userRole", "ADMIN")));
        t.setFundBucket(String.valueOf(body.getOrDefault("fundBucket", "OPERATIONAL_EXPENSE")));
        t.setTxnType(String.valueOf(body.getOrDefault("txnType", "DEBIT")));
        Object amtObj = body.get("amountBdt") != null ? body.get("amountBdt") : body.get("amount");
        t.setAmountBdt(CommonUtils.parseDecimal(amtObj, BigDecimal.ZERO));
        t.setPaymentMethod(String.valueOf(body.getOrDefault("paymentMethod", "ক্যাশ / ব্যাংক")));
        t.setTransactionId(String.valueOf(body.getOrDefault("transactionId", "EXP-" + System.currentTimeMillis() % 100000)));
        Object descObj = body.get("description") != null ? body.get("description") : body.get("expenseDescription");
        t.setDescription(String.valueOf(descObj != null ? descObj : "পরিচালন ব্যয়"));
        t.setStatus("APPROVED");
        return ResponseEntity.ok(transactionRepository.save(t));
    }

    @Transactional
    @RequestMapping(value = "/transactions/{id}/status", method = {RequestMethod.PUT, RequestMethod.POST})
    public ResponseEntity<?> updateTransactionStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<FinancialTransactionEntity> opt = transactionRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        FinancialTransactionEntity t = opt.get();
        t.setStatus(body.getOrDefault("status", t.getStatus()));
        return ResponseEntity.ok(transactionRepository.save(t));
    }

    private void recordTxn(Long uid, String name, String role, String bucket, String type, BigDecimal amt, String method, String trxId, String desc) {
        FinancialTransactionEntity t = new FinancialTransactionEntity();
        t.setUserId(uid);
        t.setUserName(name);
        t.setUserRole(role);
        t.setFundBucket(bucket);
        t.setTxnType(type);
        t.setAmountBdt(amt);
        t.setPaymentMethod(method);
        t.setTransactionId(trxId);
        t.setDescription(desc);
        t.setStatus("APPROVED");
        transactionRepository.save(t);
    }
}
