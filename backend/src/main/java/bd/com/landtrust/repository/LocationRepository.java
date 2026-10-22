package bd.com.landtrust.repository;

import bd.com.landtrust.entity.LocationEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LocationRepository extends JpaRepository<LocationEntity, Long> {
    List<LocationEntity> findByActiveTrueOrderByDistrictNameBnAscUpazilaNameBnAsc();
    List<LocationEntity> findByDistrictNameBnAndUpazilaNameBn(String districtNameBn, String upazilaNameBn);
}
