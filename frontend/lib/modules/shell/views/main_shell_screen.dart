import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:landtrust_app/modules/admin/views/admin_panel_screen.dart';
import 'package:landtrust_app/modules/auth/views/auth_screen.dart';
import 'package:landtrust_app/modules/marketplace/view_models/marketplace_view_model.dart';
import 'package:landtrust_app/modules/marketplace/views/buyer_demands_public_view.dart';
import 'package:landtrust_app/modules/marketplace/views/home_marketplace_view.dart';
import 'package:landtrust_app/modules/marketplace/views/rules_and_fees_view.dart';
import 'package:landtrust_app/modules/member_portal/views/member_dashboard_screen.dart';
import '../view_models/shell_view_model.dart';
import 'mobile/mobile_shell_view.dart';
import 'web/web_shell_view.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late final ShellViewModel _shellVm;
  late final MarketplaceViewModel _marketplaceVm;

  @override
  void initState() {
    super.initState();
    _shellVm = ShellViewModel();
    _marketplaceVm = MarketplaceViewModel();
    _marketplaceVm.loadInitialData();
  }

  @override
  void dispose() {
    _shellVm.dispose();
    _marketplaceVm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_shellVm, _marketplaceVm]),
      builder: (context, _) {
        final isMobile = !kIsWeb || MediaQuery.of(context).size.width < 960;
        final selectedTab = _shellVm.selectedTabIndex;
        final isLoggedIn = _shellVm.isLoggedIn;
        final isAdmin = _shellVm.isAdmin;

        final activeView = _buildActiveView(isMobile, selectedTab, isLoggedIn, isAdmin);

        return isMobile
            ? MobileShellView(shellVm: _shellVm, activeView: activeView, config: _marketplaceVm.config)
            : WebShellView(shellVm: _shellVm, activeView: activeView);
      },
    );
  }

  Widget _buildActiveView(bool isMobile, int tab, bool isLoggedIn, bool isAdmin) {
    return switch (tab) {
      1 => BuyerDemandsPublicView(
          viewModel: _marketplaceVm,
          isMobile: isMobile,
          onNavigateToAuth: () => _shellVm.setTabIndex(3),
        ),
      2 => RulesAndFeesView(
          config: _marketplaceVm.config,
          isMobile: isMobile,
        ),
      3 => _buildAuthOrPortalView(isMobile, isLoggedIn, isAdmin),
      _ => HomeMarketplaceView(
          viewModel: _marketplaceVm,
          isMobile: isMobile,
          onNavigateToAuth: () => _shellVm.setTabIndex(3),
        ),
    };
  }

  Widget _buildAuthOrPortalView(bool isMobile, bool isLoggedIn, bool isAdmin) {
    if (!isLoggedIn) {
      return AuthScreen(
        config: _marketplaceVm.config,
        isMobile: isMobile,
        onAuthSuccess: () {
          _marketplaceVm.loadInitialData();
          setState(() {});
        },
      );
    }
    if (isAdmin) {
      return AdminPanelScreen(
        onRefreshParent: () => _marketplaceVm.loadInitialData(),
      );
    }
    return MemberDashboardScreen(
      onRefreshParent: () => _marketplaceVm.loadInitialData(),
    );
  }
}
