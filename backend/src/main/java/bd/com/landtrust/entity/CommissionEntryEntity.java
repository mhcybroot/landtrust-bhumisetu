package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "commission_entries")
public class CommissionEntryEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long officerId;

    @Column(nullable = false)
    private String officerName;

    @Column(nullable = false)
    private String referralCode;

    @Column(nullable = false)
    private Long referredUserId;

    @Column(nullable = false)
    private String referredUserName;

    @Column(nullable = false)
    private String referredUserRole; // BUYER or SELLER

    // Commission Type: REFERRAL_VERIFIED_FIXED, DEAL_CLOSURE_FIXED, DEAL_CLOSURE_PERCENT
    @Column(nullable = false)
    private String commissionType;

    private BigDecimal baseDealAmountBdt = BigDecimal.ZERO;
    private BigDecimal percentageRate = BigDecimal.ZERO;

    @Column(nullable = false)
    private BigDecimal commissionAmountBdt;

    // Status: APPROVED_PAYABLE, PAID, CANCELLED
    @Column(nullable = false)
    private String status = "APPROVED_PAYABLE";

    private String paymentReference;
    private String note;
    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime paidAt;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getOfficerId() { return officerId; }
    public void setOfficerId(Long officerId) { this.officerId = officerId; }
    public String getOfficerName() { return officerName; }
    public void setOfficerName(String officerName) { this.officerName = officerName; }
    public String getReferralCode() { return referralCode; }
    public void setReferralCode(String referralCode) { this.referralCode = referralCode; }
    public Long getReferredUserId() { return referredUserId; }
    public void setReferredUserId(Long referredUserId) { this.referredUserId = referredUserId; }
    public String getReferredUserName() { return referredUserName; }
    public void setReferredUserName(String referredUserName) { this.referredUserName = referredUserName; }
    public String getReferredUserRole() { return referredUserRole; }
    public void setReferredUserRole(String referredUserRole) { this.referredUserRole = referredUserRole; }
    public String getCommissionType() { return commissionType; }
    public void setCommissionType(String commissionType) { this.commissionType = commissionType; }
    public BigDecimal getBaseDealAmountBdt() { return baseDealAmountBdt; }
    public void setBaseDealAmountBdt(BigDecimal baseDealAmountBdt) { this.baseDealAmountBdt = baseDealAmountBdt; }
    public BigDecimal getPercentageRate() { return percentageRate; }
    public void setPercentageRate(BigDecimal percentageRate) { this.percentageRate = percentageRate; }
    public BigDecimal getCommissionAmountBdt() { return commissionAmountBdt; }
    public void setCommissionAmountBdt(BigDecimal commissionAmountBdt) { this.commissionAmountBdt = commissionAmountBdt; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getPaymentReference() { return paymentReference; }
    public void setPaymentReference(String paymentReference) { this.paymentReference = paymentReference; }
    public String getNote() { return note; }
    public void setNote(String note) { this.note = note; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getPaidAt() { return paidAt; }
    public void setPaidAt(LocalDateTime paidAt) { this.paidAt = paidAt; }
}
