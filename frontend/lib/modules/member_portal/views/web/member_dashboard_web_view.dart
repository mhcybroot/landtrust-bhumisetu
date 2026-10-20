import 'package:flutter/material.dart';
import 'package:landtrust_app/core/network/api_client.dart';
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

class MemberDashboardWebView extends StatelessWidget {
  final MemberPortalViewModel viewModel;
  final VoidCallback onRefreshParent;
  final List<String> Function() getDistricts;
  final List<String> Function(String) getUpazilas;

  const MemberDashboardWebView({
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1180),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MemberHeaderBanner(
                user: user,
                isMobile: false,
                unreadCount: unreadCount,
                onProfileClick: () => ProfileAndSecurityDialog.show(context, user: user, isMobile: false, districts: getDistricts(), getUpazilas: getUpazilas, onUpdateProfile: viewModel.updateProfile, onChangePassword: viewModel.changePassword),
                onNotificationsClick: () => MemberNotificationsDialog.show(context, notificationsData: viewModel.notificationsData, isMobile: false, onMarkRead: viewModel.markNotificationRead),
                onRefresh: () {
                  viewModel.loadData();
                  onRefreshParent();
                },
                onResubmitPaymentClick: () => ResubmitPaymentDialog.show(context, user: user, isMobile: false, onSubmit: viewModel.resubmitPayment),
              ),
              const SizedBox(height: 16),
              PortalModeChips(currentMode: currentMode, userRole: role, listingsCount: viewModel.myListings.length, requirementsCount: viewModel.myRequirements.length, onModeChanged: viewModel.switchMode),
              const SizedBox(height: 18),
              if (currentMode == 'MARKETING_OFFICER')
                MarketingOfficerView(
                  officerData: viewModel.officerDashboard,
                  isMobile: false,
                  onPayoutRequest: () => OfficerPayoutDialog.show(context, pendingPayable: viewModel.officerDashboard['pendingPayableCommission'] ?? 0, isMobile: false, onSubmit: viewModel.requestOfficerPayout),
                )
              else if (currentMode == 'SELLER') ...[
                SellerWorkspaceView(
                  myListings: viewModel.myListings,
                  isMobile: false,
                  onAddListing: () => ListingFormDialog.show(context, isMobile: false, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.createListing(p); onRefreshParent(); }),
                  onAddProposal: () => AddCustomProposalDialog.show(context, isMobile: false, onSubmitted: viewModel.loadData),
                  onEditListing: (item) => ListingFormDialog.show(context, existing: item, isMobile: false, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.updateListing(item['id'] as int, p); onRefreshParent(); }),
                  onPreviewDoc: (item) => PrivateDocumentPreviewDialog.show(context, listing: item, isMobile: false),
                  onMarkSold: (id) async { await ApiClient.post('/member/seller/listings/$id/sold'); await viewModel.loadData(); onRefreshParent(); },
                ),
                const SizedBox(height: 20),
                MemberProposalsSection(proposals: viewModel.myProposals, isMobile: false, onShowCertificate: (p) => AgreementCertificateDialog.show(context, proposal: p, isMobile: false)),
              ] else ...[
                BuyerWorkspaceView(
                  myRequirements: viewModel.myRequirements,
                  myInquiries: viewModel.myInquiries,
                  isMobile: false,
                  onAddRequirement: () => RequirementFormDialog.show(context, isMobile: false, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.createRequirement(p); onRefreshParent(); }),
                  onAddProposal: () => AddCustomProposalDialog.show(context, isMobile: false, onSubmitted: viewModel.loadData),
                  onEditRequirement: (item) => RequirementFormDialog.show(context, existing: item, isMobile: false, districts: getDistricts(), getUpazilas: getUpazilas, onSubmit: (p) async { await viewModel.createRequirement(p); onRefreshParent(); }),
                  onFulfillRequirement: (id) async { await ApiClient.post('/member/buyer/requirements/$id/fulfill'); await viewModel.loadData(); onRefreshParent(); },
                ),
                const SizedBox(height: 20),
                MemberProposalsSection(proposals: viewModel.myProposals, isMobile: false, onShowCertificate: (p) => AgreementCertificateDialog.show(context, proposal: p, isMobile: false)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
