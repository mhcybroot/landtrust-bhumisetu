package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "land_listings")
public class LandListingEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long sellerId;

    @Column(nullable = false)
    private String sellerName;

    @Column(nullable = false)
    private String sellerPhone; // Kept private in public API responses!

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String district;

    @Column(nullable = false)
    private String upazila;

    @Column(nullable = false)
    private String areaName;

    private String mouzaName;
    private String khatianNo; // Private document info
    private String dagNo;     // Private document info
    private String mutationInfo; // Private document info

    @Column(nullable = false)
    private String landType; // আবাসিক, বাণিজ্যিক, কৃষি, বাগান/খামার

    @Column(nullable = false)
    private BigDecimal areaDecimal; // শতাংশ

    @Column(nullable = false)
    private BigDecimal expectedPriceBdt;

    private BigDecimal pricePerDecimalBdt;
    private String roadAccessInfo;

    @Column(length = 2000)
    private String description;

    @Column(columnDefinition = "TEXT")
    private String imageUrl;

    @Column(columnDefinition = "TEXT")
    private String privateDocumentUrl; // Only visible to Admin & Seller (never exposed publicly)

    private String privateDocumentName;

    private boolean duplicateSuspected = false;

    @Column(length = 1000)
    private String duplicateNote;

    // Proposed fixed service fee offered by seller to Bhumi Setu
    private BigDecimal proposedServiceFeeBdt = BigDecimal.ZERO;

    // Verification Badge: SUBMITTED, DOC_CHECKED, FIELD_VERIFIED
    @Column(nullable = false)
    private String verificationStatus = "SUBMITTED";

    // Listing Status: SUBMITTED, UNDER_REVIEW, APPROVED_PUBLISHED, RESERVED, SOLD, SUSPENDED, REJECTED
    // Admin can set SUSPENDED or REJECTED at any stage!
    @Column(nullable = false)
    private String listingStatus = "SUBMITTED";

    private String adminRemark;
    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getSellerId() { return sellerId; }
    public void setSellerId(Long sellerId) { this.sellerId = sellerId; }
    public String getSellerName() { return sellerName; }
    public void setSellerName(String sellerName) { this.sellerName = sellerName; }
    public String getSellerPhone() { return sellerPhone; }
    public void setSellerPhone(String sellerPhone) { this.sellerPhone = sellerPhone; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }
    public String getUpazila() { return upazila; }
    public void setUpazila(String upazila) { this.upazila = upazila; }
    public String getAreaName() { return areaName; }
    public void setAreaName(String areaName) { this.areaName = areaName; }
    public String getMouzaName() { return mouzaName; }
    public void setMouzaName(String mouzaName) { this.mouzaName = mouzaName; }
    public String getKhatianNo() { return khatianNo; }
    public void setKhatianNo(String khatianNo) { this.khatianNo = khatianNo; }
    public String getDagNo() { return dagNo; }
    public void setDagNo(String dagNo) { this.dagNo = dagNo; }
    public String getMutationInfo() { return mutationInfo; }
    public void setMutationInfo(String mutationInfo) { this.mutationInfo = mutationInfo; }
    public String getLandType() { return landType; }
    public void setLandType(String landType) { this.landType = landType; }
    public BigDecimal getAreaDecimal() { return areaDecimal; }
    public void setAreaDecimal(BigDecimal areaDecimal) { this.areaDecimal = areaDecimal; }
    public BigDecimal getExpectedPriceBdt() { return expectedPriceBdt; }
    public void setExpectedPriceBdt(BigDecimal expectedPriceBdt) { this.expectedPriceBdt = expectedPriceBdt; }
    public BigDecimal getPricePerDecimalBdt() { return pricePerDecimalBdt; }
    public void setPricePerDecimalBdt(BigDecimal pricePerDecimalBdt) { this.pricePerDecimalBdt = pricePerDecimalBdt; }
    public String getRoadAccessInfo() { return roadAccessInfo; }
    public void setRoadAccessInfo(String roadAccessInfo) { this.roadAccessInfo = roadAccessInfo; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    public String getPrivateDocumentUrl() { return privateDocumentUrl; }
    public void setPrivateDocumentUrl(String privateDocumentUrl) { this.privateDocumentUrl = privateDocumentUrl; }
    public String getPrivateDocumentName() { return privateDocumentName; }
    public void setPrivateDocumentName(String privateDocumentName) { this.privateDocumentName = privateDocumentName; }
    public boolean isDuplicateSuspected() { return duplicateSuspected; }
    public void setDuplicateSuspected(boolean duplicateSuspected) { this.duplicateSuspected = duplicateSuspected; }
    public String getDuplicateNote() { return duplicateNote; }
    public void setDuplicateNote(String duplicateNote) { this.duplicateNote = duplicateNote; }
    public BigDecimal getProposedServiceFeeBdt() { return proposedServiceFeeBdt; }
    public void setProposedServiceFeeBdt(BigDecimal proposedServiceFeeBdt) { this.proposedServiceFeeBdt = proposedServiceFeeBdt; }
    public String getVerificationStatus() { return verificationStatus; }
    public void setVerificationStatus(String verificationStatus) { this.verificationStatus = verificationStatus; }
    public String getListingStatus() { return listingStatus; }
    public void setListingStatus(String listingStatus) { this.listingStatus = listingStatus; }
    public String getAdminRemark() { return adminRemark; }
    public void setAdminRemark(String adminRemark) { this.adminRemark = adminRemark; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
