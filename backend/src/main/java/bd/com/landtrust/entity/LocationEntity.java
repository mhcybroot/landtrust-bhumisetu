package bd.com.landtrust.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "locations")
public class LocationEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String districtNameBn = "নোয়াখালী";

    @Column(nullable = false)
    private String districtNameEn = "Noakhali";

    // উপজেলা বা পৌরসভার নাম (যেমন: বেগমগঞ্জ, চৌমুহনী পৌরসভা)
    @Column(nullable = false)
    private String upazilaNameBn;

    @Column(nullable = false)
    private String upazilaNameEn;

    // "UPAZILA" অথবা "POURASHAVA"
    @Column(nullable = false)
    private String areaType = "UPAZILA";

    // সংশ্লিষ্ট উপজেলার ইউনিয়নসমূহ অথবা পৌরসভার ওয়ার্ডসমূহের কমা-সেপারেটেড তালিকা
    @Column(columnDefinition = "TEXT")
    private String subAreaNames;

    // "UNION" অথবা "WARD"
    @Column(nullable = false)
    private String subAreaType = "UNION";

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
    public String getAreaType() { return areaType; }
    public void setAreaType(String areaType) { this.areaType = areaType; }
    public String getSubAreaNames() { return subAreaNames; }
    public void setSubAreaNames(String subAreaNames) { this.subAreaNames = subAreaNames; }
    public String getSubAreaType() { return subAreaType; }
    public void setSubAreaType(String subAreaType) { this.subAreaType = subAreaType; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
}
