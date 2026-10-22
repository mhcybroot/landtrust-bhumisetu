package bd.com.landtrust.controller.admin;

import bd.com.landtrust.entity.LocationEntity;
import bd.com.landtrust.entity.PaymentMethodEntity;
import bd.com.landtrust.entity.SystemSettingEntity;
import bd.com.landtrust.repository.LocationRepository;
import bd.com.landtrust.repository.PaymentMethodRepository;
import bd.com.landtrust.repository.SystemSettingRepository;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/admin")
public class AdminSettingsController {

    private final SystemSettingRepository settingRepository;
    private final PaymentMethodRepository paymentMethodRepository;
    private final LocationRepository locationRepository;

    public AdminSettingsController(
            SystemSettingRepository settingRepository,
            PaymentMethodRepository paymentMethodRepository,
            LocationRepository locationRepository) {
        this.settingRepository = settingRepository;
        this.paymentMethodRepository = paymentMethodRepository;
        this.locationRepository = locationRepository;
    }

    private SystemSettingEntity getSettings() {
        return settingRepository.findAll().stream().findFirst().orElseGet(() -> {
            SystemSettingEntity def = new SystemSettingEntity();
            return settingRepository.save(def);
        });
    }

    @PutMapping("/settings")
    public ResponseEntity<SystemSettingEntity> updateSettings(@RequestBody Map<String, Object> body) {
        SystemSettingEntity s = getSettings();
        if (body.containsKey("buyerRegistrationFee")) s.setBuyerRegistrationFee(CommonUtils.parseDecimal(body.get("buyerRegistrationFee"), s.getBuyerRegistrationFee()));
        if (body.containsKey("sellerRegistrationFee")) s.setSellerRegistrationFee(CommonUtils.parseDecimal(body.get("sellerRegistrationFee"), s.getSellerRegistrationFee()));
        if (body.containsKey("officerRegistrationFee")) s.setOfficerRegistrationFee(CommonUtils.parseDecimal(body.get("officerRegistrationFee"), s.getOfficerRegistrationFee()));
        if (body.containsKey("listingFeeAgri")) s.setListingFeeAgri(CommonUtils.parseDecimal(body.get("listingFeeAgri"), s.getListingFeeAgri()));
        if (body.containsKey("listingFeeResidential")) s.setListingFeeResidential(CommonUtils.parseDecimal(body.get("listingFeeResidential"), s.getListingFeeResidential()));
        if (body.containsKey("listingFeeFlat")) s.setListingFeeFlat(CommonUtils.parseDecimal(body.get("listingFeeFlat"), s.getListingFeeFlat()));
        if (body.containsKey("listingFeeCommercial")) s.setListingFeeCommercial(CommonUtils.parseDecimal(body.get("listingFeeCommercial"), s.getListingFeeCommercial()));
        if (body.containsKey("listingFeeFeaturedExtra")) s.setListingFeeFeaturedExtra(CommonUtils.parseDecimal(body.get("listingFeeFeaturedExtra"), s.getListingFeeFeaturedExtra()));
        if (body.containsKey("referralVerifiedBonusFixed")) s.setReferralVerifiedBonusFixed(CommonUtils.parseDecimal(body.get("referralVerifiedBonusFixed"), s.getReferralVerifiedBonusFixed()));
        if (body.containsKey("dealClosureFixedCommission")) s.setDealClosureFixedCommission(CommonUtils.parseDecimal(body.get("dealClosureFixedCommission"), s.getDealClosureFixedCommission()));
        if (body.containsKey("dealClosurePercentCommission")) s.setDealClosurePercentCommission(CommonUtils.parseDecimal(body.get("dealClosurePercentCommission"), s.getDealClosurePercentCommission()));
        if (body.containsKey("advisoryReservePercent")) s.setAdvisoryReservePercent(CommonUtils.parseDecimal(body.get("advisoryReservePercent"), s.getAdvisoryReservePercent()));
        if (body.containsKey("supportPhone")) s.setSupportPhone(String.valueOf(body.get("supportPhone")));
        if (body.containsKey("supportWhatsapp")) s.setSupportWhatsapp(String.valueOf(body.get("supportWhatsapp")));
        if (body.containsKey("supportEmail")) s.setSupportEmail(String.valueOf(body.get("supportEmail")));
        if (body.containsKey("officeAddress")) s.setOfficeAddress(String.valueOf(body.get("officeAddress")));
        s.setUpdatedAt(LocalDateTime.now());
        return ResponseEntity.ok(settingRepository.save(s));
    }

