package bd.com.landtrust.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications", indexes = {
    @Index(name = "idx_notif_user_created", columnList = "user_id, created_at"),
    @Index(name = "idx_notif_user_read", columnList = "user_id, read_status")
})
public class NotificationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private Long userId;

    @Column(nullable = false)
    private String title;

    @Column(length = 1000, nullable = false)
    private String message;

    private boolean readStatus = false;

    private LocalDateTime createdAt = LocalDateTime.now();

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public boolean isReadStatus() { return readStatus; }
    public void setReadStatus(boolean readStatus) { this.readStatus = readStatus; }
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
