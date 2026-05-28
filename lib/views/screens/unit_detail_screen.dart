import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../services/unit_service.dart';
import '../../services/payment_service.dart';
import '../../services/contract_service.dart';
import '../../theme/app_theme.dart';

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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('الوحدة ${unit.unitNumber}')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: (unit.isOwnerUnit
                                  ? AppTheme.primaryColor
                                  : unit.isOccupied
                                      ? AppTheme.accentColor
                                      : AppTheme.errorColor).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              unit.isOwnerUnit ? Icons.home_rounded : unit.type == 'Shop' ? Icons.store_rounded : Icons.apartment_rounded,
                              size: 40,
                              color: unit.isOwnerUnit
                                  ? AppTheme.primaryColor
                                  : unit.isOccupied
                                      ? AppTheme.accentColor
                                      : AppTheme.errorColor,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(unit.unitNumber, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          Text(
                            unit.isOwnerUnit ? 'وحدتك السكنية' : unit.type == 'Shop' ? 'محل' : 'شقة',
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: (unit.isOwnerUnit
                                  ? AppTheme.primaryColor
                                  : unit.isOccupied
                                      ? AppTheme.accentColor
                                      : AppTheme.errorColor).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
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
                    Text('العقد النشط', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _infoRow(theme, 'المستأجر', _detail!['activeContract']['tenantName'] ?? ''),
                            _infoRow(theme, 'الإيجار', '${currency.format((_detail!['activeContract']['rentAmount'] ?? 0).toDouble())} ج.م'),
                            _infoRow(theme, 'تاريخ البداية', _formatDate(_detail!['activeContract']['startDate'])),
                            _infoRow(theme, 'تاريخ النهاية', _formatDate(_detail!['activeContract']['endDate'])),
                            _infoRow(theme, 'متبقي', '${_detail!['activeContract']['daysUntilExpiry'] ?? 0} يوم'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showAddPayment(context),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('تسجيل دفعة'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showApplyIncrease(context),
                        icon: const Icon(Icons.trending_up_rounded),
                        label: const Text('تطبيق زيادة سنوية'),
                      ),
                    ),
                  ],
                  if (_detail != null && _detail!['maintenanceRequests'] != null && (_detail!['maintenanceRequests'] as List).isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('طلبات الصيانة', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ...(_detail!['maintenanceRequests'] as List).map((m) => Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: (m['status'] == 'Completed' || m['status'] == 'Resolved'
                                    ? AppTheme.accentColor : AppTheme.warningColor).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                m['status'] == 'Completed' || m['status'] == 'Resolved'
                                    ? Icons.check_circle_rounded : Icons.build_rounded,
                                color: m['status'] == 'Completed' || m['status'] == 'Resolved'
                                    ? AppTheme.accentColor : AppTheme.warningColor,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(m['title'] ?? '', style: theme.textTheme.titleMedium),
                            const Spacer(),
                            Text(m['status'] ?? '', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    )),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _infoRow(ThemeData theme, String label, String value) {
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
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تسجيل دفعة جديدة', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(
                controller: amountCtl,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showApplyIncrease(BuildContext context) {
    final percentCtl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('تطبيق زيادة سنوية', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(
                controller: percentCtl,
                textAlign: TextAlign.right,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'نسبة الزيادة (%)'),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
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
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
