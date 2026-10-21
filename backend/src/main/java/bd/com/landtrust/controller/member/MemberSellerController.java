package bd.com.landtrust.controller.member;

import bd.com.landtrust.entity.LandListingEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.LandListingRepository;
import bd.com.landtrust.repository.UserRepository;
import bd.com.landtrust.util.CommonUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping({"/api/portal", "/api/member"})
public class MemberSellerController {

    private final UserRepository userRepository;
    private final LandListingRepository listingRepository;

    public MemberSellerController(UserRepository userRepository, LandListingRepository listingRepository) {
        this.userRepository = userRepository;
        this.listingRepository = listingRepository;
    }

    private UserEntity currentUser(Authentication auth) {
        UserEntity u = (UserEntity) auth.getPrincipal();
        return userRepository.findById(u.getId()).orElse(u);
    }

    @GetMapping({"/my-listings", "/seller/listings"})
    public ResponseEntity<List<LandListingEntity>> getMyListings(Authentication auth) {
        UserEntity user = currentUser(auth);
        return ResponseEntity.ok(listingRepository.findBySellerIdOrderByCreatedAtDesc(user.getId()));
    }

    @PostMapping({"/listings", "/seller/listings"})
    public ResponseEntity<?> createListing(Authentication auth, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        if (!"ACTIVE".equals(user.getAccountStatus())) {
            return ResponseEntity.status(403).body(Map.of("message", "আপনার অ্যাকাউন্টটি এখনও সক্রিয় নয়। অ্যাডমিন পেমেন্ট যাচাই সম্পন্ন করলে আপনি জমি পোস্ট করতে পারবেন।"));
        }
        if (!"SELLER".equals(user.getRole()) && !"ADMIN".equals(user.getRole())) {
            return ResponseEntity.status(403).body(Map.of("message", "শুধুমাত্র বিক্রেতা বা অ্যাডমিন জমি বিক্রয়ের বিজ্ঞাপন দিতে পারেন।"));
        }

        String upazila = (String) body.getOrDefault("upazila", "নোয়াখালী সদর");
        String khatianNo = ((String) body.getOrDefault("khatianNo", "")).trim();
        String dagNo = ((String) body.getOrDefault("dagNo", "")).trim();

        LandListingEntity listing = new LandListingEntity();
        listing.setSellerId(user.getId());
        listing.setSellerName(user.getFullName());
        listing.setSellerPhone(user.getPhoneNumber());
        listing.setTitle((String) body.getOrDefault("title", "জমি বিক্রয়ের বিজ্ঞাপন"));
        listing.setDistrict((String) body.getOrDefault("district", "নোয়াখালী"));
        listing.setUpazila(upazila);
        listing.setAreaName((String) body.getOrDefault("areaName", ""));
        listing.setMouzaName((String) body.getOrDefault("mouzaName", ""));
        listing.setKhatianNo(khatianNo);
        listing.setDagNo(dagNo);
        listing.setMutationInfo((String) body.getOrDefault("mutationInfo", "নামজারি ও খাজনা হালনাগাদ"));
        listing.setLandType((String) body.getOrDefault("landType", "আবাসিক"));

        if (!khatianNo.isBlank() || !dagNo.isBlank()) {
            List<LandListingEntity> existingAll = listingRepository.findAll();
            for (LandListingEntity ex : existingAll) {
                if ("REJECTED".equals(ex.getListingStatus())) continue;
                if (upazila.equalsIgnoreCase(ex.getUpazila())) {
                    boolean khatianMatch = !khatianNo.isBlank() && ex.getKhatianNo() != null && khatianNo.equalsIgnoreCase(ex.getKhatianNo().trim());
                    boolean dagMatch = !dagNo.isBlank() && ex.getDagNo() != null && dagNo.equalsIgnoreCase(ex.getDagNo().trim());
                    if (khatianMatch || dagMatch) {
                        listing.setDuplicateSuspected(true);
                        listing.setDuplicateNote("সম্ভাব্য ডুপ্লিকেট: বিজ্ঞাপন #" + ex.getId() + " (" + ex.getTitle() + " - বিক্রেতা: " + ex.getSellerName() + ") এর খতিয়ান/দাগ নম্বরের সাথে মিল পাওয়া গেছে।");
                        break;
                    }
                }
            }
        }

        BigDecimal areaDecimal = CommonUtils.parseDecimal(body.get("areaDecimal"), new BigDecimal("10"));
        BigDecimal expectedPrice = CommonUtils.parseDecimal(body.get("expectedPriceBdt"), new BigDecimal("1000000"));
        BigDecimal proposedFee = CommonUtils.parseDecimal(body.get("proposedServiceFeeBdt"), BigDecimal.ZERO);

        listing.setAreaDecimal(areaDecimal);
        listing.setExpectedPriceBdt(expectedPrice);
        if (areaDecimal.compareTo(BigDecimal.ZERO) > 0) {
            listing.setPricePerDecimalBdt(expectedPrice.divide(areaDecimal, 0, RoundingMode.HALF_UP));
        } else {
            listing.setPricePerDecimalBdt(expectedPrice);
        }
        listing.setRoadAccessInfo((String) body.getOrDefault("roadAccessInfo", "১২ ফুট পাকা রাস্তা সংলগ্ন"));
        listing.setDescription((String) body.getOrDefault("description", ""));
        String imgUrl = (String) body.getOrDefault("imageUrl", "");
        listing.setImageUrl(imgUrl.isBlank() ? "https://images.unsplash.com/photo-1500382017468-9049fed747ef?w=800" : imgUrl);
        listing.setAdditionalImageUrls((String) body.getOrDefault("additionalImageUrls", ""));
        listing.setVideoUrl((String) body.getOrDefault("videoUrl", ""));
        listing.setMapLink((String) body.getOrDefault("mapLink", ""));
        listing.setPrivateDocumentUrl((String) body.getOrDefault("privateDocumentUrl", ""));
        listing.setPrivateDocumentName((String) body.getOrDefault("privateDocumentName", ""));
        listing.setProposedServiceFeeBdt(proposedFee);
        listing.setVerificationStatus("SUBMITTED");
        listing.setListingStatus("SUBMITTED");

        listing = listingRepository.save(listing);
        return ResponseEntity.ok(listing);
    }

