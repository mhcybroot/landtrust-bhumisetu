package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "chat_conversations")
public class ChatConversationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private String userName;

    @Column(nullable = false)
    private String userPhone;

    private String userRole = "MEMBER";

    @Column(nullable = false)
    private String subject = "সাধারণ সহায়তা";

    private Long listingId;

    private String status = "OPEN";

    @Column(length = 1000)
    private String lastMessage;

    private LocalDateTime lastMessageAt = LocalDateTime.now();

    private int unreadAdminCount = 0;

    private int unreadUserCount = 0;

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
    public String getSubject() { return subject; }
    public void setSubject(String subject) { this.subject = subject; }
    public Long getListingId() { return listingId; }
    public void setListingId(Long listingId) { this.listingId = listingId; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getLastMessage() { return lastMessage; }
    public void setLastMessage(String lastMessage) { this.lastMessage = lastMessage; }
    public LocalDateTime getLastMessageAt() { return lastMessageAt; }
    public void setLastMessageAt(LocalDateTime lastMessageAt) { this.lastMessageAt = lastMessageAt; }
    public int getUnreadAdminCount() { return unreadAdminCount; }
    public void setUnreadAdminCount(int unreadAdminCount) { this.unreadAdminCount = unreadAdminCount; }
    public int getUnreadUserCount() { return unreadUserCount; }
    public void setUnreadUserCount(int unreadUserCount) { this.unreadUserCount = unreadUserCount; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
