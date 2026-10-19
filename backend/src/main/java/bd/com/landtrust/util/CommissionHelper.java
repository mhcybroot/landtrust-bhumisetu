package bd.com.landtrust.util;

import bd.com.landtrust.entity.CommissionEntryEntity;
import bd.com.landtrust.repository.CommissionEntryRepository;
import bd.com.landtrust.repository.UserRepository;

import java.math.BigDecimal;
import java.util.List;

public class CommissionHelper {

    private CommissionHelper() {}

    public static void syncOfficerCommissionTotals(UserRepository userRepo, CommissionEntryRepository commRepo, Long officerId) {
        if (userRepo == null || commRepo == null || officerId == null) return;
        userRepo.findById(officerId).ifPresent(officer -> {
            List<CommissionEntryEntity> all = commRepo.findByOfficerIdOrderByCreatedAtDesc(officerId);
            BigDecimal earned = all.stream()
                    .filter(c -> !"CANCELLED".equals(c.getStatus()))
                    .map(CommissionEntryEntity::getCommissionAmountBdt)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            BigDecimal paid = all.stream()
                    .filter(c -> "PAID".equals(c.getStatus()))
                    .map(CommissionEntryEntity::getCommissionAmountBdt)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            officer.setTotalEarnedCommission(earned);
            officer.setTotalPaidCommission(paid);
            userRepo.save(officer);
        });
    }
}