    @GetMapping("/payment-methods")
    public ResponseEntity<List<PaymentMethodEntity>> getAllPaymentMethods() {
        return ResponseEntity.ok(paymentMethodRepository.findAll());
    }

    @PostMapping("/payment-methods")
    public ResponseEntity<PaymentMethodEntity> createPaymentMethod(@RequestBody PaymentMethodEntity pm) {
        return ResponseEntity.ok(paymentMethodRepository.save(pm));
    }

    @PutMapping("/payment-methods/{id}")
    public ResponseEntity<?> updatePaymentMethod(@PathVariable Long id, @RequestBody PaymentMethodEntity updated) {
        Optional<PaymentMethodEntity> opt = paymentMethodRepository.findById(id);
        if (opt.isEmpty()) return ResponseEntity.notFound().build();
        PaymentMethodEntity pm = opt.get();
        pm.setProviderName(updated.getProviderName());
        pm.setAccountNumber(updated.getAccountNumber());
        pm.setAccountType(updated.getAccountType());
        pm.setInstructions(updated.getInstructions());
        pm.setActive(updated.isActive());
        return ResponseEntity.ok(paymentMethodRepository.save(pm));
    }

    @DeleteMapping("/payment-methods/{id}")
    public ResponseEntity<?> deletePaymentMethod(@PathVariable Long id) {
        paymentMethodRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "পেমেন্ট মাধ্যম মুছে ফেলা হয়েছে।"));
    }

    @GetMapping("/locations")
    public ResponseEntity<List<LocationEntity>> getAllLocations() {
        return ResponseEntity.ok(locationRepository.findByActiveTrueOrderByDistrictNameBnAscUpazilaNameBnAsc());
    }

    @PostMapping("/locations")
    public ResponseEntity<LocationEntity> addLocation(@RequestBody Map<String, Object> body) {
        String distBn = String.valueOf(body.getOrDefault("districtNameBn", body.getOrDefault("district", "নোয়াখালী"))).trim();
        String upzBn = String.valueOf(body.getOrDefault("upazilaNameBn", body.getOrDefault("upazila", ""))).trim();
        String distEn = String.valueOf(body.getOrDefault("districtNameEn", distBn)).trim();
        String upzEn = String.valueOf(body.getOrDefault("upazilaNameEn", upzBn)).trim();

        LocationEntity loc = new LocationEntity();
        loc.setDistrictNameBn(distBn);
        loc.setDistrictNameEn(distEn);
        loc.setUpazilaNameBn(upzBn);
        loc.setUpazilaNameEn(upzEn);
        loc.setAreaType(String.valueOf(body.getOrDefault("areaType", upzBn.contains("পৌরসভা") ? "POURASHAVA" : "UPAZILA")));
        if (body.containsKey("subAreaNames")) {
            loc.setSubAreaNames(String.valueOf(body.get("subAreaNames")).trim());
        }
        loc.setSubAreaType(String.valueOf(body.getOrDefault("subAreaType", loc.getAreaType().equals("POURASHAVA") ? "WARD" : "UNION")));
        loc.setActive(true);
        return ResponseEntity.ok(locationRepository.save(loc));
    }

    @DeleteMapping("/locations/{id}")
    public ResponseEntity<?> deleteLocation(@PathVariable Long id) {
        locationRepository.deleteById(id);
        return ResponseEntity.ok(Map.of("message", "উপজেলা মুছে ফেলা হয়েছে।"));
    }
}
