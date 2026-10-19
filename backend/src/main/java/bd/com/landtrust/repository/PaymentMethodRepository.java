package bd.com.landtrust.repository;

import bd.com.landtrust.entity.PaymentMethodEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface PaymentMethodRepository extends JpaRepository<PaymentMethodEntity, Long> {
    List<PaymentMethodEntity> findByActiveTrue();
}
