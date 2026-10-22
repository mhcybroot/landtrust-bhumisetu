package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "users", indexes = {
    @Index(name = "idx_users_role_status", columnList = "role, account_status"),
    @Index(name = "idx_users_referral_code", columnList = "my_referral_code"),
    @Index(name = "idx_users_referred_by", columnList = "referred_by_officer_id")
})
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String fullName;

    @Column(nullable = false, unique = true)
    private String phoneNumber;

    @Column(nullable = false)
    private String passwordHash;

    @Column(nullable = false)
    private String role; // BUYER, SELLER, MARKETING_OFFICER, ADMIN

    @Column(nullable = false)
    private String accountStatus; // PAYMENT_SUBMITTED, ACTIVE, SUSPENDED, REJECTED

    private String district;
    private String upazila;
    private String address;

    // For Marketing Officers: their unique referral code (e.g., LT-NOA-1001)
    @Column(unique = true)
    private String myReferralCode;

    // For Buyers / Sellers who registered using a Marketing Officer's referral code
    private Long referredByOfficerId;
    private String referredByCode;
    private String referredByOfficerName;

    // Registration Fee & Manual TrxID Verification info
    private BigDecimal registrationFeeAmount = BigDecimal.ZERO;
    private String paymentMethod;
    private String senderPhone;
    private String transactionId;

    // Marketing Officer Commission summary
    private BigDecimal totalEarnedCommission = BigDecimal.ZERO;
    private BigDecimal totalPaidCommission = BigDecimal.ZERO;

    // Tiered Representative Network (DISTRICT_AGENT, UPAZILA_AGENT, MARKETING_OFFICER)
    private String agentTier; // DISTRICT, UPAZILA, POURASHAVA, UNION
    private String assignedDistrict;
    private String assignedUpazila;
    private String assignedSubArea;
    private Long supervisorAgentId;
    private String supervisorAgentName;

    private String adminNote;
    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
    public String getAccountStatus() { return accountStatus; }
    public void setAccountStatus(String accountStatus) { this.accountStatus = accountStatus; }
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }
    public String getUpazila() { return upazila; }
    public void setUpazila(String upazila) { this.upazila = upazila; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public String getMyReferralCode() { return myReferralCode; }
    public void setMyReferralCode(String myReferralCode) { this.myReferralCode = myReferralCode; }
    public Long getReferredByOfficerId() { return referredByOfficerId; }
    public void setReferredByOfficerId(Long referredByOfficerId) { this.referredByOfficerId = referredByOfficerId; }
    public String getReferredByCode() { return referredByCode; }
    public void setReferredByCode(String referredByCode) { this.referredByCode = referredByCode; }
    public String getReferredByOfficerName() { return referredByOfficerName; }
    public void setReferredByOfficerName(String referredByOfficerName) { this.referredByOfficerName = referredByOfficerName; }
    public BigDecimal getRegistrationFeeAmount() { return registrationFeeAmount; }
    public void setRegistrationFeeAmount(BigDecimal registrationFeeAmount) { this.registrationFeeAmount = registrationFeeAmount; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getSenderPhone() { return senderPhone; }
    public void setSenderPhone(String senderPhone) { this.senderPhone = senderPhone; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public BigDecimal getTotalEarnedCommission() { return totalEarnedCommission; }
    public void setTotalEarnedCommission(BigDecimal totalEarnedCommission) { this.totalEarnedCommission = totalEarnedCommission; }
    public BigDecimal getTotalPaidCommission() { return totalPaidCommission; }
    public void setTotalPaidCommission(BigDecimal totalPaidCommission) { this.totalPaidCommission = totalPaidCommission; }
    public String getAgentTier() { return agentTier; }
    public void setAgentTier(String agentTier) { this.agentTier = agentTier; }
    public String getAssignedDistrict() { return assignedDistrict; }
    public void setAssignedDistrict(String assignedDistrict) { this.assignedDistrict = assignedDistrict; }
    public String getAssignedUpazila() { return assignedUpazila; }
    public void setAssignedUpazila(String assignedUpazila) { this.assignedUpazila = assignedUpazila; }
    public String getAssignedSubArea() { return assignedSubArea; }
    public void setAssignedSubArea(String assignedSubArea) { this.assignedSubArea = assignedSubArea; }
    public Long getSupervisorAgentId() { return supervisorAgentId; }
    public void setSupervisorAgentId(Long supervisorAgentId) { this.supervisorAgentId = supervisorAgentId; }
    public String getSupervisorAgentName() { return supervisorAgentName; }
    public void setSupervisorAgentName(String supervisorAgentName) { this.supervisorAgentName = supervisorAgentName; }
    public String getAdminNote() { return adminNote; }
    public void setAdminNote(String adminNote) { this.adminNote = adminNote; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
