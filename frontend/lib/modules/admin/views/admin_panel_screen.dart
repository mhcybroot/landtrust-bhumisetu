import 'package:flutter/material.dart';
import '../view_models/admin_view_model.dart';
import 'mobile/admin_panel_mobile_view.dart';
import 'web/admin_panel_web_view.dart';

class AdminPanelScreen extends StatefulWidget {
  final VoidCallback onRefreshParent;

  const AdminPanelScreen({super.key, required this.onRefreshParent});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  late final AdminViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AdminViewModel();
    _viewModel.loadAllData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        if (_viewModel.isLoading && _viewModel.users.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(48), child: CircularProgressIndicator()));
        }

        final isMobile = MediaQuery.of(context).size.width < 960;

        if (isMobile) {
          return AdminPanelMobileView(viewModel: _viewModel);
        }
        return AdminPanelWebView(viewModel: _viewModel);
      },
    );
  }
}