    @PutMapping({"/listings/{id}", "/seller/listings/{id}"})
    public ResponseEntity<?> updateMyListing(Authentication auth, @PathVariable Long id, @RequestBody Map<String, Object> body) {
        UserEntity user = currentUser(auth);
        Optional<LandListingEntity> opt = listingRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getSellerId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }

        LandListingEntity listing = opt.get();
        if (body.containsKey("title")) listing.setTitle(String.valueOf(body.get("title")));
        if (body.containsKey("district")) listing.setDistrict(String.valueOf(body.get("district")));
        if (body.containsKey("upazila")) listing.setUpazila(String.valueOf(body.get("upazila")));
        if (body.containsKey("areaName")) listing.setAreaName(String.valueOf(body.get("areaName")));
        if (body.containsKey("mouzaName")) listing.setMouzaName(String.valueOf(body.get("mouzaName")));
        if (body.containsKey("khatianNo")) listing.setKhatianNo(String.valueOf(body.get("khatianNo")));
        if (body.containsKey("dagNo")) listing.setDagNo(String.valueOf(body.get("dagNo")));
        if (body.containsKey("mutationInfo")) listing.setMutationInfo(String.valueOf(body.get("mutationInfo")));
        if (body.containsKey("landType")) listing.setLandType(String.valueOf(body.get("landType")));
        if (body.containsKey("areaDecimal")) {
            listing.setAreaDecimal(CommonUtils.parseDecimal(body.get("areaDecimal"), listing.getAreaDecimal()));
        }
        if (body.containsKey("expectedPriceBdt")) {
            listing.setExpectedPriceBdt(CommonUtils.parseDecimal(body.get("expectedPriceBdt"), listing.getExpectedPriceBdt()));
        }
        if (listing.getAreaDecimal() != null && listing.getAreaDecimal().compareTo(BigDecimal.ZERO) > 0 && listing.getExpectedPriceBdt() != null) {
            listing.setPricePerDecimalBdt(listing.getExpectedPriceBdt().divide(listing.getAreaDecimal(), 0, RoundingMode.HALF_UP));
        }
        if (body.containsKey("proposedServiceFeeBdt")) {
            listing.setProposedServiceFeeBdt(CommonUtils.parseDecimal(body.get("proposedServiceFeeBdt"), listing.getProposedServiceFeeBdt()));
        }
        if (body.containsKey("roadAccessInfo")) listing.setRoadAccessInfo(String.valueOf(body.get("roadAccessInfo")));
        if (body.containsKey("description")) listing.setDescription(String.valueOf(body.get("description")));
        if (body.containsKey("imageUrl") && !String.valueOf(body.get("imageUrl")).isBlank()) {
            listing.setImageUrl(String.valueOf(body.get("imageUrl")));
        }
        if (body.containsKey("additionalImageUrls")) {
            listing.setAdditionalImageUrls(String.valueOf(body.get("additionalImageUrls")));
        }
        if (body.containsKey("videoUrl")) listing.setVideoUrl(String.valueOf(body.get("videoUrl")));
        if (body.containsKey("mapLink")) listing.setMapLink(String.valueOf(body.get("mapLink")));
        if (body.containsKey("privateDocumentUrl") && !String.valueOf(body.get("privateDocumentUrl")).isBlank()) {
            listing.setPrivateDocumentUrl(String.valueOf(body.get("privateDocumentUrl")));
        }
        if (body.containsKey("privateDocumentName") && !String.valueOf(body.get("privateDocumentName")).isBlank()) {
            listing.setPrivateDocumentName(String.valueOf(body.get("privateDocumentName")));
        }

        return ResponseEntity.ok(listingRepository.save(listing));
    }

    @RequestMapping(value = {"/listings/{id}/close", "/listings/{id}/sold", "/seller/listings/{id}/sold"}, method = {RequestMethod.PUT, RequestMethod.POST})
    public ResponseEntity<?> closeMyListing(Authentication auth, @PathVariable Long id) {
        UserEntity user = currentUser(auth);
        Optional<LandListingEntity> opt = listingRepository.findById(id);
        if (opt.isEmpty() || !opt.get().getSellerId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "অনুমোদনহীন অনুরোধ"));
        }
        LandListingEntity l = opt.get();
        l.setListingStatus("SOLD");
        listingRepository.save(l);
        return ResponseEntity.ok(l);
    }
}
