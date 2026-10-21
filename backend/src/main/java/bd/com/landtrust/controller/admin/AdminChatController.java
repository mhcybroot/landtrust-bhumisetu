package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.ChatConversationEntity;
import bd.com.landtrust.entity.ChatMessageEntity;
import bd.com.landtrust.repository.ChatConversationRepository;
import bd.com.landtrust.repository.ChatMessageRepository;
import bd.com.landtrust.repository.NotificationRepository;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin/chat")
public class AdminChatController {

    private final ChatConversationRepository conversationRepository;
    private final ChatMessageRepository messageRepository;
    private final NotificationRepository notificationRepository;

    public AdminChatController(
            ChatConversationRepository conversationRepository,
            ChatMessageRepository messageRepository,
            NotificationRepository notificationRepository) {
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.notificationRepository = notificationRepository;
    }

    @GetMapping("/threads")
    public ResponseEntity<List<ChatConversationEntity>> getAllThreads() {
        List<ChatConversationEntity> threads = conversationRepository.findAllByOrderByLastMessageAtDesc();
        return ResponseEntity.ok(threads);
    }

    @GetMapping("/threads/{id}/messages")
    public ResponseEntity<?> getThreadMessages(@PathVariable Long id) {
        Optional<ChatConversationEntity> convOpt = conversationRepository.findById(id);
        if (convOpt.isEmpty()) return ResponseEntity.notFound().build();

        ChatConversationEntity conv = convOpt.get();
        if (conv.getUnreadAdminCount() > 0) {
            conv.setUnreadAdminCount(0);
            conversationRepository.save(conv);
        }

        List<ChatMessageEntity> msgs = messageRepository.findByConversationIdOrderByCreatedAtAsc(id);
        return ResponseEntity.ok(msgs);
    }

    @PostMapping("/threads/{id}/reply")
    public ResponseEntity<?> replyMessage(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<ChatConversationEntity> convOpt = conversationRepository.findById(id);
        if (convOpt.isEmpty()) return ResponseEntity.notFound().build();

        ChatConversationEntity conv = convOpt.get();
        String text = body.getOrDefault("text", "").trim();
        String attachmentUrl = body.get("attachmentUrl");
        if (text.isEmpty() && (attachmentUrl == null || attachmentUrl.isEmpty())) {
            return ResponseEntity.badRequest().body(Map.of("message", "মেসেজ খালি হতে পারে না"));
        }

        ChatMessageEntity msg = new ChatMessageEntity();
        msg.setConversationId(conv.getId());
        msg.setSenderId(0L); // 0 = Admin
        msg.setSenderRole("ADMIN");
        msg.setSenderName("LandApp এডমিন");
        msg.setText(text.isEmpty() ? "সংযুক্ত ফাইল" : text);
        msg.setAttachmentUrl(attachmentUrl);
        msg = messageRepository.save(msg);

        conv.setLastMessage(text.isEmpty() ? "[ফাইল সংযুক্ত]" : text);
        conv.setLastMessageAt(LocalDateTime.now());
        conv.setUnreadUserCount(conv.getUnreadUserCount() + 1);
        conversationRepository.save(conv);

        // ব্যবহারকারীকে ইন-অ্যাপ নোটিফিকেশন অ্যালার্ট পাঠানো
        CommonUtils.notifyUser(notificationRepository, conv.getUserId(),
                "নতুন সাপোর্ট মেসেজ: " + conv.getSubject(),
                text.length() > 60 ? text.substring(0, 57) + "..." : text);

        return ResponseEntity.ok(msg);
    }

    @PutMapping("/threads/{id}/status")
    public ResponseEntity<?> updateThreadStatus(@PathVariable Long id, @RequestBody Map<String, String> body) {
        Optional<ChatConversationEntity> convOpt = conversationRepository.findById(id);
        if (convOpt.isEmpty()) return ResponseEntity.notFound().build();

        ChatConversationEntity conv = convOpt.get();
        String newStatus = body.getOrDefault("status", "RESOLVED").toUpperCase();
        conv.setStatus(newStatus);
        conversationRepository.save(conv);

        return ResponseEntity.ok(Map.of("message", "স্ট্যাটাস সফলভাবে আপডেট করা হয়েছে"));
    }
}
