package bd.com.landtrust.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "locations")
public class LocationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String districtNameBn;

    @Column(nullable = false)
    private String districtNameEn;

    @Column(nullable = false)
    private String upazilaNameBn;

    @Column(nullable = false)
    private String upazilaNameEn;

    private boolean active = true;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getDistrictNameBn() { return districtNameBn; }
    public void setDistrictNameBn(String districtNameBn) { this.districtNameBn = districtNameBn; }
    public String getDistrictNameEn() { return districtNameEn; }
    public void setDistrictNameEn(String districtNameEn) { this.districtNameEn = districtNameEn; }
    public String getUpazilaNameBn() { return upazilaNameBn; }
    public void setUpazilaNameBn(String upazilaNameBn) { this.upazilaNameBn = upazilaNameBn; }
    public String getUpazilaNameEn() { return upazilaNameEn; }
    public void setUpazilaNameEn(String upazilaNameEn) { this.upazilaNameEn = upazilaNameEn; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
