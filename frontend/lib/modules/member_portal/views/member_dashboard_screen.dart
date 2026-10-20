import 'package:flutter/material.dart';
import '../view_models/member_portal_view_model.dart';
import 'mobile/member_dashboard_mobile_view.dart';
import 'web/member_dashboard_web_view.dart';

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

        final isMobile = MediaQuery.of(context).size.width < 960;

        if (isMobile) {
          return MemberDashboardMobileView(
            viewModel: _viewModel,
            onRefreshParent: widget.onRefreshParent,
            getDistricts: _getDistricts,
            getUpazilas: _getUpazilas,
          );
        }

        return MemberDashboardWebView(
          viewModel: _viewModel,
          onRefreshParent: widget.onRefreshParent,
          getDistricts: _getDistricts,
          getUpazilas: _getUpazilas,
        );
      },
    );
  }
}
