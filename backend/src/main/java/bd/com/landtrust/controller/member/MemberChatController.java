package bd.com.landtrust.controller.member;

import bd.com.landtrust.entity.ChatConversationEntity;
import bd.com.landtrust.entity.ChatMessageEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.ChatConversationRepository;
import bd.com.landtrust.repository.ChatMessageRepository;
import bd.com.landtrust.repository.UserRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping({"/api/portal/chat", "/api/member/chat"})
public class MemberChatController {

    private final ChatConversationRepository conversationRepository;
    private final ChatMessageRepository messageRepository;
    private final UserRepository userRepository;

    public MemberChatController(
            ChatConversationRepository conversationRepository,
            ChatMessageRepository messageRepository,
            UserRepository userRepository) {
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
        this.userRepository = userRepository;
    }

    private UserEntity currentUser(Authentication auth) {
        String phone = auth.getName();
        return userRepository.findByPhoneNumber(phone)
                .orElseThrow(() -> new RuntimeException("ইউজার পাওয়া যায়নি"));
    }

    @GetMapping("/threads")
    public ResponseEntity<List<ChatConversationEntity>> getMyThreads(Authentication auth) {
        UserEntity user = currentUser(auth);
        List<ChatConversationEntity> threads = conversationRepository.findByUserIdOrderByLastMessageAtDesc(user.getId());
        return ResponseEntity.ok(threads);
    }

    @PostMapping("/threads")
    public ResponseEntity<?> startThread(Authentication auth, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        String subject = (String) body.getOrDefault("subject", "সহায়তা ও ইনকোয়ারি");
        Long listingId = body.get("listingId") != null ? Long.valueOf(body.get("listingId").toString()) : null;
        String initialMessage = (String) body.getOrDefault("initialMessage", "");

        ChatConversationEntity conv;
        if (listingId != null) {
            Optional<ChatConversationEntity> existing = conversationRepository.findByUserIdAndListingId(user.getId(), listingId);
            if (existing.isPresent()) {
                conv = existing.get();
            } else {
                conv = new ChatConversationEntity();
                conv.setUserId(user.getId());
                conv.setUserName(user.getFullName());
                conv.setUserPhone(user.getPhoneNumber());
                conv.setUserRole(user.getRole());
                conv.setSubject(subject);
                conv.setListingId(listingId);
                conv = conversationRepository.save(conv);
            }
        } else {
            conv = new ChatConversationEntity();
            conv.setUserId(user.getId());
            conv.setUserName(user.getFullName());
            conv.setUserPhone(user.getPhoneNumber());
            conv.setUserRole(user.getRole());
            conv.setSubject(subject);
            conv = conversationRepository.save(conv);
        }

        if (initialMessage != null && !initialMessage.trim().isEmpty()) {
            ChatMessageEntity msg = new ChatMessageEntity();
            msg.setConversationId(conv.getId());
            msg.setSenderId(user.getId());
            msg.setSenderRole("USER");
            msg.setSenderName(user.getFullName());
            msg.setText(initialMessage.trim());
            messageRepository.save(msg);

            conv.setLastMessage(initialMessage.trim());
            conv.setLastMessageAt(LocalDateTime.now());
            conv.setUnreadAdminCount(conv.getUnreadAdminCount() + 1);
            conv = conversationRepository.save(conv);
        }

        return ResponseEntity.ok(conv);
    }

    @GetMapping("/threads/{id}/messages")
    public ResponseEntity<?> getThreadMessages(Authentication auth, @PathVariable Long id) {
        UserEntity user = currentUser(auth);
        Optional<ChatConversationEntity> convOpt = conversationRepository.findById(id);
        if (convOpt.isEmpty()) return ResponseEntity.notFound().build();

        ChatConversationEntity conv = convOpt.get();
        if (!conv.getUserId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অননুমোদিত অ্যাক্সেস"));
        }

        if (conv.getUnreadUserCount() > 0) {
            conv.setUnreadUserCount(0);
            conversationRepository.save(conv);
        }

        List<ChatMessageEntity> msgs = messageRepository.findByConversationIdOrderByCreatedAtAsc(id);
        return ResponseEntity.ok(msgs);
    }

    @PostMapping("/threads/{id}/messages")
    public ResponseEntity<?> sendMessage(Authentication auth, @PathVariable Long id, @RequestBody Map<String, String> body) {
        UserEntity user = currentUser(auth);
        Optional<ChatConversationEntity> convOpt = conversationRepository.findById(id);
        if (convOpt.isEmpty()) return ResponseEntity.notFound().build();

        ChatConversationEntity conv = convOpt.get();
        if (!conv.getUserId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অননুমোদিত অ্যাক্সেস"));
        }

        String text = body.getOrDefault("text", "").trim();
        String attachmentUrl = body.get("attachmentUrl");
        if (text.isEmpty() && (attachmentUrl == null || attachmentUrl.isEmpty())) {
            return ResponseEntity.badRequest().body(Map.of("message", "মেসেজ খালি হতে পারে না"));
        }

        ChatMessageEntity msg = new ChatMessageEntity();
        msg.setConversationId(conv.getId());
        msg.setSenderId(user.getId());
        msg.setSenderRole("USER");
        msg.setSenderName(user.getFullName());
        msg.setText(text.isEmpty() ? "সংযুক্ত ফাইল" : text);
        msg.setAttachmentUrl(attachmentUrl);
        msg = messageRepository.save(msg);

        conv.setLastMessage(text.isEmpty() ? "[ফাইল সংযুক্ত]" : text);
        conv.setLastMessageAt(LocalDateTime.now());
        conv.setUnreadAdminCount(conv.getUnreadAdminCount() + 1);
        conversationRepository.save(conv);

        return ResponseEntity.ok(msg);
    }
}
