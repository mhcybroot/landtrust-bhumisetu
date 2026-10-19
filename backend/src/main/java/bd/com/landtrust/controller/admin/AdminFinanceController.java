package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.*;
import bd.com.landtrust.util.CommissionHelper;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
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

    public AdminFinanceController(
            UserRepository userRepository, ServiceProposalRepository proposalRepository,
            CommissionEntryRepository commissionRepository, FinancialTransactionRepository transactionRepository,
            NotificationRepository notificationRepository) {
        this.userRepository = userRepository;
        this.proposalRepository = proposalRepository;
        this.commissionRepository = commissionRepository;
        this.transactionRepository = transactionRepository;
        this.notificationRepository = notificationRepository;
    }

    @GetMapping("/proposals")
    public ResponseEntity<List<ServiceProposalEntity>> getAllProposals() {
        return ResponseEntity.ok(proposalRepository.findAllByOrderByCreatedAtDesc());
    }

    @PutMapping("/proposals/{id}")
    public ResponseEntity<?> updateProposalByAdmin(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Optional<ServiceProposalEntity> opt = proposalRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        ServiceProposalEntity p = opt.get();
        if (body.containsKey("status")) p.setStatus(String.valueOf(body.get("status")));
        if (body.containsKey("adminCounterFeeBdt")) {
            p.setAdminCounterFeeBdt(CommonUtils.parseDecimal(body.get("adminCounterFeeBdt"), p.getAdminCounterFeeBdt()));
        }
        if (body.containsKey("finalAgreedFeeBdt")) {
            p.setFinalAgreedFeeBdt(CommonUtils.parseDecimal(body.get("finalAgreedFeeBdt"), p.getFinalAgreedFeeBdt()));
        }
        if (body.containsKey("adminNote")) p.setAdminNote(String.valueOf(body.get("adminNote")));

        p = proposalRepository.save(p);
        CommonUtils.notifyUser(notificationRepository, p.getUserId(), "বিশেষ সেবা প্রস্তাবের আপডেট: " + p.getProposalTitle(),
                "অবস্থা: " + p.getStatus() + (p.getAdminCounterFeeBdt() != null ? " | পাল্টা ফি: ৳" + p.getAdminCounterFeeBdt() : "")
                        + (p.getAdminNote() != null && !p.getAdminNote().isBlank() ? " | নোট: " + p.getAdminNote() : ""));

        if ("COMPLETED".equals(p.getStatus())) {
            BigDecimal revenue = p.getFinalAgreedFeeBdt() != null ? p.getFinalAgreedFeeBdt() : p.getCustomerProposedFeeBdt();
            if (revenue != null && revenue.compareTo(BigDecimal.ZERO) > 0) {
                recordTxn(p.getUserId(), p.getUserName(), p.getUserRole(), "SERVICE_REVENUE", "CREDIT", revenue, "AGREED_CONTRACT", "DEAL-" + p.getId(), "বিশেষ সেবার পারিশ্রমিক: " + p.getProposalTitle());
            }
        }
        return ResponseEntity.ok(p);
    }

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

        String commissionType = String.valueOf(body.getOrDefault("commissionType", "DEAL_CLOSURE_FIXED"));
        BigDecimal baseDealAmount = CommonUtils.parseDecimal(body.get("baseDealAmountBdt"), BigDecimal.ZERO);
        BigDecimal percentageRate = CommonUtils.parseDecimal(body.get("percentageRate"), BigDecimal.ZERO);
        BigDecimal customFixedAmount = CommonUtils.parseDecimal(body.get("commissionAmountBdt"), BigDecimal.ZERO);
        String note = String.valueOf(body.getOrDefault("note", "অ্যাডমিন কর্তৃক অনুমোদিত কমিশন"));

        BigDecimal finalCommission = "DEAL_CLOSURE_PERCENT".equals(commissionType)
                ? baseDealAmount.multiply(percentageRate).divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP)
                : customFixedAmount;

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
        CommissionHelper.syncOfficerCommissionTotals(userRepository, commissionRepository, officer.getId());
        CommonUtils.notifyUser(notificationRepository, officer.getId(), "নতুন কমিশন অনুমোদিত: ৳" + finalCommission,
                "রেফারকৃত সদস্য " + referredUser.getFullName() + " এর বিপরীতে ৳" + finalCommission + " কমিশন অনুমোদিত (" + note + ")।");

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

        recordTxn(entry.getOfficerId(), entry.getOfficerName(), "MARKETING_OFFICER", "OFFICER_COMMISSION", "DEBIT", entry.getCommissionAmountBdt(), "ADMIN_PAYOUT", paymentRef, "মার্কেটিং অফিসার সম্মানী পরিশোধ (" + entry.getOfficerName() + ")");
        CommissionHelper.syncOfficerCommissionTotals(userRepository, commissionRepository, entry.getOfficerId());
        CommonUtils.notifyUser(notificationRepository, entry.getOfficerId(), "কমিশন পরিশোধ সম্পন্ন: ৳" + entry.getCommissionAmountBdt(),
                "আপনার ৳" + entry.getCommissionAmountBdt() + " সম্মানী পরিশোধ করা হয়েছে। রেফারেন্স: " + paymentRef);

        return ResponseEntity.ok(entry);
    }

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
        t.setAmountBdt(CommonUtils.parseDecimal(body.get("amountBdt"), BigDecimal.ZERO));
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
