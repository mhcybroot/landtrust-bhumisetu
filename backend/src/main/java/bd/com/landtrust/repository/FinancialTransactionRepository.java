package bd.com.landtrust.repository;

import bd.com.landtrust.entity.FinancialTransactionEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface FinancialTransactionRepository extends JpaRepository<FinancialTransactionEntity, Long> {
    List<FinancialTransactionEntity> findByUserIdOrderByCreatedAtDesc(Long userId);
    List<FinancialTransactionEntity> findAllByOrderByCreatedAtDesc();
}
