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

    // Dynamic Registration Fees decided by Admin (Minimum 1000 BDT policy)
    private BigDecimal buyerRegistrationFee = new BigDecimal("1000");
    private BigDecimal sellerRegistrationFee = new BigDecimal("1000");
    private BigDecimal sellerRegistrationFeePourashava = new BigDecimal("2000");
    private BigDecimal sellerRegistrationFeeUnion = new BigDecimal("1000");
    private BigDecimal officerRegistrationFee = new BigDecimal("1000");

    // Multi-Level Listing Fees per Property decided by Admin
    private BigDecimal listingFeeAgri = new BigDecimal("500");
    private BigDecimal listingFeeResidential = new BigDecimal("1000");
    private BigDecimal listingFeeFlat = new BigDecimal("1500");
    private BigDecimal listingFeeCommercial = new BigDecimal("2000");
    private BigDecimal listingFeeFeaturedExtra = new BigDecimal("1000");

    // Dual Commission Rules decided by Admin
    private BigDecimal referralVerifiedBonusFixed = new BigDecimal("100");
    private BigDecimal dealClosureFixedCommission = new BigDecimal("5000");
    private BigDecimal dealClosurePercentCommission = new BigDecimal("10");

    // Advisory Reserve Suggestion (No Lock! Only Advisory Display)
    private BigDecimal advisoryReservePercent = new BigDecimal("25");

    private String supportPhone = "01700-000000";
    private String supportWhatsapp = "01700-000000";
    private String supportEmail = "info@bhumisetu.com.bd";
    private String officeAddress = "মাইজদী কোর্ট, সদর, নোয়াখালী";
    private LocalDateTime updatedAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public BigDecimal getBuyerRegistrationFee() { return buyerRegistrationFee; }
    public void setBuyerRegistrationFee(BigDecimal buyerRegistrationFee) { this.buyerRegistrationFee = buyerRegistrationFee; }
    public BigDecimal getSellerRegistrationFee() { return sellerRegistrationFee; }
    public void setSellerRegistrationFee(BigDecimal sellerRegistrationFee) { this.sellerRegistrationFee = sellerRegistrationFee; }
    public BigDecimal getSellerRegistrationFeePourashava() { return sellerRegistrationFeePourashava; }
    public void setSellerRegistrationFeePourashava(BigDecimal sellerRegistrationFeePourashava) { this.sellerRegistrationFeePourashava = sellerRegistrationFeePourashava; }
    public BigDecimal getSellerRegistrationFeeUnion() { return sellerRegistrationFeeUnion; }
    public void setSellerRegistrationFeeUnion(BigDecimal sellerRegistrationFeeUnion) { this.sellerRegistrationFeeUnion = sellerRegistrationFeeUnion; }
    public BigDecimal getOfficerRegistrationFee() { return officerRegistrationFee; }
    public void setOfficerRegistrationFee(BigDecimal officerRegistrationFee) { this.officerRegistrationFee = officerRegistrationFee; }
    public BigDecimal getListingFeeAgri() { return listingFeeAgri; }
    public void setListingFeeAgri(BigDecimal listingFeeAgri) { this.listingFeeAgri = listingFeeAgri; }
    public BigDecimal getListingFeeResidential() { return listingFeeResidential; }
    public void setListingFeeResidential(BigDecimal listingFeeResidential) { this.listingFeeResidential = listingFeeResidential; }
    public BigDecimal getListingFeeFlat() { return listingFeeFlat; }
    public void setListingFeeFlat(BigDecimal listingFeeFlat) { this.listingFeeFlat = listingFeeFlat; }
    public BigDecimal getListingFeeCommercial() { return listingFeeCommercial; }
    public void setListingFeeCommercial(BigDecimal listingFeeCommercial) { this.listingFeeCommercial = listingFeeCommercial; }
    public BigDecimal getListingFeeFeaturedExtra() { return listingFeeFeaturedExtra; }
    public void setListingFeeFeaturedExtra(BigDecimal listingFeeFeaturedExtra) { this.listingFeeFeaturedExtra = listingFeeFeaturedExtra; }
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
    public String getSupportWhatsapp() { return supportWhatsapp; }
    public void setSupportWhatsapp(String supportWhatsapp) { this.supportWhatsapp = supportWhatsapp; }
    public String getSupportEmail() { return supportEmail; }
    public void setSupportEmail(String supportEmail) { this.supportEmail = supportEmail; }
    public String getOfficeAddress() { return officeAddress; }
    public void setOfficeAddress(String officeAddress) { this.officeAddress = officeAddress; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
