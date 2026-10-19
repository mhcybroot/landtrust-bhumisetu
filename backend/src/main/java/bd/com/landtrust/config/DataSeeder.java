package bd.com.landtrust.config;

import bd.com.landtrust.entity.*;
import bd.com.landtrust.repository.*;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.util.List;

@Component
public class DataSeeder implements CommandLineRunner {

    private final UserRepository userRepository;
    private final SystemSettingRepository settingRepository;
    private final PaymentMethodRepository paymentMethodRepository;
    private final LocationRepository locationRepository;
    private final PasswordEncoder passwordEncoder;

    public DataSeeder(
            UserRepository userRepository,
            SystemSettingRepository settingRepository,
            PaymentMethodRepository paymentMethodRepository,
            LocationRepository locationRepository,
            PasswordEncoder passwordEncoder) {
        this.userRepository = userRepository;
        this.settingRepository = settingRepository;
        this.paymentMethodRepository = paymentMethodRepository;
        this.locationRepository = locationRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    public void run(String... args) {
        if (settingRepository.count() == 0) {
            SystemSettingEntity s = new SystemSettingEntity();
            s.setBuyerRegistrationFee(new BigDecimal("500"));
            s.setSellerRegistrationFee(new BigDecimal("500"));
            s.setOfficerRegistrationFee(new BigDecimal("300"));
            s.setReferralVerifiedBonusFixed(new BigDecimal("100"));
            s.setDealClosureFixedCommission(new BigDecimal("5000"));
            s.setDealClosurePercentCommission(new BigDecimal("10"));
            s.setAdvisoryReservePercent(new BigDecimal("25"));
            s.setSupportPhone("01711-889900");
            s.setSupportEmail("support@bhumisetu.com.bd");
            s.setOfficeAddress("প্রধান কার্যালয়: মাইজদী কোর্ট, সদর, নোয়াখালী");
            settingRepository.save(s);
        }

        if (paymentMethodRepository.count() == 0) {
            PaymentMethodEntity bkash = new PaymentMethodEntity();
            bkash.setProviderName("বিকাশ (bKash)");
            bkash.setAccountNumber("01711-889900");
            bkash.setAccountType("Personal (Send Money)");
            bkash.setInstructions("বিকাশ অ্যাপ থেকে Send Money করে আপনার বিকাশ নম্বর ও TrxID নিচের ফর্মে লিখুন।");
            bkash.setActive(true);

            PaymentMethodEntity nagad = new PaymentMethodEntity();
            nagad.setProviderName("নগদ (Nagad)");
            nagad.setAccountNumber("01819-556677");
            nagad.setAccountType("Merchant / Personal");
            nagad.setInstructions("নগদ থেকে টাকা পাঠিয়ে TrxID প্রদান করুন।");
            nagad.setActive(true);

            PaymentMethodEntity bank = new PaymentMethodEntity();
            bank.setProviderName("ইসলামী ব্যাংক পিএলসি (মাইজদী শাখা)");
            bank.setAccountNumber("A/C: 205019802004512 (Bhumi Setu)");
            bank.setAccountType("Bank Account");
            bank.setInstructions("ব্যাংক ডিপোজিট বা সেলফিন/NPSB ট্রান্সফার করে রেফারেন্স আইডি দিন।");
            bank.setActive(true);

            paymentMethodRepository.saveAll(List.of(bkash, nagad, bank));
        }

        if (locationRepository.count() == 0) {
            String[][] noakhaliUpazilas = {
                {"নোয়াখালী সদর", "Noakhali Sadar"},
                {"বেগমগঞ্জ", "Begumganj"},
                {"চাটখিল", "Chatkhil"},
                {"কোম্পানীগঞ্জ", "Companiganj"},
                {"সেনবাগ", "Senbagh"},
                {"সোনাইমুড়ী", "Sonaimuri"},
                {"কবিরহাট", "Kabirhat"},
                {"সুবর্ণচর", "Subarnachar"},
                {"হাতিয়া", "Hatiya"}
            };
            for (String[] upz : noakhaliUpazilas) {
                LocationEntity loc = new LocationEntity();
                loc.setDistrictNameBn("নোয়াখালী");
                loc.setDistrictNameEn("Noakhali");
                loc.setUpazilaNameBn(upz[0]);
                loc.setUpazilaNameEn(upz[1]);
                loc.setActive(true);
                locationRepository.save(loc);
            }
        }

        // Seed only demo users (no dummy listings, requirements, proposals, commissions, or transactions)
        if (userRepository.count() == 0) {
            // 1. Super Admin
            UserEntity admin = new UserEntity();
            admin.setFullName("কেন্দ্রীয় অ্যাডমিন (ভূমি সেতু)");
            admin.setPhoneNumber("01700000000");
            admin.setPasswordHash(passwordEncoder.encode("admin123"));
            admin.setRole("ADMIN");
            admin.setAccountStatus("ACTIVE");
            admin.setDistrict("নোয়াখালী");
            admin.setUpazila("নোয়াখালী সদর");
            admin.setAddress("মাইজদী কোর্ট, নোয়াখালী");
            userRepository.save(admin);

            // 2. Marketing Officer 1 (Referral Code: LT-NOA-1001)
            UserEntity officer1 = new UserEntity();
            officer1.setFullName("মোঃ কামরুল হাসান (মার্কেটিং অফিসার)");
            officer1.setPhoneNumber("01800000001");
            officer1.setPasswordHash(passwordEncoder.encode("123456"));
            officer1.setRole("MARKETING_OFFICER");
            officer1.setAccountStatus("ACTIVE");
            officer1.setDistrict("নোয়াখালী");
            officer1.setUpazila("নোয়াখালী সদর");
            officer1.setAddress("সোনাপুর, সদর, নোয়াখালী");
            officer1.setMyReferralCode("LT-NOA-1001");
            officer1.setRegistrationFeeAmount(new BigDecimal("300"));
            officer1.setPaymentMethod("বিকাশ (bKash)");
            officer1.setSenderPhone("01800000001");
            officer1.setTransactionId("DEMO-OFFICER");
            officer1.setTotalEarnedCommission(BigDecimal.ZERO);
            officer1.setTotalPaidCommission(BigDecimal.ZERO);
            officer1 = userRepository.save(officer1);

            // 3. Seller 1 (Demo Seller)
            UserEntity seller1 = new UserEntity();
            seller1.setFullName("হাজী আবদুল মালেক (বিক্রেতা)");
            seller1.setPhoneNumber("01900000002");
            seller1.setPasswordHash(passwordEncoder.encode("123456"));
            seller1.setRole("SELLER");
            seller1.setAccountStatus("ACTIVE");
            seller1.setDistrict("নোয়াখালী");
            seller1.setUpazila("নোয়াখালী সদর");
            seller1.setAddress("হাউজিং এস্টেট, মাইজদী, নোয়াখালী");
            seller1.setReferredByOfficerId(officer1.getId());
            seller1.setReferredByCode(officer1.getMyReferralCode());
            seller1.setReferredByOfficerName(officer1.getFullName());
            seller1.setRegistrationFeeAmount(new BigDecimal("500"));
            seller1.setPaymentMethod("বিকাশ (bKash)");
            seller1.setSenderPhone("01900000002");
            seller1.setTransactionId("DEMO-SELLER");
            userRepository.save(seller1);

            // 4. Buyer 1 (Demo Buyer)
            UserEntity buyer1 = new UserEntity();
            buyer1.setFullName("প্রবাসী আনোয়ার হোসেন (ক্রেতা)");
            buyer1.setPhoneNumber("01600000003");
            buyer1.setPasswordHash(passwordEncoder.encode("123456"));
            buyer1.setRole("BUYER");
            buyer1.setAccountStatus("ACTIVE");
            buyer1.setDistrict("নোয়াখালী");
            buyer1.setUpazila("নোয়াখালী সদর");
            buyer1.setAddress("দত্তেরহাট, নোয়াখালী সদর");
            buyer1.setReferredByOfficerId(officer1.getId());
            buyer1.setReferredByCode(officer1.getMyReferralCode());
            buyer1.setReferredByOfficerName(officer1.getFullName());
            buyer1.setRegistrationFeeAmount(new BigDecimal("500"));
            buyer1.setPaymentMethod("নগদ (Nagad)");
            buyer1.setSenderPhone("01600000003");
            buyer1.setTransactionId("DEMO-BUYER");
            userRepository.save(buyer1);
        }
    }
}
