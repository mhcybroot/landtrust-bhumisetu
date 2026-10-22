package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.*;
import bd.com.landtrust.service.SystemSettingService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.*;

@RestController
@RequestMapping("/api/admin")
public class AdminDashboardController {

    private final UserRepository userRepository;
    private final SystemSettingService settingService;
    private final LandListingRepository listingRepository;
    private final BuyerRequirementRepository requirementRepository;
    private final LandInquiryRepository inquiryRepository;
    private final ServiceProposalRepository proposalRepository;
    private final CommissionEntryRepository commissionRepository;
    private final FinancialTransactionRepository transactionRepository;

    public AdminDashboardController(
            UserRepository userRepository,
            SystemSettingService settingService,
            LandListingRepository listingRepository,
            BuyerRequirementRepository requirementRepository,
            LandInquiryRepository inquiryRepository,
            ServiceProposalRepository proposalRepository,
            CommissionEntryRepository commissionRepository,
            FinancialTransactionRepository transactionRepository) {
        this.userRepository = userRepository;
        this.settingService = settingService;
        this.listingRepository = listingRepository;
        this.requirementRepository = requirementRepository;
        this.inquiryRepository = inquiryRepository;
        this.proposalRepository = proposalRepository;
        this.commissionRepository = commissionRepository;
        this.transactionRepository = transactionRepository;
    }

