import 'package:flutter/material.dart';
import '../view_models/marketplace_view_model.dart';
import 'mobile/home_marketplace_mobile_view.dart';
import 'web/home_marketplace_web_view.dart';

class HomeMarketplaceView extends StatelessWidget {
  final MarketplaceViewModel viewModel;
  final bool isMobile;
  final VoidCallback onNavigateToAuth;

  const HomeMarketplaceView({
    super.key,
    required this.viewModel,
    required this.isMobile,
    required this.onNavigateToAuth,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return HomeMarketplaceMobileView(
        viewModel: viewModel,
        onNavigateToAuth: onNavigateToAuth,
      );
    }
    return HomeMarketplaceWebView(
      viewModel: viewModel,
      onNavigateToAuth: onNavigateToAuth,
    );
  }
}
