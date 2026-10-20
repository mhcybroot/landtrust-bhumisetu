import 'package:flutter/material.dart';
import '../../view_models/shell_view_model.dart';
import '../../widgets/shell_footer.dart';
import '../../widgets/shell_header_bar.dart';

class WebShellView extends StatelessWidget {
  final ShellViewModel shellVm;
  final Widget activeView;

  const WebShellView({
    super.key,
    required this.shellVm,
    required this.activeView,
  });

  @override
  Widget build(BuildContext context) {
    final selectedTab = shellVm.selectedTabIndex;
    final isLoggedIn = shellVm.isLoggedIn;
    final isAdmin = shellVm.isAdmin;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FA),
      body: Column(
        children: [
          ShellHeaderBar(
            selectedIndex: selectedTab,
            isMobile: false,
            isLoggedIn: isLoggedIn,
            isAdmin: isAdmin,
            user: shellVm.currentUser,
            onTabSelected: shellVm.setTabIndex,
            onLogout: shellVm.logout,
          ),
          Expanded(
            child: activeView,
          ),
          const ShellFooter(isMobile: false),
        ],
      ),
    );
  }
}
