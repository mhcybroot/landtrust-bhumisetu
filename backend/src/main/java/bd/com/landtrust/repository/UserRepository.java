package bd.com.landtrust.repository;

import bd.com.landtrust.entity.UserEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
import java.util.Optional;

public interface UserRepository extends JpaRepository<UserEntity, Long> {
    Optional<UserEntity> findByPhoneNumber(String phoneNumber);
    Optional<UserEntity> findByMyReferralCodeIgnoreCase(String referralCode);
    List<UserEntity> findByReferredByOfficerIdOrderByCreatedAtDesc(Long officerId);
    List<UserEntity> findByRoleOrderByCreatedAtDesc(String role);
    List<UserEntity> findByRoleInOrderByCreatedAtDesc(List<String> roles);
    List<UserEntity> findBySupervisorAgentIdOrderByCreatedAtDesc(Long supervisorAgentId);
    Optional<UserEntity> findFirstByRoleAndDistrictAndAccountStatus(String role, String district, String accountStatus);
    Optional<UserEntity> findFirstByRoleAndDistrictAndUpazilaAndAccountStatus(String role, String district, String upazila, String accountStatus);
    List<UserEntity> findAllByOrderByCreatedAtDesc();
}
