import 'package:flutter/material.dart';
import 'admin_auth_transitions.dart';
import 'finance_payment_transitions.dart';
import 'form_wizard_transitions.dart';
import 'gis_map_transitions.dart';
import 'media_gallery_transitions.dart';
import 'route_navigation_transitions.dart';
import 'shared_element_transitions.dart';
import 'sheet_drawer_transitions.dart';
import 'state_micro_transitions.dart';

/// Spec Aliases ensuring 100% naming parity across Design Spec and Plan.
typedef GridToLightboxZoom = ThumbnailToLightboxMorph;
typedef BeforeAfterSliderWipe = BeforeAfterCurtainWipe;
typedef Panorama360SwipeRotate = Panorama360SpinTransition;
typedef DroneVideoThumbnailMorph = VideoPlayPulseOverlay;
typedef FloorPlanLevelSwitch = BlueprintFloorPlanCrossfade;
typedef PhotoAlbumCubeTransition = DocumentPdfPageTurnTransition;
typedef ThumbnailStripReveal = FilmstripSlideCrossfade;
typedef VideoPipMinimizeTransition = DroneAerialZoomReveal;
typedef VirtualTourHotspotJump = ThumbnailToLightboxMorph;
typedef SatelliteTimelapseWipe = MouzaOverlayCrossfade;

typedef BajnaToEscrowLockTransition = PaymentSuccessCoinDropTransition;
typedef PaymentMethodRadioBounce = OtpDigitBoxPulseTransition;
typedef CommissionFilterCurtainDrop = CommissionSplitSlidingBar;
typedef DigitalReceiptPaperUnfold = DigitalReceiptFoldUnfoldTransition;
typedef TokenCountdownPulse = EscrowStatusProgressStepTransition;
typedef WalletBalanceCreditRoll = TkCurrencyRollingOdometerTransition;
typedef RefundReverseArrowTransition = PayoutTransferFlyArrow;
typedef InstallmentScheduleCardFlip = BankCardFlipCvvTransition;
typedef TaxSummarySlideUpDrawer = InvoiceQrCodeZoomReveal;
typedef PaymentConfirmationShieldGlow = SecurityShieldLockSnap;

typedef BuyerToSellerFlipTransition = RoleSwitchCrossfadeTransition;
typedef AdminTabSlidingUnderline = AdminDashboardCardStaggerSlide;
typedef OtpPinAutoFocusHop = TwoFactorCodeCellSlide;
typedef BiometricScanWaveTransition = BiometricScanRippleTransition;
typedef InactivitySessionBlurTransition = SessionTimeoutWarningSlide;
typedef DocumentRejectFlagDrop = AdminApprovalStampSlam;
typedef PermissionToggleMorph = PermissionRevokeStrikeTransition;
typedef LogoutReverseZoomTransition = LogoutExitShrinkFadeTransition;
typedef OledSunToMoonCircularReveal = CircularClipRevealRoute;
typedef SystemMaintenanceBannerSlide = SessionTimeoutWarningSlide;

typedef ActiveTabIndicatorGlide = TabContentSlideWipe;
typedef ReviewSummaryCardFlip = BankCardFlipCvvTransition;
typedef CollapsibleFormSectionAccordion = AccordionShelfExpandTransition;
typedef CurvedCornerSheetReveal = CurvedEdgePullTransition;
typedef FormStepSlideTransition = StepSlideFadeTransition;
typedef SearchBoxToResultsViewMorph = FloatingSearchToHeaderMorph;

/// Staggered entrance for bottom sheet and drawer item collections
class StaggeredSheetItemsSlide extends StatelessWidget {
  final int index;
  final Widget child;
  const StaggeredSheetItemsSlide({super.key, required this.index, required this.child});
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (180 + (index * 35)).clamp(180, 450)),
      curve: Curves.easeOutCubic,
      builder: (_, val, c) => Transform.translate(
        offset: Offset(0, 16 * (1.0 - val)),
        child: Opacity(opacity: val.clamp(0.0, 1.0), child: c),
      ),
      child: child,
    );
  }
}

/// Search filter tag horizontal bounce / elevation micro-interaction
class SearchFilterTagSlide extends StatelessWidget {
  final bool isSelected;
  final Widget child;
  const SearchFilterTagSlide({super.key, required this.isSelected, required this.child});
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, isSelected ? -2.0 : 0.0, 0),
      child: child,
    );
  }
}

/// Filter pill to expanded modal/filter panel crossfade morph
class FilterPillToFilterPanelMorph extends StatelessWidget {
  final bool isExpanded;
  final Widget collapsedPill;
  final Widget expandedPanel;
  const FilterPillToFilterPanelMorph({super.key, required this.isExpanded, required this.collapsedPill, required this.expandedPanel});
  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: collapsedPill,
      secondChild: expandedPanel,
      crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 260),
    );
  }
}
