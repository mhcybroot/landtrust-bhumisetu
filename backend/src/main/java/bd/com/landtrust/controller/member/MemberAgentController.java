package bd.com.landtrust.controller.member;

import bd.com.landtrust.entity.CommissionEntryEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.CommissionEntryRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.util.UserMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;

@RestController
@RequestMapping({"/api/portal/agent", "/api/member/agent"})
public class MemberAgentController {

    private final UserRepository userRepository;
    private final CommissionEntryRepository commissionRepository;
    private final NotificationRepository notificationRepository;

    public MemberAgentController(
            UserRepository userRepository,
            CommissionEntryRepository commissionRepository,
            NotificationRepository notificationRepository) {
        this.userRepository = userRepository;
        this.commissionRepository = commissionRepository;
        this.notificationRepository = notificationRepository;
    }

    private UserEntity currentUser(Authentication auth) {
        UserEntity u = (UserEntity) auth.getPrincipal();
        return userRepository.findById(u.getId()).orElse(u);
    }

    @GetMapping("/dashboard")
    public ResponseEntity<Map<String, Object>> getAgentDashboard(Authentication auth) {
        UserEntity agent = currentUser(auth);
        List<UserEntity> subordinates = userRepository.findBySupervisorAgentIdOrderByCreatedAtDesc(agent.getId());
        List<CommissionEntryEntity> commissions = commissionRepository.findByOfficerIdOrderByCreatedAtDesc(agent.getId());

        BigDecimal totalEarned = commissions.stream()
                .filter(c -> !"CANCELLED".equals(c.getStatus()))
                .map(CommissionEntryEntity::getCommissionAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal totalPaid = commissions.stream()
                .filter(c -> "PAID".equals(c.getStatus()))
                .map(CommissionEntryEntity::getCommissionAmountBdt)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal pendingPayable = totalEarned.subtract(totalPaid);

        List<Map<String, Object>> subsView = new ArrayList<>();
        for (UserEntity s : subordinates) {
            subsView.add(UserMapper.sanitizeUser(s));
        }

        Map<String, Object> response = new LinkedHashMap<>();
        response.put("agent", UserMapper.sanitizeUser(agent));
        response.put("referralCode", agent.getMyReferralCode());
        response.put("role", agent.getRole());
        response.put("agentTier", agent.getAgentTier());
        response.put("subordinatesCount", subordinates.size());
        response.put("subordinates", subsView);
        response.put("totalEarnedCommission", totalEarned);
        response.put("totalPaidCommission", totalPaid);
        response.put("pendingPayableCommission", pendingPayable);
        response.put("commissions", commissions);

        return ResponseEntity.ok(response);
    }
}
