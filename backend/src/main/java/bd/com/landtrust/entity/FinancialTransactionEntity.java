package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "financial_transactions", indexes = {
    @Index(name = "idx_txn_bucket_type_status", columnList = "fundBucket, txnType, status"),
    @Index(name = "idx_txn_user", columnList = "userId"),
    @Index(name = "idx_txn_id", columnList = "transactionId")
})
public class FinancialTransactionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;
    private String userName;
    private String userRole;

    // Fund Buckets: REG_FEE_FUND, SERVICE_REVENUE, OFFICER_COMMISSION, OPERATIONAL_EXPENSE
    @Column(nullable = false)
    private String fundBucket;

    // CREDIT (Income/Collection), DEBIT (Expense/Payout), REFUND
    @Column(nullable = false)
    private String txnType;

    @Column(nullable = false)
    private BigDecimal amountBdt;

    private String paymentMethod; // bKash, Nagad, Bank, Cash
    private String senderPhone;
    private String transactionId; // Manual TrxID submitted by user or admin

    @Column(length = 500)
    private String description;

    // Status: PENDING_VERIFICATION, APPROVED, REJECTED, REFUNDED
    @Column(nullable = false)
    private String status = "PENDING_VERIFICATION";

    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    public String getUserRole() { return userRole; }
    public void setUserRole(String userRole) { this.userRole = userRole; }
    public String getFundBucket() { return fundBucket; }
    public void setFundBucket(String fundBucket) { this.fundBucket = fundBucket; }
    public String getTxnType() { return txnType; }
    public void setTxnType(String txnType) { this.txnType = txnType; }
    public BigDecimal getAmountBdt() { return amountBdt; }
    public void setAmountBdt(BigDecimal amountBdt) { this.amountBdt = amountBdt; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getSenderPhone() { return senderPhone; }
    public void setSenderPhone(String senderPhone) { this.senderPhone = senderPhone; }
    public String getTransactionId() { return transactionId; }
    public void setTransactionId(String transactionId) { this.transactionId = transactionId; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
