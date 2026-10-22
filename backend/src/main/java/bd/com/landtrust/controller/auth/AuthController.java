package bd.com.landtrust.controller.auth;

import bd.com.landtrust.entity.FinancialTransactionEntity;
import bd.com.landtrust.entity.LocationEntity;
import bd.com.landtrust.entity.NotificationEntity;
import bd.com.landtrust.entity.SystemSettingEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.FinancialTransactionRepository;
import bd.com.landtrust.repository.LocationRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.repository.SystemSettingRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.security.JwtService;
import bd.com.landtrust.util.UserMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api")
public class AuthController {

    private final UserRepository userRepository;
    private final LocationRepository locationRepository;
    private final SystemSettingRepository settingRepository;
    private final FinancialTransactionRepository transactionRepository;
    private final NotificationRepository notificationRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthController(
            UserRepository userRepository,
            LocationRepository locationRepository,
            SystemSettingRepository settingRepository,
            FinancialTransactionRepository transactionRepository,
            NotificationRepository notificationRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService) {
        this.userRepository = userRepository;
        this.locationRepository = locationRepository;
        this.settingRepository = settingRepository;
        this.transactionRepository = transactionRepository;
        this.notificationRepository = notificationRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    private SystemSettingEntity getSettings() {
        return settingRepository.findAll().stream().findFirst().orElseGet(() -> {
            SystemSettingEntity def = new SystemSettingEntity();
            return settingRepository.save(def);
        });
    }

    @PostMapping("/auth/register")
    public ResponseEntity<?> register(@RequestBody Map<String, Object> body) {
        String fullName = (String) body.getOrDefault("fullName", "");
        String phoneNumber = ((String) body.getOrDefault("phoneNumber", "")).trim();
        String password = (String) body.getOrDefault("password", "");
        String role = ((String) body.getOrDefault("role", "BUYER")).toUpperCase();
        String district = (String) body.getOrDefault("district", "নোয়াখালী");
        String upazila = (String) body.getOrDefault("upazila", "নোয়াখালী সদর");
        String address = (String) body.getOrDefault("address", "");
        String referralCodeInput = ((String) body.getOrDefault("referralCode", "")).trim();
        String paymentMethod = (String) body.getOrDefault("paymentMethod", "বিকাশ (bKash)");
        String senderPhone = (String) body.getOrDefault("senderPhone", phoneNumber);
        String transactionId = ((String) body.getOrDefault("transactionId", "")).trim();

        if (fullName.isBlank() || phoneNumber.isBlank() || password.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("message", "নাম, মোবাইল নম্বর এবং পাসওয়ার্ড আবশ্যক।"));
        }
        if (!phoneNumber.matches("^01[3-9]\\d{8}$")) {
            return ResponseEntity.badRequest().body(Map.of("message", "সঠিক ১১ ডিজিটের বাংলাদেশী মোবাইল নম্বর দিন (যেমন: 017xxxxxxxx)"));
        }
        if (password.length() < 6) {
            return ResponseEntity.badRequest().body(Map.of("message", "পাসওয়ার্ড ন্যূনতম ৬ অক্ষরের হতে হবে।"));
        }
        if (!List.of("BUYER", "SELLER", "MARKETING_OFFICER", "UPAZILA_AGENT", "DISTRICT_AGENT").contains(role)) {
            return ResponseEntity.badRequest().body(Map.of("message", "সঠিক সদস্যের ধরন নির্বাচন করুন।"));
        }
        if (userRepository.findByPhoneNumber(phoneNumber).isPresent()) {
            return ResponseEntity.badRequest().body(Map.of("message", "এই মোবাইল নম্বর দিয়ে ইতোমধ্যে নিবন্ধন করা হয়েছে।"));
        }

        SystemSettingEntity settings = getSettings();
        boolean isPourashava = false;
        List<LocationEntity> locs = locationRepository.findByDistrictNameBnAndUpazilaNameBn(district, upazila);
        if (!locs.isEmpty()) {
            isPourashava = locs.stream().anyMatch(l -> "POURASHAVA".equalsIgnoreCase(l.getAreaType()));
        }
        if (!isPourashava && upazila != null) {
            String uLower = upazila.toLowerCase();
            if (uLower.contains("পৌরসভা") || uLower.contains("সিটি কর্পোরেশন") || uLower.contains("pourashava")) {
                isPourashava = true;
            }
        }

        BigDecimal feeAmount;
        if ("DISTRICT_AGENT".equals(role)) {
            feeAmount = settings.getDistrictAgentRegistrationFee();
        } else if ("UPAZILA_AGENT".equals(role)) {
            feeAmount = settings.getUpazilaAgentRegistrationFee();
        } else if ("MARKETING_OFFICER".equals(role)) {
            feeAmount = isPourashava ? settings.getOfficerRegistrationFeePourashava() : settings.getOfficerRegistrationFeeUnion();
        } else if ("SELLER".equals(role)) {
            feeAmount = isPourashava ? settings.getSellerRegistrationFeePourashava() : settings.getSellerRegistrationFeeUnion();
        } else {
            feeAmount = settings.getBuyerRegistrationFee();
        }

        UserEntity user = new UserEntity();
        user.setFullName(fullName);
        user.setPhoneNumber(phoneNumber);
        user.setPasswordHash(passwordEncoder.encode(password));
        user.setRole(role);
        user.setAccountStatus("PAYMENT_SUBMITTED");
        user.setDistrict(district);
        user.setUpazila(upazila);
        user.setAddress(address);
        user.setRegistrationFeeAmount(feeAmount);
        user.setPaymentMethod(paymentMethod);
        user.setSenderPhone(senderPhone);
        user.setTransactionId(transactionId.isBlank() ? "PENDING-TRX" : transactionId);

        if (!referralCodeInput.isBlank() && ("BUYER".equals(role) || "SELLER".equals(role))) {
            Optional<UserEntity> officerOpt = userRepository.findByMyReferralCodeIgnoreCase(referralCodeInput);
            if (officerOpt.isEmpty()) {
                return ResponseEntity.badRequest().body(Map.of("message", "প্রদত্ত রেফারেল কোডটি সঠিক নয়।"));
            }
            UserEntity officer = officerOpt.get();
            user.setReferredByOfficerId(officer.getId());
            user.setReferredByCode(officer.getMyReferralCode());
            user.setReferredByOfficerName(officer.getFullName());
        }

        if ("DISTRICT_AGENT".equals(role)) {
            user.setAgentTier("DISTRICT");
            user.setAssignedDistrict(district);
            long count = userRepository.findByRoleOrderByCreatedAtDesc("DISTRICT_AGENT").size() + 101;
            String code = "LT-DIST-" + count;
            while (userRepository.findByMyReferralCodeIgnoreCase(code).isPresent()) {
                count++;
                code = "LT-DIST-" + count;
            }
            user.setMyReferralCode(code);
        } else if ("UPAZILA_AGENT".equals(role)) {
            user.setAgentTier("UPAZILA");
            user.setAssignedDistrict(district);
            user.setAssignedUpazila(upazila);
            Optional<UserEntity> distAgent = userRepository.findFirstByRoleAndDistrictAndAccountStatus("DISTRICT_AGENT", district, "ACTIVE");
            if (distAgent.isPresent()) {
                user.setSupervisorAgentId(distAgent.get().getId());
                user.setSupervisorAgentName(distAgent.get().getFullName());
            }
            long count = userRepository.findByRoleOrderByCreatedAtDesc("UPAZILA_AGENT").size() + 501;
            String code = "LT-UPZ-" + count;
            while (userRepository.findByMyReferralCodeIgnoreCase(code).isPresent()) {
                count++;
                code = "LT-UPZ-" + count;
            }
            user.setMyReferralCode(code);
        } else if ("MARKETING_OFFICER".equals(role)) {
            user.setAgentTier(isPourashava ? "POURASHAVA" : "UNION");
            user.setAssignedDistrict(district);
            user.setAssignedUpazila(upazila);
            user.setAssignedSubArea(address);
            Optional<UserEntity> upzAgent = userRepository.findFirstByRoleAndDistrictAndUpazilaAndAccountStatus("UPAZILA_AGENT", district, upazila, "ACTIVE");
            if (upzAgent.isPresent()) {
                user.setSupervisorAgentId(upzAgent.get().getId());
                user.setSupervisorAgentName(upzAgent.get().getFullName());
            }
            long count = userRepository.findByRoleOrderByCreatedAtDesc("MARKETING_OFFICER").size() + 1001;
            String code = "LT-OFF-" + count;
            while (userRepository.findByMyReferralCodeIgnoreCase(code).isPresent()) {
                count++;
                code = "LT-OFF-" + count;
            }
            user.setMyReferralCode(code);
        }

        user = userRepository.save(user);

        FinancialTransactionEntity txn = new FinancialTransactionEntity();
        txn.setUserId(user.getId());
        txn.setUserName(user.getFullName());
        txn.setUserRole(user.getRole());
        txn.setFundBucket("REG_FEE_FUND");
        txn.setTxnType("CREDIT");
        txn.setAmountBdt(feeAmount);
        txn.setPaymentMethod(paymentMethod);
        txn.setSenderPhone(senderPhone);
        txn.setTransactionId(user.getTransactionId());
        txn.setDescription(role + " নিবন্ধন ফি (" + user.getFullName() + ")");
        txn.setStatus("PENDING_VERIFICATION");
        transactionRepository.save(txn);

        NotificationEntity n = new NotificationEntity();
        n.setUserId(user.getId());
        n.setTitle("ভূমি সেতুতে স্বাগতম!");
        n.setMessage("আপনার নিবন্ধন ও TrxID (" + user.getTransactionId() + ") জমা হয়েছে। অ্যাডমিন যাচাই করে আপনার অ্যাকাউন্ট সক্রিয় করবেন।");
        notificationRepository.save(n);

        if (user.getReferredByOfficerId() != null) {
            NotificationEntity on = new NotificationEntity();
            on.setUserId(user.getReferredByOfficerId());
            on.setTitle("নতুন রেফারেল সদস্য যুক্ত হয়েছেন");
            on.setMessage(user.getFullName() + " (" + user.getRole() + ") আপনার রেফারেল কোড ব্যবহার করে নিবন্ধন করেছেন।");
            notificationRepository.save(on);
        }

        String token = jwtService.generateToken(user);
        return ResponseEntity.ok(Map.of(
                "token", token,
                "user", UserMapper.sanitizeUser(user),
                "message", "নিবন্ধন সফল হয়েছে! অ্যাডমিন আপনার পেমেন্ট (TrxID) যাচাই করে অ্যাকাউন্ট সক্রিয় করবেন।"
        ));
    }

