import 'package:flutter/material.dart';
import 'package:landtrust_app/core/animations/animated_fade_switcher.dart';
import 'package:landtrust_app/core/network/api_client.dart';
import 'package:landtrust_app/core/widgets/account_status_lock_dialog.dart';
import '../../view_models/member_portal_view_model.dart';
import '../../widgets/add_custom_proposal_dialog.dart';
import '../../widgets/agreement_certificate_dialog.dart';
import '../../widgets/buyer_workspace_view.dart';
import '../../widgets/listing_form_dialog.dart';
import '../../widgets/marketing_officer_view.dart';
import '../../widgets/member_header_banner.dart';
import '../../widgets/member_notifications_dialog.dart';
import '../../widgets/member_proposals_section.dart';
import '../../widgets/payout_and_resubmit_dialogs.dart';
import '../../widgets/portal_mode_chips.dart';
import '../../widgets/private_document_preview_dialog.dart';
import '../../widgets/profile_and_security_dialogs.dart';
import '../../widgets/requirement_form_dialog.dart';
import '../../widgets/seller_workspace_view.dart';

class MemberDashboardMobileView extends StatelessWidget {
  final MemberPortalViewModel viewModel;
  final VoidCallback onRefreshParent;
  final List<String> Function() getDistricts;
  final List<String> Function(String) getUpazilas;

  const MemberDashboardMobileView({
    super.key,
    required this.viewModel,
    required this.onRefreshParent,
    required this.getDistricts,
    required this.getUpazilas,
  });

  @override
  Widget build(BuildContext context) {
    final user = viewModel.currentUser!;
    final role = user['role'] as String? ?? 'BUYER';
    final unreadCount = (viewModel.notificationsData['unreadCount'] as num?)?.toInt() ?? 0;
    final currentMode = viewModel.activePortalMode.isEmpty ? role : viewModel.activePortalMode;
    final isLocked = (user['accountStatus'] ?? 'PENDING') != 'ACTIVE';
    void guardAction(VoidCallback action) {
      if (isLocked) {
        AccountStatusLockDialog.show(
          context,
          user: user,
          onResubmitRequested: () => ResubmitPaymentDialog.show(
            context,
            user: user,
            isMobile: true,
            onSubmit: viewModel.resubmitPayment,
          ),
        );
      } else {
        action();
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      floatingActionButton: currentMode == 'MARKETING_OFFICER'
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xFF0B4F32),
              foregroundColor: Colors.white,
              tooltip: currentMode == 'SELLER' ? 'নতুন জমি যোগ করুন' : 'নতুন চাহিদা দিন',
              onPressed: () => guardAction(() {
                if (currentMode == 'SELLER') {
                  ListingFormDialog.show(context, isMobile: true, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.createListing(p); onRefreshParent(); });
                } else {
                  RequirementFormDialog.show(context, isMobile: true, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.createRequirement(p); onRefreshParent(); });
                }
              }),
              child: const Icon(Icons.add_rounded, size: 26),
            ),
      body: RefreshIndicator(
        color: const Color(0xFF0B4F32),
        onRefresh: viewModel.loadData,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
          children: [
            MemberHeaderBanner(
              user: user,
              isMobile: true,
              unreadCount: unreadCount,
              onProfileClick: () => ProfileAndSecurityDialog.show(context, user: user, isMobile: true, districts: getDistricts(), getUpazilas: getUpazilas, onUpdateProfile: viewModel.updateProfile, onChangePassword: viewModel.changePassword),
              onNotificationsClick: () => MemberNotificationsDialog.show(context, notificationsData: viewModel.notificationsData, isMobile: true, onMarkRead: viewModel.markNotificationRead),
              onRefresh: () {
                viewModel.loadData();
                onRefreshParent();
              },
              onResubmitPaymentClick: () => ResubmitPaymentDialog.show(context, user: user, isMobile: true, onSubmit: viewModel.resubmitPayment),
            ),
            const SizedBox(height: 12),
            PortalModeChips(currentMode: currentMode, userRole: role, listingsCount: viewModel.myListings.length, requirementsCount: viewModel.myRequirements.length, onModeChanged: viewModel.switchMode),
            const SizedBox(height: 14),
            AnimatedFadeSwitcher(
              child: KeyedSubtree(
                key: ValueKey(currentMode),
                child: Column(
                  children: [
                    if (currentMode == 'MARKETING_OFFICER')
                      MarketingOfficerView(
                        officerData: viewModel.officerDashboard,
                        isMobile: true,
                        onPayoutRequest: () => OfficerPayoutDialog.show(context, pendingPayable: viewModel.officerDashboard['pendingPayableCommission'] ?? 0, isMobile: true, onSubmit: viewModel.requestOfficerPayout),
                      )
                    else if (currentMode == 'SELLER') ...[
                      SellerWorkspaceView(
                        myListings: viewModel.myListings,
                        isMobile: true,
                        onAddListing: () => guardAction(() => ListingFormDialog.show(context, isMobile: true, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.createListing(p); onRefreshParent(); })),
                        onAddProposal: () => guardAction(() => AddCustomProposalDialog.show(context, isMobile: true, onSubmitted: viewModel.loadData)),
                        onEditListing: (item) => ListingFormDialog.show(context, existing: item, isMobile: true, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.updateListing(item['id'] as int, p); onRefreshParent(); }),
                        onPreviewDoc: (item) => PrivateDocumentPreviewDialog.show(context, listing: item, isMobile: true),
                        onMarkSold: (id) async { await ApiClient.post('/member/seller/listings/$id/sold'); await viewModel.loadData(); onRefreshParent(); },
                      ),
                      const SizedBox(height: 16),
                      MemberProposalsSection(proposals: viewModel.myProposals, isMobile: true, onShowCertificate: (p) => AgreementCertificateDialog.show(context, proposal: p, isMobile: true)),
                    ] else ...[
                      BuyerWorkspaceView(
                        myRequirements: viewModel.myRequirements,
                        myInquiries: viewModel.myInquiries,
                        isMobile: true,
                        onAddRequirement: () => guardAction(() => RequirementFormDialog.show(context, isMobile: true, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.createRequirement(p); onRefreshParent(); })),
                        onAddProposal: () => guardAction(() => AddCustomProposalDialog.show(context, isMobile: true, onSubmitted: viewModel.loadData)),
                        onEditRequirement: (item) => RequirementFormDialog.show(context, existing: item, isMobile: true, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.updateRequirement(item['id'] as int, p); onRefreshParent(); }),
                        onFulfillRequirement: (id) async { await ApiClient.post('/member/buyer/requirements/$id/fulfill'); await viewModel.loadData(); onRefreshParent(); },
                      ),
                      const SizedBox(height: 16),
                      MemberProposalsSection(proposals: viewModel.myProposals, isMobile: true, onShowCertificate: (p) => AgreementCertificateDialog.show(context, proposal: p, isMobile: true)),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
