import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/unit_service.dart';
import '../../services/payment_service.dart';
import '../../services/contract_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class UnitDetailScreen extends ConsumerStatefulWidget {
  final int unitId;
  final dynamic unit;

  const UnitDetailScreen({super.key, required this.unitId, required this.unit});

  @override
  ConsumerState<UnitDetailScreen> createState() => _UnitDetailScreenState();
}

class _UnitDetailScreenState extends ConsumerState<UnitDetailScreen> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await UnitService().getUnitDetail(widget.unitId);
      setState(() { _detail = data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat('#,##0', 'ar_EG');
    final unit = widget.unit;

    return Scaffold(
      appBar: AppBar(title: Text('الوحدة ${unit.unitNumber}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            unit.isOwnerUnit ? Icons.home : unit.type == 'Shop' ? Icons.store : Icons.apartment,
                            size: 48,
                            color: unit.isOwnerUnit
                                ? AppTheme.primaryColor
                                : unit.isOccupied
                                    ? AppTheme.accentColor
                                    : AppTheme.errorColor,
                          ),
                          const SizedBox(height: 8),
                          Text(unit.unitNumber,
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            unit.isOwnerUnit ? 'وحدتك السكنية' : unit.type == 'Shop' ? 'محل' : 'شقة',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: unit.isOwnerUnit
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : unit.isOccupied
                                      ? AppTheme.accentColor.withOpacity(0.1)
                                      : AppTheme.errorColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              unit.isOwnerUnit ? 'مملوكة لك' : unit.isOccupied ? 'مؤجرة' : 'فارغة',
                              style: TextStyle(
                                color: unit.isOwnerUnit
                                    ? AppTheme.primaryColor
                                    : unit.isOccupied
                                        ? AppTheme.accentColor
                                        : AppTheme.errorColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_detail != null && _detail!['activeContract'] != null) ...[
                    const SizedBox(height: 16),
                    Text('العقد النشط', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _infoRow('المستأجر', _detail!['activeContract']['tenantName'] ?? ''),
                            _infoRow('الإيجار', '${currency.format((_detail!['activeContract']['rentAmount'] ?? 0).toDouble())} ج.م'),
                            _infoRow('تاريخ البداية', _formatDate(_detail!['activeContract']['startDate'])),
                            _infoRow('تاريخ النهاية', _formatDate(_detail!['activeContract']['endDate'])),
                            _infoRow('متبقي', '${_detail!['activeContract']['daysUntilExpiry'] ?? 0} يوم'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddPayment(context),
                        icon: const Icon(Icons.add),
                        label: const Text('تسجيل دفعة'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showApplyIncrease(context),
                        icon: const Icon(Icons.trending_up),
                        label: const Text('تطبيق زيادة سنوية'),
                      ),
                    ),
                  ],
                  if (_detail != null && _detail!['maintenanceRequests'] != null && (_detail!['maintenanceRequests'] as List).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('طلبات الصيانة', style: Theme.of(context).textTheme.titleLarge),
                    ...(_detail!['maintenanceRequests'] as List).map((m) => Card(
                      child: ListTile(
                        leading: Icon(
                          m['status'] == 'Completed' || m['status'] == 'Resolved'
                              ? Icons.check_circle : Icons.build,
                          color: m['status'] == 'Completed' || m['status'] == 'Resolved'
                              ? AppTheme.accentColor : AppTheme.warningColor,
                        ),
                        title: Text(m['title'] ?? ''),
                        subtitle: Text(m['status'] ?? ''),
                      ),
                    )),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      return DateFormat('yyyy/MM/dd', 'ar').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  void _showAddPayment(BuildContext context) {
    final amountCtl = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تسجيل دفعة جديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: amountCtl,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'المبلغ'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (amountCtl.text.isEmpty) return;
                try {
                  await PaymentService().createPayment({
                    'contractId': _detail!['activeContract']['id'],
                    'amount': double.parse(amountCtl.text),
                    'paidDate': DateTime.now().toIso8601String(),
                    'periodStart': DateTime.now().toIso8601String(),
                    'periodEnd': DateTime.now().toIso8601String(),
                    'method': 'Cash',
                  });
                  Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              },
              child: const Text('حفظ'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showApplyIncrease(BuildContext context) {
    final percentCtl = TextEditingController();
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تطبيق زيادة سنوية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: percentCtl,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'نسبة الزيادة (%)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (percentCtl.text.isEmpty) return;
                try {
                  await ContractService().applyIncrease(
                    _detail!['activeContract']['id'],
                    double.parse(percentCtl.text),
                  );
                  Navigator.pop(ctx);
                  _load();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                }
              },
              child: const Text('تطبيق'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