    private SystemSettingEntity getSettings() {
        return settingService.getSettings();
    }

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getAdminDashboard() {
        List<UserEntity> users = userRepository.findAllByOrderByCreatedAtDesc();
        List<LandListingEntity> listings = listingRepository.findAllByOrderByCreatedAtDesc();
        List<BuyerRequirementEntity> requirements = requirementRepository.findAllByOrderByCreatedAtDesc();
        List<FinancialTransactionEntity> transactions = transactionRepository.findAllByOrderByCreatedAtDesc();
        List<CommissionEntryEntity> commissions = commissionRepository.findAllByOrderByCreatedAtDesc();
        SystemSettingEntity settings = getSettings();

        long totalBuyers = users.stream().filter(u -> "BUYER".equals(u.getRole())).count();
        long totalSellers = users.stream().filter(u -> "SELLER".equals(u.getRole())).count();
        long totalOfficers = users.stream().filter(u -> "MARKETING_OFFICER".equals(u.getRole())).count();
        long pendingUsers = users.stream().filter(u -> "PAYMENT_SUBMITTED".equals(u.getAccountStatus())).count();

        BigDecimal regFeeCollected = sumTransactions(transactions, "REG_FEE_FUND", "CREDIT", "APPROVED");
        BigDecimal regFeePending = sumTransactions(transactions, "REG_FEE_FUND", "CREDIT", "PENDING_VERIFICATION");
        BigDecimal regFeeRefunded = sumTransactions(transactions, "REG_FEE_FUND", "REFUND", "APPROVED");

        BigDecimal serviceRevenue = sumTransactions(transactions, "SERVICE_REVENUE", "CREDIT", "APPROVED");
        BigDecimal operationalExpenses = sumTransactions(transactions, "OPERATIONAL_EXPENSE", "DEBIT", "APPROVED");

        BigDecimal totalCommissionEarned = commissions.stream()
                .filter(c -> !"CANCELLED".equals(c.getStatus()))
                .map(CommissionEntryEntity::getCommissionAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalCommissionPaid = commissions.stream()
                .filter(c -> "PAID".equals(c.getStatus()))
                .map(CommissionEntryEntity::getCommissionAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal pendingCommissionPayable = totalCommissionEarned.subtract(totalCommissionPaid);

        BigDecimal netRegFee = regFeeCollected.subtract(regFeeRefunded);
        BigDecimal advisoryReserveAmount = netRegFee
                .multiply(settings.getAdvisoryReservePercent())
                .divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP);

        BigDecimal totalInflow = netRegFee.add(serviceRevenue);
        BigDecimal totalOutflow = operationalExpenses.add(totalCommissionPaid);
        BigDecimal netOperatingBalance = totalInflow.subtract(totalOutflow);

        List<Map<String, Object>> autoMatches = computeAutoMatches(listings, requirements);

        Map<String, Object> res = new LinkedHashMap<>();
        res.put("totalMembers", users.size());
        res.put("totalBuyers", totalBuyers);
        res.put("totalSellers", totalSellers);
        res.put("totalOfficers", totalOfficers);
        res.put("pendingUsers", pendingUsers);
        res.put("totalListings", listings.size());
        res.put("publishedListings", listings.stream().filter(l -> "APPROVED_PUBLISHED".equals(l.getListingStatus())).count());
        res.put("totalRequirements", requirements.size());
        res.put("totalInquiries", inquiryRepository.count());
        res.put("totalProposals", proposalRepository.count());

        Map<String, Object> finance = new LinkedHashMap<>();
        finance.put("regFeeCollected", netRegFee);
        finance.put("regFeePending", regFeePending);
        finance.put("advisoryReservePercent", settings.getAdvisoryReservePercent());
        finance.put("advisoryReserveRecommendation", advisoryReserveAmount);
        finance.put("advisoryNote", "পরামর্শ: কোনো তহবিল লক করা নেই। তবে সম্ভাব্য রিফান্ড ও জরুরি প্রয়োজনে নিবন্ধন তহবিলের "
                + settings.getAdvisoryReservePercent() + "% (৳" + advisoryReserveAmount + ") হাতে রাখার পরামর্শ দেওয়া হলো।");
        finance.put("serviceRevenue", serviceRevenue);
        finance.put("totalCommissionEarned", totalCommissionEarned);
        finance.put("totalCommissionPaid", totalCommissionPaid);
        finance.put("pendingCommissionPayable", pendingCommissionPayable);
        finance.put("operationalExpenses", operationalExpenses);
        finance.put("netOperatingBalance", netOperatingBalance);

        res.put("finance", finance);
        res.put("autoMatches", autoMatches);
        res.put("settings", settings);
        return ResponseEntity.ok(res);
    }

    private BigDecimal sumTransactions(List<FinancialTransactionEntity> list, String bucket, String type, String status) {
        return list.stream()
                .filter(t -> bucket.equals(t.getFundBucket()) && type.equals(t.getTxnType()) && status.equals(t.getStatus()))
                .map(FinancialTransactionEntity::getAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private List<Map<String, Object>> computeAutoMatches(List<LandListingEntity> listings, List<BuyerRequirementEntity> reqs) {
        List<BuyerRequirementEntity> activeReqs = reqs.stream()
                .filter(r -> "ACTIVE".equals(r.getStatus()) || "MATCHED".equals(r.getStatus()) || "SUBMITTED".equals(r.getStatus()))
                .limit(50)
                .toList();

        List<LandListingEntity> activeListings = listings.stream()
                .filter(l -> "APPROVED_PUBLISHED".equals(l.getListingStatus()) || "RESERVED".equals(l.getListingStatus()))
                .limit(100)
                .toList();

        List<Map<String, Object>> matches = new ArrayList<>();
        for (BuyerRequirementEntity req : activeReqs) {
            for (LandListingEntity land : activeListings) {
                int score = 0;
                List<String> reasons = new ArrayList<>();
                if (req.getPreferredDistrict() != null && req.getPreferredDistrict().equalsIgnoreCase(land.getDistrict())) score += 20;
                if (req.getPreferredUpazila() != null && req.getPreferredUpazila().equalsIgnoreCase(land.getUpazila())) {
                    score += 35;
                    reasons.add("একই উপজেলা (" + land.getUpazila() + ")");
                }
                if (req.getLandType() != null && req.getLandType().equalsIgnoreCase(land.getLandType())) {
                    score += 25;
                    reasons.add("জমির ধরন মিলেছে (" + land.getLandType() + ")");
                }
                if (req.getMaxBudgetBdt() != null && land.getExpectedPriceBdt() != null) {
                    BigDecimal maxWithTolerance = req.getMaxBudgetBdt().multiply(new BigDecimal("1.15"));
                    if (land.getExpectedPriceBdt().compareTo(maxWithTolerance) <= 0) {
                        score += 20;
                        reasons.add("বাজেটের মধ্যে (৳" + land.getExpectedPriceBdt() + ")");
                    }
                }
                if (score >= 55) {
                    Map<String, Object> m = new LinkedHashMap<>();
                    m.put("matchScore", score);
                    m.put("reasons", String.join(" • ", reasons));
                    m.put("listingId", land.getId());
                    m.put("listingTitle", land.getTitle());
                    m.put("sellerName", land.getSellerName());
                    m.put("sellerPhone", land.getSellerPhone());
                    m.put("expectedPriceBdt", land.getExpectedPriceBdt());
                    m.put("areaDecimal", land.getAreaDecimal());
                    m.put("requirementId", req.getId());
                    m.put("buyerName", req.getBuyerName());
                    m.put("buyerPhone", req.getBuyerPhone());
                    m.put("buyerMaxBudgetBdt", req.getMaxBudgetBdt());
                    matches.add(m);
                }
            }
        }
        matches.sort((a, b) -> Integer.compare((int) b.get("matchScore"), (int) a.get("matchScore")));
        return matches.stream().limit(50).toList();
    }
}
