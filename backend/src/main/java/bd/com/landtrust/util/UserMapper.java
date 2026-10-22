package bd.com.landtrust.util;

import bd.com.landtrust.entity.UserEntity;
import java.util.LinkedHashMap;
import java.util.Map;

public class UserMapper {

    private UserMapper() {}

    public static Map<String, Object> sanitizeUser(UserEntity u) {
        if (u == null) return Map.of();
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("id", u.getId());
        m.put("fullName", u.getFullName());
        m.put("phoneNumber", u.getPhoneNumber());
        m.put("role", u.getRole());
        m.put("accountStatus", u.getAccountStatus());
        m.put("district", u.getDistrict());
        m.put("upazila", u.getUpazila());
        m.put("address", u.getAddress());
        m.put("myReferralCode", u.getMyReferralCode());
        m.put("referredByOfficerId", u.getReferredByOfficerId());
        m.put("referredByCode", u.getReferredByCode());
        m.put("referredByOfficerName", u.getReferredByOfficerName());
        m.put("registrationFeeAmount", u.getRegistrationFeeAmount());
        m.put("paymentMethod", u.getPaymentMethod());
        m.put("senderPhone", u.getSenderPhone());
        m.put("transactionId", u.getTransactionId());
        m.put("totalEarnedCommission", u.getTotalEarnedCommission());
        m.put("totalPaidCommission", u.getTotalPaidCommission());
        m.put("agentTier", u.getAgentTier());
        m.put("assignedDistrict", u.getAssignedDistrict());
        m.put("assignedUpazila", u.getAssignedUpazila());
        m.put("assignedSubArea", u.getAssignedSubArea());
        m.put("supervisorAgentId", u.getSupervisorAgentId());
        m.put("supervisorAgentName", u.getSupervisorAgentName());
        m.put("adminNote", u.getAdminNote());
        m.put("createdAt", u.getCreatedAt());
        return m;
    }
}
