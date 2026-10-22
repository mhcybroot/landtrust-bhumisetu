package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "buyer_requirements", indexes = {
    @Index(name = "idx_req_status_dist_upz", columnList = "status, preferredDistrict, preferredUpazila"),
    @Index(name = "idx_req_buyer", columnList = "buyerId")
})
public class BuyerRequirementEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long buyerId;

    @Column(nullable = false)
    private String buyerName;

    @Column(nullable = false)
    private String buyerPhone;

    @Column(nullable = false)
    private String preferredDistrict;

    @Column(nullable = false)
    private String preferredUpazila;

    private String preferredArea;

    @Column(nullable = false)
    private String landType; // আবাসিক, বাণিজ্যিক, কৃষি, বাগান/খামার

    private BigDecimal minAreaDecimal;
    private BigDecimal maxAreaDecimal;

    @Column(nullable = false)
    private BigDecimal minBudgetBdt;

    @Column(nullable = false)
    private BigDecimal maxBudgetBdt;

    private String purpose;
    private String purchaseTimeline; // জরুরি (১ মাসের মধ্যে), ১-৩ মাস, ৩-৬ মাস, আলোচনা সাপেক্ষে

    private BigDecimal proposedServiceFeeBdt = BigDecimal.ZERO;

    @Column(length = 1500)
    private String specialRequirements;

    // Status: SUBMITTED, ACTIVE, MATCHED, FULFILLED, SUSPENDED, REJECTED
    @Column(nullable = false)
    private String status = "SUBMITTED";

    private String adminRemark;
    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getBuyerId() { return buyerId; }
    public void setBuyerId(Long buyerId) { this.buyerId = buyerId; }
    public String getBuyerName() { return buyerName; }
    public void setBuyerName(String buyerName) { this.buyerName = buyerName; }
    public String getBuyerPhone() { return buyerPhone; }
    public void setBuyerPhone(String buyerPhone) { this.buyerPhone = buyerPhone; }
    public String getPreferredDistrict() { return preferredDistrict; }
    public void setPreferredDistrict(String preferredDistrict) { this.preferredDistrict = preferredDistrict; }
    public String getPreferredUpazila() { return preferredUpazila; }
    public void setPreferredUpazila(String preferredUpazila) { this.preferredUpazila = preferredUpazila; }
    public String getPreferredArea() { return preferredArea; }
    public void setPreferredArea(String preferredArea) { this.preferredArea = preferredArea; }
    public String getLandType() { return landType; }
    public void setLandType(String landType) { this.landType = landType; }
    public BigDecimal getMinAreaDecimal() { return minAreaDecimal; }
    public void setMinAreaDecimal(BigDecimal minAreaDecimal) { this.minAreaDecimal = minAreaDecimal; }
    public BigDecimal getMaxAreaDecimal() { return maxAreaDecimal; }
    public void setMaxAreaDecimal(BigDecimal maxAreaDecimal) { this.maxAreaDecimal = maxAreaDecimal; }
    public BigDecimal getMinBudgetBdt() { return minBudgetBdt; }
    public void setMinBudgetBdt(BigDecimal minBudgetBdt) { this.minBudgetBdt = minBudgetBdt; }
    public BigDecimal getMaxBudgetBdt() { return maxBudgetBdt; }
    public void setMaxBudgetBdt(BigDecimal maxBudgetBdt) { this.maxBudgetBdt = maxBudgetBdt; }
    public String getPurpose() { return purpose; }
    public void setPurpose(String purpose) { this.purpose = purpose; }
    public String getPurchaseTimeline() { return purchaseTimeline; }
    public void setPurchaseTimeline(String purchaseTimeline) { this.purchaseTimeline = purchaseTimeline; }
    public BigDecimal getProposedServiceFeeBdt() { return proposedServiceFeeBdt; }
    public void setProposedServiceFeeBdt(BigDecimal proposedServiceFeeBdt) { this.proposedServiceFeeBdt = proposedServiceFeeBdt; }
    public String getSpecialRequirements() { return specialRequirements; }
    public void setSpecialRequirements(String specialRequirements) { this.specialRequirements = specialRequirements; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminRemark() { return adminRemark; }
    public void setAdminRemark(String adminRemark) { this.adminRemark = adminRemark; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
