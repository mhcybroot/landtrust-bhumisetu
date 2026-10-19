package bd.com.landtrust.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "payment_methods")
public class PaymentMethodEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String providerName; // e.g., বিকাশ (bKash), নগদ (Nagad), রকেট (Rocket), ব্যাংক হিসাব

    @Column(nullable = false)
    private String accountNumber; // e.g., 01711-XXXXXX

    @Column(nullable = false)
    private String accountType; // Personal (সেন্ড মানি), Merchant (পেমেন্ট), Bank Account

    @Column(length = 500)
    private String instructions;

    private boolean active = true;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getProviderName() { return providerName; }
    public void setProviderName(String providerName) { this.providerName = providerName; }
    public String getAccountNumber() { return accountNumber; }
    public void setAccountNumber(String accountNumber) { this.accountNumber = accountNumber; }
    public String getAccountType() { return accountType; }
    public void setAccountType(String accountType) { this.accountType = accountType; }
    public String getInstructions() { return instructions; }
    public void setInstructions(String instructions) { this.instructions = instructions; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