    @PostMapping("/auth/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {
        String phoneNumber = body.getOrDefault("phoneNumber", "").trim();
        String password = body.getOrDefault("password", "");

        Optional<UserEntity> userOpt = userRepository.findByPhoneNumber(phoneNumber);
        if (userOpt.isEmpty() || !passwordEncoder.matches(password, userOpt.get().getPasswordHash())) {
            return ResponseEntity.status(401).body(Map.of("message", "মোবাইল নম্বর বা পাসওয়ার্ড সঠিক নয়।"));
        }

        UserEntity user = userOpt.get();
        if ("SUSPENDED".equals(user.getAccountStatus())) {
            return ResponseEntity.status(403).body(Map.of(
                    "message", "আপনার অ্যাকাউন্টটি বর্তমানে স্থগিত (Suspended) অবস্থায় রয়েছে। অ্যাডমিনের সাথে যোগাযোগ করুন।"
            ));
        }

        String token = jwtService.generateToken(user);
        return ResponseEntity.ok(Map.of(
                "token", token,
                "user", UserMapper.sanitizeUser(user)
        ));
    }

    @GetMapping("/user/me")
    public ResponseEntity<?> getCurrentUser(Authentication auth) {
        if (auth == null || !(auth.getPrincipal() instanceof UserEntity user)) {
            return ResponseEntity.status(401).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }
        UserEntity fresh = userRepository.findById(user.getId()).orElse(user);
        return ResponseEntity.ok(UserMapper.sanitizeUser(fresh));
    }
}
