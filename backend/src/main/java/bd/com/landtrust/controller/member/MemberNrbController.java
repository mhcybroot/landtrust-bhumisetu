package bd.com.landtrust.controller.member;

import bd.com.landtrust.entity.NrbServiceRequestEntity;
import bd.com.landtrust.entity.NotificationEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.NrbServiceRequestRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping({"/api/portal/nrb", "/api/member/nrb"})
public class MemberNrbController {

    private final NrbServiceRequestRepository nrbRepository;
    private final UserRepository userRepository;
    private final NotificationRepository notificationRepository;

    public MemberNrbController(
            NrbServiceRequestRepository nrbRepository,
            UserRepository userRepository,
            NotificationRepository notificationRepository) {
        this.nrbRepository = nrbRepository;
        this.userRepository = userRepository;
        this.notificationRepository = notificationRepository;
    }

    private UserEntity currentUser(Authentication auth) {
        UserEntity u = (UserEntity) auth.getPrincipal();
        return userRepository.findById(u.getId()).orElse(u);
    }

    @GetMapping("/my-requests")
    public ResponseEntity<List<NrbServiceRequestEntity>> getMyRequests(Authentication auth) {
        UserEntity user = currentUser(auth);
        return ResponseEntity.ok(nrbRepository.findByUserIdOrderByCreatedAtDesc(user.getId()));
    }

    @PostMapping("/request")
    public ResponseEntity<?> submitNrbRequest(Authentication auth, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        if (!"ACTIVE".equals(user.getAccountStatus())) {
            return ResponseEntity.status(403).body(Map.of(
                    "message", "আপনার অ্যাকাউন্টটি সক্রিয় (ACTIVE) নয়। প্রবাসী সেবা আবেদন করতে অ্যাকাউন্টটি সক্রিয় হওয়া আবশ্যক।",
                    "accountStatus", user.getAccountStatus()
            ));
        }

        String applicantName = (String) body.getOrDefault("applicantName", user.getFullName());
        String country = (String) body.getOrDefault("countryOfResidence", "সৌদি আরব");
        String overseasPhone = (String) body.getOrDefault("overseasPhone", user.getPhoneNumber());
        String district = (String) body.getOrDefault("district", user.getDistrict() != null ? user.getDistrict() : "নোয়াখালী");
        String upazila = (String) body.getOrDefault("upazila", user.getUpazila() != null ? user.getUpazila() : "নোয়াখালী সদর");
        String serviceType = (String) body.getOrDefault("serviceType", "INSTITUTIONAL_REPRESENTATION");

        NrbServiceRequestEntity req = new NrbServiceRequestEntity();
        req.setUserId(user.getId());
        req.setApplicantName(applicantName);
        req.setPassportNumber((String) body.get("passportNumber"));
        req.setCountryOfResidence(country);
        req.setOverseasPhone(overseasPhone);
        req.setWhatsappNumber((String) body.getOrDefault("whatsappNumber", overseasPhone));
        req.setDistrict(district);
        req.setUpazila(upazila);
        req.setMouza((String) body.get("mouza"));
        req.setKhatianNo((String) body.get("khatianNo"));
        req.setDagNo((String) body.get("dagNo"));
        req.setLandAreaDecimal(CommonUtils.parseDecimal(body.get("landAreaDecimal"), BigDecimal.ZERO));
        req.setAskingPriceBdt(CommonUtils.parseDecimal(body.get("askingPriceBdt"), BigDecimal.ZERO));
        req.setServiceType(serviceType);
        req.setPoaStatus("SUBMITTED");
        req.setAdminNotes((String) body.get("notes"));
        req.setDocumentUrls((String) body.get("documentUrls"));
        req.setCreatedAt(LocalDateTime.now());
        req.setUpdatedAt(LocalDateTime.now());

        req = nrbRepository.save(req);

        CommonUtils.notifyUser(notificationRepository, user.getId(),
                "প্রবাসী প্রতিনিধিত্ব/PoA আবেদন জমা হয়েছে",
                "আপনার " + req.getDistrict() + " জেলার প্রপার্টির জন্য " +
                ("POWER_OF_ATTORNEY".equals(serviceType) ? "পাওয়ার অব অ্যাটর্নি (PoA)" : "প্রাতিষ্ঠানিক প্রতিনিধিত্ব") +
                " সেবা আবেদনটি সফলভাবে গৃহীত হয়েছে। আমাদের লিগ্যাল টিম পর্যালোচনা করে দ্রুত যোগাযোগ করবে।");

        return ResponseEntity.ok(req);
    }
}
