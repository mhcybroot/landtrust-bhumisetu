package bd.com.landtrust;

import bd.com.landtrust.controller.auth.AuthController;
import bd.com.landtrust.entity.SystemSettingEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.FinancialTransactionRepository;
import bd.com.landtrust.repository.LocationRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.repository.SystemSettingRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.security.JwtService;
import bd.com.landtrust.service.SystemSettingService;
import bd.com.landtrust.util.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

class UserControllerAndSecurityTest {

    private UserRepository userRepository;
    private LocationRepository locationRepository;
    private SystemSettingService settingService;
    private FinancialTransactionRepository transactionRepository;
    private NotificationRepository notificationRepository;
    private PasswordEncoder passwordEncoder;
    private JwtService jwtService;
    private AuthController authController;

    @BeforeEach
    void setUp() {
        userRepository = mock(UserRepository.class);
        locationRepository = mock(LocationRepository.class);
        SystemSettingRepository settingRepository = mock(SystemSettingRepository.class);
        transactionRepository = mock(FinancialTransactionRepository.class);
        notificationRepository = mock(NotificationRepository.class);
        passwordEncoder = new BCryptPasswordEncoder();

        jwtService = new JwtService();
        ReflectionTestUtils.setField(jwtService, "jwtSecret", "12345678901234567890123456789012");
        ReflectionTestUtils.setField(jwtService, "jwtExpirationMs", 3600000L);

        SystemSettingEntity defaultSettings = new SystemSettingEntity();
        defaultSettings.setBuyerRegistrationFee(new BigDecimal("500"));
        defaultSettings.setSellerRegistrationFeeUnion(new BigDecimal("1000"));
        when(settingRepository.findAll()).thenReturn(java.util.List.of(defaultSettings));

        settingService = new SystemSettingService(settingRepository);

        authController = new AuthController(
                userRepository,
                locationRepository,
                settingService,
                transactionRepository,
                notificationRepository,
                passwordEncoder,
                jwtService
        );
    }

    @Test
    @DisplayName("UserMapper sanitization strips sensitive passwordHash and maps core profile fields")
    void testUserSanitizationAndStatus() {
        UserEntity user = new UserEntity();
        user.setId(77L);
        user.setFullName("Rahim Uddin");
        user.setPhoneNumber("01712345678");
        user.setPasswordHash("$2a$10$hashedSecurePasswordString");
        user.setRole("BUYER");
        user.setAccountStatus("ACTIVE");
        user.setDistrict("নোয়াখালী");
        user.setUpazila("নোয়াখালী সদর");

        Map<String, Object> sanitized = UserMapper.sanitizeUser(user);

        assertNotNull(sanitized);
        assertFalse(sanitized.containsKey("passwordHash"), "Sanitized user DTO must not contain passwordHash key");
        assertFalse(sanitized.containsValue(user.getPasswordHash()), "Sanitized user DTO must never leak password hash value");
        assertEquals(77L, sanitized.get("id"));
        assertEquals("Rahim Uddin", sanitized.get("fullName"));
        assertEquals("01712345678", sanitized.get("phoneNumber"));
        assertEquals("BUYER", sanitized.get("role"));
        assertEquals("ACTIVE", sanitized.get("accountStatus"));

        // Null user safe handling
        Map<String, Object> nullMapped = UserMapper.sanitizeUser(null);
        assertNotNull(nullMapped);
        assertTrue(nullMapped.isEmpty());
    }

    @Test
    @DisplayName("JWT secret length validation requires at least 32 characters")
    void testJwtSecretLengthValidation() {
        JwtService service = new JwtService();

        // Null secret should fail validation
        ReflectionTestUtils.setField(service, "jwtSecret", null);
        IllegalStateException nullEx = assertThrows(IllegalStateException.class, service::validateKey);
        assertTrue(nullEx.getMessage().contains("at least 32 characters"));

        // Short secret (< 32 chars) should fail validation
        ReflectionTestUtils.setField(service, "jwtSecret", "short-secret-key-16-char");
        IllegalStateException shortEx = assertThrows(IllegalStateException.class, service::validateKey);
        assertTrue(shortEx.getMessage().contains("at least 32 characters"));

        // Secret with >= 32 chars should pass validation
        String validSecret = "secure-jwt-secret-key-that-is-at-least-32-chars-long";
        ReflectionTestUtils.setField(service, "jwtSecret", validSecret);
        ReflectionTestUtils.setField(service, "jwtExpirationMs", 3600000L);
        assertDoesNotThrow(service::validateKey);

        // Verification token generation with valid secret
        UserEntity user = new UserEntity();
        user.setId(101L);
        user.setPhoneNumber("01711223344");
        user.setRole("BUYER");
        user.setFullName("Test User");

        String token = service.generateToken(user);
        assertNotNull(token);
        assertFalse(token.isBlank());
        assertEquals("101", service.parseToken(token).getSubject());
    }

