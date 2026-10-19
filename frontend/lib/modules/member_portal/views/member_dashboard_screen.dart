import 'package:flutter/material.dart';
import 'package:landtrust_app/core/network/api_client.dart';
import '../view_models/member_portal_view_model.dart';
import '../widgets/add_custom_proposal_dialog.dart';
import '../widgets/agreement_certificate_dialog.dart';
import '../widgets/buyer_workspace_view.dart';
import '../widgets/listing_form_dialog.dart';
import '../widgets/marketing_officer_view.dart';
import '../widgets/member_header_banner.dart';
import '../widgets/member_notifications_dialog.dart';
import '../widgets/member_proposals_section.dart';
import '../widgets/payout_and_resubmit_dialogs.dart';
import '../widgets/portal_mode_chips.dart';
import '../widgets/private_document_preview_dialog.dart';
import '../widgets/profile_and_security_dialogs.dart';
import '../widgets/requirement_form_dialog.dart';
import '../widgets/seller_workspace_view.dart';

class MemberDashboardScreen extends StatefulWidget {
  final VoidCallback onRefreshParent;

  const MemberDashboardScreen({super.key, required this.onRefreshParent});

  @override
  State<MemberDashboardScreen> createState() => _MemberDashboardScreenState();
}

class _MemberDashboardScreenState extends State<MemberDashboardScreen> {
  late final MemberPortalViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = MemberPortalViewModel();
    _viewModel.loadData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  List<String> _getDistricts() {
    final locs = (_viewModel.publicConfig['locations'] as List<dynamic>?) ?? [];
    return locs.isNotEmpty ? locs.map((l) => l['districtNameBn'].toString()).toSet().toList() : ['নোয়াখালী'];
  }

  List<String> _getUpazilas(String district) {
    final locs = (_viewModel.publicConfig['locations'] as List<dynamic>?) ?? [];
    final list = locs.where((l) => l['districtNameBn'] == district).map((l) => l['upazilaNameBn'].toString()).toSet().toList();
    return list.isNotEmpty ? list : ['নোয়াখালী সদর', 'বেগমগঞ্জ', 'চাটখিল', 'কোম্পানীগঞ্জ', 'সেনবাগ', 'সোনাইমুড়ী', 'কবিরহাট', 'সুবর্ণচর', 'হাতিয়া'];
  }

  void _showListingDialog({Map<String, dynamic>? existing, bool isMobile = false}) {
    ListingFormDialog.show(
      context,
      existing: existing,
      isMobile: isMobile,
      districts: _getDistricts(),
      getUpazilas: _getUpazilas,
      onSubmit: (p) async {
        if (existing != null) {
          await _viewModel.updateListing(existing['id'] as int, p);
        } else {
          await _viewModel.createListing(p);
        }
        widget.onRefreshParent();
      },
    );
  }

  void _showRequirementDialog({Map<String, dynamic>? existing, bool isMobile = false}) {
    RequirementFormDialog.show(
      context,
      existing: existing,
      isMobile: isMobile,
      districts: _getDistricts(),
      getUpazilas: _getUpazilas,
      onSubmit: (p) async {
        await _viewModel.createRequirement(p);
        widget.onRefreshParent();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        final user = _viewModel.currentUser;
        if (user == null) return const Center(child: Text('দয়া করে প্রথমে লগইন করুন।'));
        if (_viewModel.isLoading && _viewModel.myListings.isEmpty && _viewModel.myRequirements.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
        }

        final role = user['role'] as String? ?? 'BUYER';
        final unreadCount = (_viewModel.notificationsData['unreadCount'] as num?)?.toInt() ?? 0;
        final currentMode = _viewModel.activePortalMode.isEmpty ? role : _viewModel.activePortalMode;
        final isMobile = MediaQuery.of(context).size.width < 768;

        return RefreshIndicator(
          onRefresh: _viewModel.loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 12 : 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1180),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MemberHeaderBanner(
                      user: user,
                      isMobile: isMobile,
                      unreadCount: unreadCount,
                      onProfileClick: () => ProfileAndSecurityDialog.show(context, user: user, isMobile: isMobile, districts: _getDistricts(), getUpazilas: _getUpazilas, onUpdateProfile: _viewModel.updateProfile, onChangePassword: _viewModel.changePassword),
                      onNotificationsClick: () => MemberNotificationsDialog.show(context, notificationsData: _viewModel.notificationsData, isMobile: isMobile, onMarkRead: _viewModel.markNotificationRead),
                      onRefresh: () {
                        _viewModel.loadData();
                        widget.onRefreshParent();
                      },
                      onResubmitPaymentClick: () => ResubmitPaymentDialog.show(context, user: user, isMobile: isMobile, onSubmit: _viewModel.resubmitPayment),
                    ),
                    const SizedBox(height: 14),
                    PortalModeChips(currentMode: currentMode, userRole: role, listingsCount: _viewModel.myListings.length, requirementsCount: _viewModel.myRequirements.length, onModeChanged: _viewModel.switchMode),
                    const SizedBox(height: 16),
                    if (currentMode == 'MARKETING_OFFICER')
                      MarketingOfficerView(
                        officerData: _viewModel.officerDashboard,
                        isMobile: isMobile,
                        onPayoutRequest: () => OfficerPayoutDialog.show(context, pendingPayable: _viewModel.officerDashboard['pendingPayableCommission'] ?? 0, isMobile: isMobile, onSubmit: _viewModel.requestOfficerPayout),
                      )
                    else if (currentMode == 'SELLER') ...[
                      SellerWorkspaceView(
                        myListings: _viewModel.myListings,
                        isMobile: isMobile,
                        onAddListing: () => _showListingDialog(isMobile: isMobile),
                        onAddProposal: () => AddCustomProposalDialog.show(context, isMobile: isMobile, onSubmitted: _viewModel.loadData),
                        onEditListing: (item) => _showListingDialog(existing: item, isMobile: isMobile),
                        onPreviewDoc: (item) => PrivateDocumentPreviewDialog.show(context, listing: item, isMobile: isMobile),
                        onMarkSold: (id) async {
                          await ApiClient.post('/member/seller/listings/$id/sold');
                          await _viewModel.loadData();
                          widget.onRefreshParent();
                        },
                      ),
                      const SizedBox(height: 18),
                      MemberProposalsSection(proposals: _viewModel.myProposals, isMobile: isMobile, onShowCertificate: (p) => AgreementCertificateDialog.show(context, proposal: p, isMobile: isMobile)),
                    ] else ...[
                      BuyerWorkspaceView(
                        myRequirements: _viewModel.myRequirements,
                        myInquiries: _viewModel.myInquiries,
                        isMobile: isMobile,
                        onAddRequirement: () => _showRequirementDialog(isMobile: isMobile),
                        onAddProposal: () => AddCustomProposalDialog.show(context, isMobile: isMobile, onSubmitted: _viewModel.loadData),
                        onEditRequirement: (item) => _showRequirementDialog(existing: item, isMobile: isMobile),
                        onFulfillRequirement: (id) async {
                          await ApiClient.post('/member/buyer/requirements/$id/fulfill');
                          await _viewModel.loadData();
                          widget.onRefreshParent();
                        },
                      ),
                      const SizedBox(height: 18),
                      MemberProposalsSection(proposals: _viewModel.myProposals, isMobile: isMobile, onShowCertificate: (p) => AgreementCertificateDialog.show(context, proposal: p, isMobile: isMobile)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
