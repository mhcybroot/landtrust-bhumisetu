import 'package:flutter/material.dart';
import '../view_models/marketplace_view_model.dart';
import 'mobile/buyer_demands_mobile_view.dart';
import 'web/buyer_demands_web_view.dart';

class BuyerDemandsPublicView extends StatelessWidget {
  final MarketplaceViewModel viewModel;
  final bool isMobile;
  final VoidCallback onNavigateToAuth;

  const BuyerDemandsPublicView({
    super.key,
    required this.viewModel,
    required this.isMobile,
    required this.onNavigateToAuth,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return BuyerDemandsMobileView(
        viewModel: viewModel,
        onNavigateToAuth: onNavigateToAuth,
      );
    }
    return BuyerDemandsWebView(
      viewModel: viewModel,
      onNavigateToAuth: onNavigateToAuth,
    );
  }
}
