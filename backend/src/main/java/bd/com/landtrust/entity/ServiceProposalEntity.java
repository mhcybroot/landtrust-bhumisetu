package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "service_proposals")
public class ServiceProposalEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private String userName;

    @Column(nullable = false)
    private String userPhone;

    @Column(nullable = false)
    private String userRole; // BUYER or SELLER

    @Column(nullable = false)
    private String proposalTitle;

    @Column(length = 1500)
    private String scopeDescription;

    @Column(nullable = false)
    private BigDecimal customerProposedFeeBdt;

    private BigDecimal adminCounterFeeBdt;
    private BigDecimal finalAgreedFeeBdt;

    private String timelineTerms;
    private String paymentTerms;

    // Status: CUSTOMER_PROPOSED, ADMIN_COUNTER_OFFER, MUTUALLY_AGREED, COMPLETED, SUSPENDED, REJECTED
    @Column(nullable = false)
    private String status = "CUSTOMER_PROPOSED";

    private String adminNote;
    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getUserPhone() { return userPhone; }
    public void setUserPhone(String userPhone) { this.userPhone = userPhone; }
    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }
    public String getProposalTitle() { return proposalTitle; }
    public void setProposalTitle(String proposalTitle) { this.proposalTitle = proposalTitle; }
    public String getScopeDescription() { return scopeDescription; }
    public void setScopeDescription(String scopeDescription) { this.scopeDescription = scopeDescription; }
    public BigDecimal getCustomerProposedFeeBdt() { return customerProposedFeeBdt; }
    public void setCustomerProposedFeeBdt(BigDecimal customerProposedFeeBdt) { this.customerProposedFeeBdt = customerProposedFeeBdt; }
    public BigDecimal getAdminCounterFeeBdt() { return adminCounterFeeBdt; }
    public void setAdminCounterFeeBdt(BigDecimal adminCounterFeeBdt) { this.adminCounterFeeBdt = adminCounterFeeBdt; }
    public BigDecimal getFinalAgreedFeeBdt() { return finalAgreedFeeBdt; }
    public void setFinalAgreedFeeBdt(BigDecimal finalAgreedFeeBdt) { this.finalAgreedFeeBdt = finalAgreedFeeBdt; }
    public String getTimelineTerms() { return timelineTerms; }
    public void setTimelineTerms(String timelineTerms) { this.timelineTerms = timelineTerms; }
    public String getPaymentTerms() { return paymentTerms; }
    public void setPaymentTerms(String paymentTerms) { this.paymentTerms = paymentTerms; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getAdminNote() { return adminNote; }
    public void setAdminNote(String adminNote) { this.adminNote = adminNote; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
