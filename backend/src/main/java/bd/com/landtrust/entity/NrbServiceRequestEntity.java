package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "nrb_service_requests")
public class NrbServiceRequestEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;

    @Column(nullable = false)
    private String applicantName;

    private String passportNumber;

    @Column(nullable = false)
    private String countryOfResidence;

    @Column(nullable = false)
    private String overseasPhone;

    private String whatsappNumber;

    @Column(nullable = false)
    private String district;

    @Column(nullable = false)
    private String upazila;

    private String mouza;
    private String khatianNo;
    private String dagNo;

    private BigDecimal landAreaDecimal;
    private BigDecimal askingPriceBdt;

    // Service Type: INSTITUTIONAL_REPRESENTATION, POWER_OF_ATTORNEY
    @Column(nullable = false)
    private String serviceType;

    // POA Status: SUBMITTED, UNDER_LEGAL_REVIEW, EMBASSY_DRAFT_READY, ATTESTED, REGISTERED, COMPLETED, REJECTED
    @Column(nullable = false)
    private String poaStatus = "SUBMITTED";

    private Long assignedAgentId;
    private String assignedAgentName;

    @Column(columnDefinition = "TEXT")
    private String adminNotes;

    @Column(columnDefinition = "TEXT")
    private String documentUrls;

    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime updatedAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getApplicantName() { return applicantName; }
    public void setApplicantName(String applicantName) { this.applicantName = applicantName; }
    public String getPassportNumber() { return passportNumber; }
    public void setPassportNumber(String passportNumber) { this.passportNumber = passportNumber; }
    public String getCountryOfResidence() { return countryOfResidence; }
    public void setCountryOfResidence(String countryOfResidence) { this.countryOfResidence = countryOfResidence; }
    public String getOverseasPhone() { return overseasPhone; }
    public void setOverseasPhone(String overseasPhone) { this.overseasPhone = overseasPhone; }
    public String getWhatsappNumber() { return whatsappNumber; }
    public void setWhatsappNumber(String whatsappNumber) { this.whatsappNumber = whatsappNumber; }
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }
    public String getUpazila() { return upazila; }
    public void setUpazila(String upazila) { this.upazila = upazila; }
    public String getMouza() { return mouza; }
    public void setMouza(String mouza) { this.mouza = mouza; }
    public String getKhatianNo() { return khatianNo; }
    public void setKhatianNo(String khatianNo) { this.khatianNo = khatianNo; }
    public String getDagNo() { return dagNo; }
    public void setDagNo(String dagNo) { this.dagNo = dagNo; }
    public BigDecimal getLandAreaDecimal() { return landAreaDecimal; }
    public void setLandAreaDecimal(BigDecimal landAreaDecimal) { this.landAreaDecimal = landAreaDecimal; }
    public BigDecimal getAskingPriceBdt() { return askingPriceBdt; }
    public void setAskingPriceBdt(BigDecimal askingPriceBdt) { this.askingPriceBdt = askingPriceBdt; }
    public String getServiceType() { return serviceType; }
    public void setServiceType(String serviceType) { this.serviceType = serviceType; }
    public String getPoaStatus() { return poaStatus; }
    public void setPoaStatus(String poaStatus) { this.poaStatus = poaStatus; }
    public Long getAssignedAgentId() { return assignedAgentId; }
    public void setAssignedAgentId(Long assignedAgentId) { this.assignedAgentId = assignedAgentId; }
    public String getAssignedAgentName() { return assignedAgentName; }
    public void setAssignedAgentName(String assignedAgentName) { this.assignedAgentName = assignedAgentName; }
    public String getAdminNotes() { return adminNotes; }
    public void setAdminNotes(String adminNotes) { this.adminNotes = adminNotes; }
    public String getDocumentUrls() { return documentUrls; }
    public void setDocumentUrls(String documentUrls) { this.documentUrls = documentUrls; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}
