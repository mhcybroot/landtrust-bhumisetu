package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "system_settings")
public class SystemSettingEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Dynamic Registration Fees decided by Admin
    private BigDecimal buyerRegistrationFee = new BigDecimal("500");
    private BigDecimal sellerRegistrationFee = new BigDecimal("500");
    private BigDecimal officerRegistrationFee = new BigDecimal("300");

    // Dual Commission Rules decided by Admin
    private BigDecimal referralVerifiedBonusFixed = new BigDecimal("100");
    private BigDecimal dealClosureFixedCommission = new BigDecimal("5000");
    private BigDecimal dealClosurePercentCommission = new BigDecimal("10");

    // Advisory Reserve Suggestion (No Lock! Only Advisory Display)
    private BigDecimal advisoryReservePercent = new BigDecimal("25");

    private String supportPhone = "01700-000000";
    private String supportEmail = "info@bhumisetu.com.bd";
    private String officeAddress = "মাইজদী কোর্ট, সদর, নোয়াখালী";
    private LocalDateTime updatedAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public BigDecimal getBuyerRegistrationFee() { return buyerRegistrationFee; }
    public void setBuyerRegistrationFee(BigDecimal buyerRegistrationFee) { this.buyerRegistrationFee = buyerRegistrationFee; }
    public BigDecimal getSellerRegistrationFee() { return sellerRegistrationFee; }
    public void setSellerRegistrationFee(BigDecimal sellerRegistrationFee) { this.sellerRegistrationFee = sellerRegistrationFee; }
    public BigDecimal getOfficerRegistrationFee() { return officerRegistrationFee; }
    public void setOfficerRegistrationFee(BigDecimal officerRegistrationFee) { this.officerRegistrationFee = officerRegistrationFee; }
    public BigDecimal getReferralVerifiedBonusFixed() { return referralVerifiedBonusFixed; }
    public void setReferralVerifiedBonusFixed(BigDecimal referralVerifiedBonusFixed) { this.referralVerifiedBonusFixed = referralVerifiedBonusFixed; }
    public BigDecimal getDealClosureFixedCommission() { return dealClosureFixedCommission; }
    public void setDealClosureFixedCommission(BigDecimal dealClosureFixedCommission) { this.dealClosureFixedCommission = dealClosureFixedCommission; }
    public BigDecimal getDealClosurePercentCommission() { return dealClosurePercentCommission; }
    public void setDealClosurePercentCommission(BigDecimal dealClosurePercentCommission) { this.dealClosurePercentCommission = dealClosurePercentCommission; }
    public BigDecimal getAdvisoryReservePercent() { return advisoryReservePercent; }
    public void setAdvisoryReservePercent(BigDecimal advisoryReservePercent) { this.advisoryReservePercent = advisoryReservePercent; }
    public String getSupportPhone() { return supportPhone; }
    public void setSupportPhone(String supportPhone) { this.supportPhone = supportPhone; }
    public String getSupportEmail() { return supportEmail; }
    public void setSupportEmail(String supportEmail) { this.supportEmail = supportEmail; }
    public String getOfficeAddress() { return officeAddress; }
    public void setOfficeAddress(String officeAddress) { this.officeAddress = officeAddress; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
