package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "land_listings", indexes = {
    @Index(name = "idx_listing_status_district_upz", columnList = "listingStatus, district, upazila"),
    @Index(name = "idx_listing_seller", columnList = "sellerId"),
    @Index(name = "idx_listing_khatian", columnList = "upazila, khatianNo"),
    @Index(name = "idx_listing_dag", columnList = "upazila, dagNo")
})
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
    private String upazila; // উপজেলা অথবা পৌরসভার নাম

    private String subArea; // ইউনিয়ন অথবা ওয়ার্ডের নাম (যেমন: রাজগঞ্জ / ৪ নং ওয়ার্ড)

    @Column(nullable = false)
    private String areaName; // পাড়া / গ্রাম / রোড

    private String mouzaName;
    private String khatianNo;
    private String dagNo;
    private String mutationInfo;

    @Column(nullable = false)
    private String landType; // আবাসিক জমি, ফ্ল্যাট / অ্যাপার্টমেন্ট, বাণিজ্যিক সম্পত্তি, কৃষি জমি, বাগান বাড়ি

    @Column(nullable = false)
    private BigDecimal areaDecimal; // শতাংশ / স্কয়ার ফিট

    @Column(nullable = false)
    private BigDecimal expectedPriceBdt;

    private BigDecimal pricePerDecimalBdt;
    private String roadAccessInfo;

    @Column(length = 2000)
    private String description;

    @Column(columnDefinition = "TEXT")
    private String imageUrl;

    @Column(columnDefinition = "TEXT")
    private String additionalImageUrls;

    @Column(length = 1000)
    private String videoUrl;

    @Column(length = 1000)
    private String mapLink;

    @Column(columnDefinition = "TEXT")
    private String privateDocumentUrl;

    private String privateDocumentName;

    private boolean duplicateSuspected = false;

    @Column(length = 1000)
    private String duplicateNote;

    private BigDecimal proposedServiceFeeBdt = BigDecimal.ZERO;

    // Multi-level listing fee tracking
    private String propertyRegCode; // e.g. PROP-NOA-1001
    private Long referredOfficerId;
    private String referredOfficerName;
    private boolean listingCommissionAwarded = false;
    private BigDecimal listingFeeChargedBdt = BigDecimal.ZERO;
    private String paymentMethod;
    private String senderPhone;
    private String transactionId;
    private String paymentStatus = "PENDING"; // PENDING, APPROVED, REJECTED, WAIVED
    private boolean isFeatured = false;

    // Verification Badge: SUBMITTED, DOC_CHECKED, FIELD_VERIFIED
    @Column(nullable = false)
    private String verificationStatus = "SUBMITTED";

    // Listing Status: SUBMITTED, UNDER_REVIEW, APPROVED_PUBLISHED, RESERVED, SOLD, SUSPENDED, REJECTED
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
    public String getSubArea() { return subArea; }
    public void setSubArea(String subArea) { this.subArea = subArea; }
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
    public String getAdditionalImageUrls() { return additionalImageUrls; }
    public void setAdditionalImageUrls(String additionalImageUrls) { this.additionalImageUrls = additionalImageUrls; }
    public String getVideoUrl() { return videoUrl; }
    public void setVideoUrl(String videoUrl) { this.videoUrl = videoUrl; }
    public String getMapLink() { return mapLink; }
    public void setMapLink(String mapLink) { this.mapLink = mapLink; }
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
    public BigDecimal getListingFeeChargedBdt() { return listingFeeChargedBdt; }
    public void setListingFeeChargedBdt(BigDecimal listingFeeChargedBdt) { this.listingFeeChargedBdt = listingFeeChargedBdt; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getSenderPhone() { return senderPhone; }
    public void setSenderPhone(String senderPhone) { this.senderPhone = senderPhone; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public String getPaymentStatus() { return paymentStatus; }
    public void setPaymentStatus(String paymentStatus) { this.paymentStatus = paymentStatus; }
    @com.fasterxml.jackson.annotation.JsonProperty("isFeatured")
    public boolean isFeatured() { return isFeatured; }
    public void setFeatured(boolean featured) { isFeatured = featured; }
    public String getVerificationStatus() { return verificationStatus; }
    public void setVerificationStatus(String verificationStatus) { this.verificationStatus = verificationStatus; }
    public String getListingStatus() { return listingStatus; }
    public void setListingStatus(String listingStatus) { this.listingStatus = listingStatus; }
    public String getPropertyRegCode() { return propertyRegCode; }
    public void setPropertyRegCode(String propertyRegCode) { this.propertyRegCode = propertyRegCode; }
    public Long getReferredOfficerId() { return referredOfficerId; }
    public void setReferredOfficerId(Long referredOfficerId) { this.referredOfficerId = referredOfficerId; }
    public String getReferredOfficerName() { return referredOfficerName; }
    public void setReferredOfficerName(String referredOfficerName) { this.referredOfficerName = referredOfficerName; }
    public boolean isListingCommissionAwarded() { return listingCommissionAwarded; }
    public void setListingCommissionAwarded(boolean listingCommissionAwarded) { this.listingCommissionAwarded = listingCommissionAwarded; }
    public String getAdminRemark() { return adminRemark; }
    public void setAdminRemark(String adminRemark) { this.adminRemark = adminRemark; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
