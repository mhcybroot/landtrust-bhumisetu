import 'admin_auth_transitions.dart';
import 'finance_payment_transitions.dart';
import 'gis_map_transitions.dart';
import 'media_gallery_transitions.dart';
import 'route_navigation_transitions.dart';

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
