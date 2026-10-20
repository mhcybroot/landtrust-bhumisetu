import 'package:flutter/material.dart';
import 'mobile/rules_and_fees_mobile_view.dart';
import 'web/rules_and_fees_web_view.dart';

class RulesAndFeesView extends StatelessWidget {
  final Map<String, dynamic> config;
  final bool isMobile;

  const RulesAndFeesView({
    super.key,
    required this.config,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return RulesAndFeesMobileView(config: config);
    }
    return RulesAndFeesWebView(config: config);
  }
}
