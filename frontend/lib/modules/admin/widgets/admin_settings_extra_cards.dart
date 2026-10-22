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

class AdminLocationsCard extends StatefulWidget {
  final AdminViewModel viewModel;
  final bool isMobile;
  final VoidCallback? onSaved;

  const AdminLocationsCard({super.key, required this.viewModel, required this.isMobile, this.onSaved});

  @override
  State<AdminLocationsCard> createState() => _AdminLocationsCardState();
}

class _AdminLocationsCardState extends State<AdminLocationsCard> {
  String _selectedDistrict = '';

  @override
  Widget build(BuildContext context) {
    final allLocs = widget.viewModel.locations;
    final districts = allLocs.map((l) => l['districtNameBn'].toString()).toSet().toList();
    final locs = allLocs.where((l) => _selectedDistrict.isEmpty || l['districtNameBn'] == _selectedDistrict).toList();
    final pourashavas = locs.where((l) => l['areaType'] == 'POURASHAVA').toList();
    final upazilas = locs.where((l) => l['areaType'] != 'POURASHAVA').toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(widget.isMobile ? 12 : 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text('কভারেজ এলাকা ব্যবস্থাপনা (${allLocs.length} এলাকা, ${districts.length} জেলা)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0B4F32), foregroundColor: Colors.white),
                  onPressed: () => AdminSettingsDialogs.showAddLocationDialog(context, isMobile: widget.isMobile, onSubmit: (loc) async {
                    await widget.viewModel.createLocation(loc);
                    widget.onSaved?.call();
                  }),
                  icon: const Icon(Icons.add_location_alt, size: 16),
                  label: const Text('নতুন এলাকা যোগ'),
                ),
              ],
            ),
            if (districts.length > 1) ...[
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ChoiceChip(
                      label: Text('সকল জেলা (${allLocs.length})'),
                      selected: _selectedDistrict.isEmpty,
                      onSelected: (_) => setState(() => _selectedDistrict = ''),
                    ),
                    ...districts.map((d) {
                      final count = allLocs.where((l) => l['districtNameBn'] == d).length;
                      return Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: ChoiceChip(
                          label: Text('$d ($count)'),
                          selected: _selectedDistrict == d,
                          onSelected: (_) => setState(() => _selectedDistrict = d),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            if (pourashavas.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.apartment, size: 16, color: Colors.purple),
                  const SizedBox(width: 4),
                  Text('${_selectedDistrict.isNotEmpty ? "$_selectedDistrict-র " : ""}পৌরসভাসমূহ (${pourashavas.length}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.purple)),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: pourashavas.map((l) => _buildChip(l)).toList(),
              ),
            ],
            if (upazilas.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.nature_people, size: 16, color: Color(0xFF0B4F32)),
                  const SizedBox(width: 4),
                  Text('${_selectedDistrict.isNotEmpty ? "$_selectedDistrict-র " : ""}উপজেলাসমূহ (${upazilas.length}):', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0B4F32))),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: upazilas.map((l) => _buildChip(l)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChip(dynamic l) {
    final subCount = (l['subAreaNames']?.toString().split(',') ?? []).where((s) => s.trim().isNotEmpty).length;
    final isPourashava = l['areaType'] == 'POURASHAVA';
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: isPourashava ? Colors.purple.shade50 : const Color(0xFFE8F5E9),
        child: Icon(isPourashava ? Icons.apartment : Icons.location_city, size: 13, color: isPourashava ? Colors.purple : const Color(0xFF0B4F32)),
      ),
      label: Text(
        '${l['upazilaNameBn']}${_selectedDistrict.isEmpty ? " (${l['districtNameBn']})" : ""}${subCount > 0 ? " - $subCount ${isPourashava ? 'ওয়ার্ড' : 'ইউনিয়ন'}" : ''}',
        style: const TextStyle(fontSize: 11.5),
      ),
      onDeleted: () async {
        await widget.viewModel.deleteLocation(l['id'] as int);
        widget.onSaved?.call();
      },
      deleteIconColor: Colors.red,
    );
  }
}
