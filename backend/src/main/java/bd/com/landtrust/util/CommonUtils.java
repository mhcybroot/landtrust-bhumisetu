package bd.com.landtrust.util;

import bd.com.landtrust.entity.NotificationEntity;
import bd.com.landtrust.repository.NotificationRepository;

import java.math.BigDecimal;

public class CommonUtils {

    private CommonUtils() {}

    public static BigDecimal parseDecimal(Object val, BigDecimal fallback) {
        if (val == null) return fallback;
        try {
            return new BigDecimal(String.valueOf(val).trim());
        } catch (Exception e) {
            return fallback;
        }
    }

    public static void notifyUser(NotificationRepository repo, Long userId, String title, String message) {
        if (repo == null || userId == null) return;
        NotificationEntity n = new NotificationEntity();
        n.setUserId(userId);
        n.setTitle(title);
        n.setMessage(message);
        repo.save(n);
    }
}
