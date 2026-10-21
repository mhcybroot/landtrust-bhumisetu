import 'package:flutter/material.dart';
import '../view_models/admin_view_model.dart';
import 'admin_settings_dialogs.dart';

class AdminPaymentMethodsCard extends StatelessWidget {
  final AdminViewModel viewModel;
  final bool isMobile;
  final VoidCallback? onSaved;

  const AdminPaymentMethodsCard({super.key, required this.viewModel, required this.isMobile, this.onSaved});

  @override
  Widget build(BuildContext context) {
    final pms = viewModel.paymentMethods;
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text('নিবন্ধন ফি পেমেন্ট মাধ্যম (${pms.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                  onPressed: () => AdminSettingsDialogs.showAddPaymentMethodDialog(context, isMobile: isMobile, onSubmit: (pm) async {
                    await viewModel.createPaymentMethod(pm);
                    onSaved?.call();
                  }),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('নতুন মেথড'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...pms.map((pm) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_wallet, color: Color(0xFF0B4F32)),
                  title: Text('${pm['providerName']} (${pm['accountType']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  subtitle: Text('নম্বর: ${pm['accountNumber']}', style: const TextStyle(fontSize: 11)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () async {
                      await viewModel.deletePaymentMethod(pm['id'] as int);
                      onSaved?.call();
                    },
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class AdminLocationsCard extends StatelessWidget {
  final AdminViewModel viewModel;
  final bool isMobile;
  final VoidCallback? onSaved;

  const AdminLocationsCard({super.key, required this.viewModel, required this.isMobile, this.onSaved});

  @override
  Widget build(BuildContext context) {
    final locs = viewModel.locations;
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text('কভারেজ জেলা ও উপজেলাসমূহ (${locs.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                  onPressed: () => AdminSettingsDialogs.showAddLocationDialog(context, isMobile: isMobile, onSubmit: (loc) async {
                    await viewModel.createLocation(loc);
                    onSaved?.call();
                  }),
                  icon: const Icon(Icons.add_location_alt, size: 16),
                  label: const Text('নতুন এলাকা'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: locs.map((l) => Chip(
                    label: Text('${l['districtNameBn']} - ${l['upazilaNameBn']}', style: const TextStyle(fontSize: 11.5)),
                    onDeleted: () async {
                      await viewModel.deleteLocation(l['id'] as int);
                      onSaved?.call();
                    },
                    deleteIconColor: Colors.red,
                  )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
