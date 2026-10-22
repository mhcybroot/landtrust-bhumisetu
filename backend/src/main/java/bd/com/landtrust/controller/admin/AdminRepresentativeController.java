package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.CommissionEntryRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.util.CommonUtils;
import bd.com.landtrust.util.UserMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/admin/representatives")
public class AdminRepresentativeController {

    private final UserRepository userRepository;
    private final CommissionEntryRepository commissionRepository;
    private final NotificationRepository notificationRepository;

    public AdminRepresentativeController(
            UserRepository userRepository,
            CommissionEntryRepository commissionRepository,
            NotificationRepository notificationRepository) {
        this.userRepository = userRepository;
        this.commissionRepository = commissionRepository;
        this.notificationRepository = notificationRepository;
    }

    @GetMapping
    public ResponseEntity<List<Map<String, Object>>> getRepresentatives(
            @RequestParam(required = false) String role,
            @RequestParam(required = false) String district,
            @RequestParam(required = false) String upazila) {
        
        List<String> repRoles = (role != null && !role.isBlank())
                ? List.of(role)
                : List.of("DISTRICT_AGENT", "UPAZILA_AGENT", "MARKETING_OFFICER");

        List<UserEntity> reps = userRepository.findByRoleInOrderByCreatedAtDesc(repRoles);
        List<Map<String, Object>> result = new ArrayList<>();

        for (UserEntity r : reps) {
            if (district != null && !district.isBlank() && !district.equalsIgnoreCase(r.getDistrict()) && !district.equalsIgnoreCase(r.getAssignedDistrict())) {
                continue;
            }
            if (upazila != null && !upazila.isBlank() && !upazila.equalsIgnoreCase(r.getUpazila()) && !upazila.equalsIgnoreCase(r.getAssignedUpazila())) {
                continue;
            }

            Map<String, Object> map = UserMapper.sanitizeUser(r);
            map.put("childSubordinatesCount", userRepository.findBySupervisorAgentIdOrderByCreatedAtDesc(r.getId()).size());
            result.add(map);
        }

        return ResponseEntity.ok(result);
    }

    @RequestMapping(value = "/{id}/jurisdiction", method = {RequestMethod.PUT, RequestMethod.POST})
    public ResponseEntity<?> updateJurisdiction(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        Optional<UserEntity> opt = userRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        UserEntity rep = opt.get();
        if (body.containsKey("assignedDistrict")) rep.setAssignedDistrict((String) body.get("assignedDistrict"));
        if (body.containsKey("assignedUpazila")) rep.setAssignedUpazila((String) body.get("assignedUpazila"));
        if (body.containsKey("assignedSubArea")) rep.setAssignedSubArea((String) body.get("assignedSubArea"));
        if (body.containsKey("agentTier")) rep.setAgentTier((String) body.get("agentTier"));
        
        if (body.containsKey("supervisorAgentId")) {
            Object sId = body.get("supervisorAgentId");
            if (sId != null && !sId.toString().isBlank()) {
                try {
                    Long supId = Long.valueOf(sId.toString().trim());
                    userRepository.findById(supId).ifPresentOrElse(sup -> {
                        rep.setSupervisorAgentId(sup.getId());
                        rep.setSupervisorAgentName(sup.getFullName());
                    }, () -> {
                        rep.setSupervisorAgentId(null);
                        rep.setSupervisorAgentName(null);
                    });
                } catch (NumberFormatException e) {
                    return ResponseEntity.badRequest().body(Map.of("message", "সুপারভাইজার আইডি সঠিক নয়।"));
                }
            } else {
                rep.setSupervisorAgentId(null);
                rep.setSupervisorAgentName(null);
            }
        }

        userRepository.save(rep);
        CommonUtils.notifyUser(notificationRepository, rep.getId(), "প্রতিনিধি এলাকা আপডেট",
                "আপনার দায়িত্বপ্রাপ্ত এলাকা বা সুপারভাইজার তথ্য অ্যাডমিন কর্তৃক হালনাগাদ করা হয়েছে।");

        return ResponseEntity.ok(UserMapper.sanitizeUser(rep));
    }

    @RequestMapping(value = "/{id}/approve", method = {RequestMethod.PUT, RequestMethod.POST})
    public ResponseEntity<?> approveRepresentative(@PathVariable Long id) {
        Optional<UserEntity> opt = userRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        UserEntity rep = opt.get();
        rep.setAccountStatus("ACTIVE");
        userRepository.save(rep);

        CommonUtils.notifyUser(notificationRepository, rep.getId(), "প্রতিনিধি অ্যাকাউন্ট অনুমোদিত!",
                "অভিনন্দন! আপনার " + rep.getRole() + " অ্যাকাউন্টটি কেন্দ্রীয়ভাবে সক্রিয় করা হয়েছে।");

        return ResponseEntity.ok(UserMapper.sanitizeUser(rep));
    }
}
