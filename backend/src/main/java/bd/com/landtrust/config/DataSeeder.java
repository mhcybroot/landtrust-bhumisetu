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

        if (locationRepository.count() < 40) {
            locationRepository.deleteAll();

            // ================= 1. নোয়াখালী (NOAKHALI) =================
            String[][] noakhaliPourashavas = {
                {"চৌমুহনী পৌরসভা", "Choumuhani Pourashava"},
                {"নোয়াখালী পৌরসভা", "Noakhali Pourashava"},
                {"কবিরহাট পৌরসভা", "Kabirhat Pourashava"},
                {"বসুরহাট পৌরসভা", "Basurhat Pourashava"},
                {"চাটখিল পৌরসভা", "Chatkhil Pourashava"},
                {"সেনবাগ পৌরসভা", "Senbagh Pourashava"},
                {"সোনাইমুড়ী পৌরসভা", "Sonaimuri Pourashava"}
            };
            String defaultWards = "১ নং ওয়ার্ড,২ নং ওয়ার্ড,৩ নং ওয়ার্ড,৪ নং ওয়ার্ড,৫ নং ওয়ার্ড,৬ নং ওয়ার্ড,৭ নং ওয়ার্ড,৮ নং ওয়ার্ড,৯ নং ওয়ার্ড";
            for (String[] p : noakhaliPourashavas) {
                saveLocation("নোয়াখালী", "Noakhali", p[0], p[1], "POURASHAVA", defaultWards, "WARD");
            }

            String[][] noakhaliUpazilas = {
                {"নোয়াখালী সদর", "Noakhali Sadar", "চরমটুয়া,কাদিরহানিফ,বিনোদপুর,দাদপুর,চর মটুয়া,নেয়াজপুর,নোয়াখালী ইউনিয়ন,অশ্বদিয়া,কালাদরাপ"},
                {"বেগমগঞ্জ", "Begumganj", "রাজগঞ্জ,একলাশপুর,মিরওয়ারিশপুর,বেগমগঞ্জ,আমানউল্ল্যাপুর,গোপালপুর,আলাইয়ারপুর,ছয়ানী,কুতুবপুর"},
                {"সেনবাগ", "Senbagh", "ছাতারপাইয়া,কেশারপাড়,ডুমুরুয়া,কাদরা,নবীপুর,বিজবাগ,মোহাম্মদপুর"},
                {"চাটখিল", "Chatkhil", "রামনারায়ণপুর,নোয়াখলা,খিলপাড়া,বদলকোট,পরকোট,সাহাপুর,পাঁচগাঁও"},
                {"সোনাইমুড়ী", "Sonaimuri", "জয়াগ,নদনা,বজরা,দেওটি,সোনাপুর,অম্বরনগর,বারাহিপুর"},
                {"কোম্পানীগঞ্জ", "Companiganj", "চরহাজারী,চরকাঁকড়া,মুছাপুর,চরফকিরা,রামপুর,সিরাজপুর"},
                {"কবিরহাট", "Kabirhat", "নরোত্তমপুর,সুন্দলপুর,ধানসিঁড়ি,ঘোষবাগ,চাপরাশিরহাট,বাটইয়া"},
                {"সুবর্ণচর", "Subarnachar", "চরজব্বার,চরবাটা,চরক্লার্ক,চরওয়াপদা,চরআমানউল্লাহ,পূর্ব চরবাটা"},
                {"হাতিয়া", "Hatiya", "চরকিং,তমরদ্দি,সোনাদিয়া,বুড়িরচর,জাহাজমারা,নিঝুমদ্বীপ,হরণী,চাননন্দী"}
            };
            for (String[] u : noakhaliUpazilas) {
                saveLocation("নোয়াখালী", "Noakhali", u[0], u[1], "UPAZILA", u[2], "UNION");
            }

            // ================= 2. লক্ষ্মীপুর (LAKSHMIPUR) =================
            String lakshmipurWards = "১ নং ওয়ার্ড,২ নং ওয়ার্ড,৩ নং ওয়ার্ড,৪ নং ওয়ার্ড,৫ নং ওয়ার্ড,৬ নং ওয়ার্ড,৭ নং ওয়ার্ড,৮ নং ওয়ার্ড,৯ নং ওয়ার্ড,১০ নং ওয়ার্ড,১১ নং ওয়ার্ড,১২ নং ওয়ার্ড";
            saveLocation("লক্ষ্মীপুর", "Lakshmipur", "লক্ষ্মীপুর পৌরসভা", "Lakshmipur Pourashava", "POURASHAVA", lakshmipurWards, "WARD");
            saveLocation("লক্ষ্মীপুর", "Lakshmipur", "রায়পুর পৌরসভা", "Raipur Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("লক্ষ্মীপুর", "Lakshmipur", "রামগঞ্জ পৌরসভা", "Ramganj Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("লক্ষ্মীপুর", "Lakshmipur", "রামগতি পৌরসভা", "Ramgati Pourashava", "POURASHAVA", defaultWards, "WARD");

            String[][] lakshmipurUpazilas = {
                {"লক্ষ্মীপুর সদর", "Lakshmipur Sadar", "উত্তর জয়পুর,ভবানীগঞ্জ,মান্দারী,চন্দ্রগঞ্জ,হাজিরপাড়া,দালাল বাজার,চর রুহিতা,বশিকপুর,পার্বতীনগর,কুশাখালী"},
                {"রায়পুর", "Raipur", "উত্তর রায়পুর,দক্ষিণ রায়পুর,চর মোহনা,সোনাপুর,বামনী,চর আবাবিল,কেরোয়া"},
                {"রামগঞ্জ", "Ramganj", "কাঞ্চনপুর,নোয়াগাঁও,ভাদুর,ইছাপুর,চণ্ডীপুর,লামচর,দরবেশপুর,ভাটরা,করপাড়া"},
                {"রামগতি", "Ramgati", "চর বাদাম,চর পোড়াগাছা,চর রমিজ,আলেকজান্ডার,চর গাজী"},
                {"কমলনগর", "Kamalnagar", "চর কাদিরা,তোরাবগঞ্জ,হাজিরহাট,পাটারীরহাট,চর ফলকন,চর লরেন্স,সাহেবগঞ্জ"}
            };
            for (String[] u : lakshmipurUpazilas) {
                saveLocation("লক্ষ্মীপুর", "Lakshmipur", u[0], u[1], "UPAZILA", u[2], "UNION");
            }

            // ================= 3. ফেনী (FENI) =================
            String feniWards18 = "১ নং ওয়ার্ড,২ নং ওয়ার্ড,৩ নং ওয়ার্ড,৪ নং ওয়ার্ড,৫ নং ওয়ার্ড,৬ নং ওয়ার্ড,৭ নং ওয়ার্ড,৮ নং ওয়ার্ড,৯ নং ওয়ার্ড,১০ নং ওয়ার্ড,১১ নং ওয়ার্ড,১২ নং ওয়ার্ড,১৩ নং ওয়ার্ড,১৪ নং ওয়ার্ড,১৫ নং ওয়ার্ড,১৬ নং ওয়ার্ড,১৭ নং ওয়ার্ড,১৮ নং ওয়ার্ড";
            saveLocation("ফেনী", "Feni", "ফেনী পৌরসভা", "Feni Pourashava", "POURASHAVA", feniWards18, "WARD");
            saveLocation("ফেনী", "Feni", "দাগনভূঞা পৌরসভা", "Daganbhuiyan Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("ফেনী", "Feni", "সোনাগাজী পৌরসভা", "Sonagazi Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("ফেনী", "Feni", "ছাগলনাইয়া পৌরসভা", "Chhagalnaiya Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("ফেনী", "Feni", "পরশুরাম পৌরসভা", "Parshuram Pourashava", "POURASHAVA", defaultWards, "WARD");

            String[][] feniUpazilas = {
                {"ফেনী সদর", "Feni Sadar", "ফরহাদনগর,ধলিয়া,লেমুয়া,ছনুয়া,মোটবী,কাজিরবাগ,কালিদহ,বালুয়া চৌমুহনী,ধর্মপুর"},
                {"দাগনভূঞা", "Daganbhuiyan", "রাজাপুর,পূর্ব চন্দ্রপুর,সিন্দুরপুর,ইয়াকুবপুর,মাতুভূঁইয়া,দাগনভূঞা ইউনিয়ন"},
                {"সোনাগাজী", "Sonagazi", "চর মজলিশপুর,বগাদানা,মঙ্গলকান্দি,মতিগঞ্জ,চর চান্দিয়া,সোনাগাজী ইউনিয়ন,আমিরাবাদ,নবাবপুর"},
                {"ছাগলনাইয়া", "Chhagalnaiya", "পাঠাননগর,মহামায়া,রাধানগর,শুভপুর,ঘোপাল"},
                {"পরশুরাম", "Parshuram", "মির্জানগর,চিথলিয়া,বক্সমাহমুদ"},
                {"ফুলগাজী", "Fulgazi", "ফুলগাজী সদর,মুন্সীরহাট,দরবারপুর,আনন্দপুর,আমজাদহাট,জিএমহাট"}
            };
            for (String[] u : feniUpazilas) {
                saveLocation("ফেনী", "Feni", u[0], u[1], "UPAZILA", u[2], "UNION");
            }

            // ================= 4. কুমিল্লা (CUMILLA) =================
            String cumillaCCWards = "১ নং ওয়ার্ড,২ নং ওয়ার্ড,৩ নং ওয়ার্ড,৪ নং ওয়ার্ড,৫ নং ওয়ার্ড,৬ নং ওয়ার্ড,৭ নং ওয়ার্ড,৮ নং ওয়ার্ড,৯ নং ওয়ার্ড,১০ নং ওয়ার্ড,১১ নং ওয়ার্ড,১২ নং ওয়ার্ড,১৩ নং ওয়ার্ড,১৪ নং ওয়ার্ড,১৫ নং ওয়ার্ড,১৬ নং ওয়ার্ড,১৭ নং ওয়ার্ড,১৮ নং ওয়ার্ড,১৯ নং ওয়ার্ড,২০ নং ওয়ার্ড,২১ নং ওয়ার্ড,২২ নং ওয়ার্ড,২৩ নং ওয়ার্ড,২৪ নং ওয়ার্ড,২৫ নং ওয়ার্ড,২৬ নং ওয়ার্ড,২৭ নং ওয়ার্ড";
            saveLocation("কুমিল্লা", "Cumilla", "কুমিল্লা সিটি কর্পোরেশন", "Cumilla City Corporation", "POURASHAVA", cumillaCCWards, "WARD");
            saveLocation("কুমিল্লা", "Cumilla", "চান্দিনা পৌরসভা", "Chandina Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("কুমিল্লা", "Cumilla", "দাউদকান্দি পৌরসভা", "Daudkandi Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("কুমিল্লা", "Cumilla", "লাকসাম পৌরসভা", "Laksam Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("কুমিল্লা", "Cumilla", "চৌদ্দগ্রাম পৌরসভা", "Chauddagram Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("কুমিল্লা", "Cumilla", "হোমনা পৌরসভা", "Homna Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("কুমিল্লা", "Cumilla", "বরুড়া পৌরসভা", "Barura Pourashava", "POURASHAVA", defaultWards, "WARD");
            saveLocation("কুমিল্লা", "Cumilla", "দেবিদ্বার পৌরসভা", "Debidwar Pourashava", "POURASHAVA", defaultWards, "WARD");

            String[][] cumillaUpazilas = {
                {"কুমিল্লা আদর্শ সদর", "Adarsha Sadar", "কালিরবাজার,আমড়াতলী,জগন্নাথপুর,দুর্গাপুর উত্তর,দুর্গাপুর দক্ষিণ,পাঁচথুবী"},
                {"কুমিল্লা সদর দক্ষিণ", "Sadar Dakshin", "বিজয়পুর,বারপাড়া,জোড়কানন পূর্ব,জোড়কানন পশ্চিম,গলিয়ারা,চৌয়ারা"},
                {"চান্দিনা", "Chandina", "মহিচাইল,সুহিলপুর,বাতাঘাসী,বাড়েরা,গল্লাই,দোল্লাই নবাবপুর,কেরণখাল,মাইজখার"},
                {"দাউদকান্দি", "Daudkandi", "গৌরীপুর,জগতপুর,মারুকা,ইলিয়টগঞ্জ উত্তর,ইলিয়টগঞ্জ দক্ষিণ,বারপাড়া,জিংলাতলী,পাঁচগাছিয়া"},
                {"দেবিদ্বার", "Debidwar", "ফতেহাবাদ,সুবিল,এলাহাবাদ,জাফরগঞ্জ,রসুলপুর,গুনাইঘর উত্তর,গুনাইঘর দক্ষিণ,ইউসুফপুর"},
                {"লাকসাম", "Laksam", "বাকই,মুদাফফরগঞ্জ,কান্দিরপাড়,গোবিন্দপুর,উত্তরদা,আজগরা"},
                {"চৌদ্দগ্রাম", "Chauddagram", "কাশিনগর,উজিরপুর,কালিকাপুর,বাতিসা,গুণবতী,চিওড়া,মুন্সীরহাট,কনকাপৈত"},
                {"বুড়িচং", "Burichang", "রাজাপুর,বাকশীমূল,বুড়িচং সদর,ময়নামতি,মোকাম,ভারেল্লা উত্তর,ভারেল্লা দক্ষিণ"},
                {"ব্রাহ্মণপাড়া", "Brahmanpara", "মাধবপুর,শিদলাই,চান্দলা,শশীদল,দুলালপুর,ব্রাহ্মণপাড়া সদর,সাহেবাবাদ"},
                {"মুরাদনগর", "Muradnagar", "শ্রীকাইল,আকুবপুর,আন্দিকোট,পূর্বধইর পূর্ব,বাঙ্গরা পূর্ব,বাঙ্গরা পশ্চিম,ধামঘর,জাহাপুর"},
                {"মনোহরগঞ্জ", "Monoharganj", "বাইশগাঁও,সরসপুর,হাসনাবাদ,ঝলম উত্তর,ঝলম দক্ষিণ,মৈশাতুয়া,লক্ষণপুর,খিলা"},
                {"বরুড়া", "Barura", "আড্ডা,আদ্রা,আমড়াতলী,ভাউকসার,চিতড্ডা,পয়ালগাছা,গালিমপুর"},
                {"তিতাস", "Titas", "বলরামপুর,কড়িকান্দি,মজিদপুর,জিয়ারকান্দি,কলাকান্দি,ভিটিকান্দি,সাতানী"},
                {"মেঘনা", "Meghna", "চন্দনপুর,চালিবাঙ্গা,মানিকারচর,রাধানগর,লবণেচারা,গোবিন্দপুর"},
                {"লালমাই", "Lalmai", "বাগমারা উত্তর,বাগমারা দক্ষিণ,ভূল্লইন উত্তর,ভূল্লইন দক্ষিণ,পেরুল উত্তর,পেরুল দক্ষিণ"},
                {"হোমনা", "Homna", "মাথাভাঙ্গা,ঘাগুটিয়া,দুলালপুর,চান্দেরচর,আছাদপুর,নিলখী,ভাষানিয়া"}
            };
            for (String[] u : cumillaUpazilas) {
                saveLocation("কুমিল্লা", "Cumilla", u[0], u[1], "UPAZILA", u[2], "UNION");
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

    private void saveLocation(String distBn, String distEn, String upzBn, String upzEn, String areaType, String subAreas, String subAreaType) {
        LocationEntity loc = new LocationEntity();
        loc.setDistrictNameBn(distBn);
        loc.setDistrictNameEn(distEn);
        loc.setUpazilaNameBn(upzBn);
        loc.setUpazilaNameEn(upzEn);
        loc.setAreaType(areaType);
        loc.setSubAreaNames(subAreas);
        loc.setSubAreaType(subAreaType);
        loc.setActive(true);
        locationRepository.save(loc);
    }
}
