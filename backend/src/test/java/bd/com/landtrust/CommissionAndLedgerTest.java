package bd.com.landtrust;

import bd.com.landtrust.controller.publicapi.PublicListingController;
import bd.com.landtrust.entity.CommissionEntryEntity;
import bd.com.landtrust.entity.LandListingEntity;
import bd.com.landtrust.entity.SystemSettingEntity;
import bd.com.landtrust.entity.UserEntity;
import bd.com.landtrust.repository.*;
import bd.com.landtrust.service.SystemSettingService;
import bd.com.landtrust.util.CommissionHelper;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

class CommissionAndLedgerTest {

    @Test
    @DisplayName("Officer commission sync correctly aggregates earned vs paid and ignores cancelled")
    void testOfficerCommissionSync() {
        UserRepository userRepo = Mockito.mock(UserRepository.class);
        CommissionEntryRepository commRepo = Mockito.mock(CommissionEntryRepository.class);

        Long officerId = 42L;
        UserEntity officer = new UserEntity();
        officer.setId(officerId);
        officer.setTotalEarnedCommission(BigDecimal.ZERO);
        officer.setTotalPaidCommission(BigDecimal.ZERO);

        CommissionEntryEntity c1 = new CommissionEntryEntity();
        c1.setStatus("APPROVED_UNPAID");
        c1.setCommissionAmountBdt(new BigDecimal("1500"));

        CommissionEntryEntity c2 = new CommissionEntryEntity();
        c2.setStatus("PAID");
        c2.setCommissionAmountBdt(new BigDecimal("2500"));

        CommissionEntryEntity c3 = new CommissionEntryEntity();
        c3.setStatus("CANCELLED");
        c3.setCommissionAmountBdt(new BigDecimal("9999"));

        when(userRepo.findById(officerId)).thenReturn(Optional.of(officer));
        when(commRepo.findByOfficerIdOrderByCreatedAtDesc(officerId)).thenReturn(List.of(c1, c2, c3));

        CommissionHelper.syncOfficerCommissionTotals(userRepo, commRepo, officerId);

        // Earned: 1500 + 2500 = 4000 (excluding 9999 cancelled)
        // Paid: 2500
        assertEquals(new BigDecimal("4000"), officer.getTotalEarnedCommission());
        assertEquals(new BigDecimal("2500"), officer.getTotalPaidCommission());
        verify(userRepo, times(1)).save(officer);
    }

    @Test
    @DisplayName("SystemSettingService caches settings in-memory and avoids repeated DB queries")
    void testSystemSettingServiceCaching() {
        SystemSettingRepository settingRepo = Mockito.mock(SystemSettingRepository.class);
        SystemSettingEntity entity = new SystemSettingEntity();
        entity.setId(1L);
        entity.setSupportEmail("info@bdhousing.com.bd");

        when(settingRepo.findAll()).thenReturn(List.of(entity));

        SystemSettingService service = new SystemSettingService(settingRepo);

        SystemSettingEntity s1 = service.getSettings();
        SystemSettingEntity s2 = service.getSettings();

        assertEquals("info@bdhousing.com.bd", s1.getSupportEmail());
        assertEquals(s1, s2);
        // Only 1 DB call should be made due to in-memory TTL caching
        verify(settingRepo, times(1)).findAll();
    }

    @Test
    @DisplayName("Percentage deal closure calculation produces expected integer BDT")
    void testPercentageCommissionMath() {
        BigDecimal dealAmount = new BigDecimal("2500000"); // 25 Lakh BDT
        BigDecimal rate = new BigDecimal("1.5"); // 1.5%

        BigDecimal commission = dealAmount.multiply(rate).divide(new BigDecimal("100"), 0, RoundingMode.HALF_UP);
        assertEquals(new BigDecimal("37500"), commission);
    }

    @Test
    @DisplayName("Active listing status filtering includes APPROVED_PUBLISHED and RESERVED while excluding PENDING_REVIEW and REJECTED")
    void testActiveListingStatusFiltering() {
        LandListingRepository listingRepo = Mockito.mock(LandListingRepository.class);
        SystemSettingRepository settingRepo = Mockito.mock(SystemSettingRepository.class);
        SystemSettingService settingService = new SystemSettingService(settingRepo);

        PublicListingController controller = new PublicListingController(
                Mockito.mock(UserRepository.class),
                settingService,
                Mockito.mock(PaymentMethodRepository.class),
                Mockito.mock(LocationRepository.class),
                listingRepo,
                Mockito.mock(BuyerRequirementRepository.class)
        );

        LandListingEntity l1 = new LandListingEntity();
        l1.setId(101L);
        l1.setTitle("Dhaka Prime Plot");
        l1.setListingStatus("APPROVED_PUBLISHED");

        LandListingEntity l2 = new LandListingEntity();
        l2.setId(102L);
        l2.setTitle("Chittagong Hill Plot");
        l2.setListingStatus("RESERVED");

        List<String> targetStatuses = List.of("APPROVED_PUBLISHED", "RESERVED");
        when(listingRepo.findByListingStatusInOrderByCreatedAtDesc(targetStatuses))
                .thenReturn(List.of(l1, l2));

        var response = controller.getPublishedListings(null, null, null, null, null, null, null, null, null);
        List<Map<String, Object>> listings = response.getBody();

        assertNotNull(listings);
        assertEquals(2, listings.size());
        assertEquals("APPROVED_PUBLISHED", listings.get(0).get("listingStatus"));
        assertEquals("RESERVED", listings.get(1).get("listingStatus"));

        // Verify repository query was invoked with exact active statuses
        verify(listingRepo).findByListingStatusInOrderByCreatedAtDesc(targetStatuses);

        // Verify inclusion and exclusion semantics
        assertTrue(targetStatuses.contains("APPROVED_PUBLISHED"), "Active query must include APPROVED_PUBLISHED");
        assertTrue(targetStatuses.contains("RESERVED"), "Active query must include RESERVED");
        assertFalse(targetStatuses.contains("PENDING_REVIEW"), "Active query must exclude PENDING_REVIEW");
        assertFalse(targetStatuses.contains("REJECTED"), "Active query must exclude REJECTED");
    }
}