    @Test
    @DisplayName("Registration rejects duplicate phone numbers and prevents saving duplicate user")
    void testPhoneNumberUniquenessValidation() {
        String existingPhone = "01711223344";
        UserEntity existingUser = new UserEntity();
        existingUser.setId(12L);
        existingUser.setPhoneNumber(existingPhone);

        when(userRepository.findByPhoneNumber(existingPhone)).thenReturn(Optional.of(existingUser));

        Map<String, Object> request = Map.of(
                "fullName", "Duplicate Phone User",
                "phoneNumber", existingPhone,
                "password", "secretPassword123",
                "role", "BUYER"
        );

        ResponseEntity<?> response = authController.register(request);

        assertEquals(400, response.getStatusCode().value());
        @SuppressWarnings("unchecked")
        Map<String, Object> responseBody = (Map<String, Object>) response.getBody();
        assertNotNull(responseBody);
        assertEquals("এই মোবাইল নম্বর দিয়ে ইতোমধ্যে নিবন্ধন করা হয়েছে।", responseBody.get("message"));

        // Verify repository save was never called
        verify(userRepository, never()).save(any());
    }

    @Test
    @DisplayName("Registration hashes password with BCrypt and returns sanitized user without passwordHash")
    void testUserRegistrationPasswordHashing() {
        String phone = "01811223344";
        String plainPassword = "SuperSecretPassword123";

        when(userRepository.findByPhoneNumber(phone)).thenReturn(Optional.empty());
        when(userRepository.save(any(UserEntity.class))).thenAnswer(invocation -> {
            UserEntity u = invocation.getArgument(0);
            u.setId(99L);
            return u;
        });

        Map<String, Object> request = Map.of(
                "fullName", "Farhan Ahmed",
                "phoneNumber", phone,
                "password", plainPassword,
                "role", "BUYER",
                "district", "নোয়াখালী",
                "upazila", "নোয়াখালী সদর"
        );

        ResponseEntity<?> response = authController.register(request);

        assertEquals(200, response.getStatusCode().value());

        // Capture saved entity and verify password hashing
        ArgumentCaptor<UserEntity> userCaptor = ArgumentCaptor.forClass(UserEntity.class);
        verify(userRepository).save(userCaptor.capture());
        UserEntity savedUser = userCaptor.getValue();

        assertNotNull(savedUser.getPasswordHash());
        assertNotEquals(plainPassword, savedUser.getPasswordHash(), "Plaintext password must never be stored");
        assertTrue(passwordEncoder.matches(plainPassword, savedUser.getPasswordHash()), "Password hash must match BCrypt verification");

        // Verify response payload is sanitized
        @SuppressWarnings("unchecked")
        Map<String, Object> body = (Map<String, Object>) response.getBody();
        assertNotNull(body);
        @SuppressWarnings("unchecked")
        Map<String, Object> userDto = (Map<String, Object>) body.get("user");
        assertNotNull(userDto);
        assertFalse(userDto.containsKey("passwordHash"), "Response user object must not leak passwordHash");
        assertEquals("Farhan Ahmed", userDto.get("fullName"));
        assertEquals(phone, userDto.get("phoneNumber"));
    }

    @Test
    @DisplayName("Registration enforces input validation rules on password length, role, and phone format")
    void testRegistrationValidationRules() {
        // Short password (< 6 chars)
        Map<String, Object> shortPwReq = Map.of(
                "fullName", "Test User",
                "phoneNumber", "01711223344",
                "password", "12345",
                "role", "BUYER"
        );
        ResponseEntity<?> respShortPw = authController.register(shortPwReq);
        assertEquals(400, respShortPw.getStatusCode().value());

        // Invalid phone number format
        Map<String, Object> badPhoneReq = Map.of(
                "fullName", "Test User",
                "phoneNumber", "12345",
                "password", "validPassword123",
                "role", "BUYER"
        );
        ResponseEntity<?> respBadPhone = authController.register(badPhoneReq);
        assertEquals(400, respBadPhone.getStatusCode().value());

        // Invalid role
        Map<String, Object> badRoleReq = Map.of(
                "fullName", "Test User",
                "phoneNumber", "01711223344",
                "password", "validPassword123",
                "role", "INVALID_ROLE"
        );
        ResponseEntity<?> respBadRole = authController.register(badRoleReq);
        assertEquals(400, respBadRole.getStatusCode().value());
    }
}
