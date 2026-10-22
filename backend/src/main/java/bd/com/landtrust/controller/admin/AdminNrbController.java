package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.NrbServiceRequestEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.NrbServiceRequestRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin/nrb")
public class AdminNrbController {

    private final NrbServiceRequestRepository nrbRepository;
    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;

    public AdminNrbController(
            NrbServiceRequestRepository nrbRepository,
            UserRepository userRepository,
            NotificationRepository notificationRepository) {
        this.nrbRepository = nrbRepository;
        this.userRepository = userRepository;
        this.notificationRepository = notificationRepository;
    }

    @GetMapping("/requests")
    public ResponseEntity<List<NrbServiceRequestEntity>> getAllRequests() {
        return ResponseEntity.ok(nrbRepository.findAllByOrderByCreatedAtDesc());
    }

    @PutMapping("/requests/{id}/status")
    public ResponseEntity<?> updateRequestStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<NrbServiceRequestEntity> opt = nrbRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        NrbServiceRequestEntity req = opt.get();
        if (body.containsKey("poaStatus")) {
            req.setPoaStatus(body.get("poaStatus"));
        }
        if (body.containsKey("adminNotes")) {
            req.setAdminNotes(body.get("adminNotes"));
        }
        req.setUpdatedAt(LocalDateTime.now());
        req = nrbRepository.save(req);

        if (req.getUserId() != null) {
            CommonUtils.notifyUser(notificationRepository, req.getUserId(),
                    "প্রবাসী সেবা আবেদনের স্ট্যাটাস আপডেট",
                    "আপনার আবেদনের বর্তমান অবস্থা: " + req.getPoaStatus() +
                    (req.getAdminNotes() != null ? " (নোট: " + req.getAdminNotes() + ")" : ""));
        }

        return ResponseEntity.ok(req);
    }

    @PutMapping("/requests/{id}/assign")
    public ResponseEntity<?> assignAgent(@PathVariable Long id, @RequestBody Map<String, Object> body) {
        Optional<NrbServiceRequestEntity> opt = nrbRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();

        NrbServiceRequestEntity req = opt.get();
        if (body.containsKey("agentId")) {
            Long agentId = Long.valueOf(String.valueOf(body.get("agentId")));
            Optional<UserEntity> agentOpt = userRepository.findById(agentId);
            if (agentOpt.isPresent()) {
                UserEntity agent = agentOpt.get();
                req.setAssignedAgentId(agent.getId());
                req.setAssignedAgentName(agent.getFullName() + " (" + agent.getRole() + ")");
                CommonUtils.notifyUser(notificationRepository, agent.getId(),
                        "নতুন প্রবাসী প্রতিনিধিত্ব দায়িত্ব অর্পণ",
                        "আপনাকে " + req.getApplicantName() + " (" + req.getCountryOfResidence() + ") এর " + req.getUpazila() + " এলাকার প্রপার্টির প্রতিনিধি হিসেবে মনোনীত করা হয়েছে।");
            }
        }
        req.setUpdatedAt(LocalDateTime.now());
        return ResponseEntity.ok(nrbRepository.save(req));
    }
}
