import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/contract_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/payment_service.dart';

class ContractDetailScreen extends ConsumerWidget {
  final int contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(contractDetailProvider(contractId));
    final currency = NumberFormat('#,##0', 'ar_EG');

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل العقد')),
      body: contractAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (c) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppTheme.primaryColor, size: 28),
                      ),
                      const SizedBox(height: 8),
                      Text(c.tenantName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(c.tenantPhone.isNotEmpty ? c.tenantPhone : '', style: TextStyle(color: Colors.grey.shade600)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: c.status == 'Active' ? AppTheme.accentColor.withOpacity(0.1) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          c.status == 'Active' ? 'نشط' : 'منتهي',
                          style: TextStyle(
                            color: c.status == 'Active' ? AppTheme.accentColor : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('معلومات العقد', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Divider(),
                      _row('الوحدة', c.unitNumber),
                      _row('النوع', c.unitType == 'Shop' ? 'محل' : 'شقة'),
                      _row('تاريخ البداية', DateFormat('yyyy/MM/dd', 'ar').format(c.startDate)),
                      _row('تاريخ النهاية', DateFormat('yyyy/MM/dd', 'ar').format(c.endDate)),
                      _row('الإيجار الحالي', '${currency.format(c.rentAmount)} ج.م'),
                      _row('الإيجار القادم', '${currency.format(c.nextRent)} ج.م'),
                      _row('الزيادة السنوية', '${c.annualIncreasePercent}%'),
                      _row('التأمين', '${currency.format(c.securityDeposit)} ج.م'),
                      if (c.depositRefunded) _row('التأمين', 'تم رده'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (c.payments.isNotEmpty) ...[
                Text('سجل الدفعات', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...c.payments.map((p) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle, color: AppTheme.accentColor),
                    title: Text('${currency.format(p.amount)} ج.م'),
                    subtitle: Text(DateFormat('yyyy/MM/dd', 'ar').format(p.paidDate)),
                    trailing: Text(p.method, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ),
                )),
              ],
              if (c.rentIncreaseHistories.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('تاريخ الزيادات', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...c.rentIncreaseHistories.map((r) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.trending_up, color: AppTheme.warningColor),
                    title: Text('${currency.format(r.oldRent)} → ${currency.format(r.newRent)} ج.م'),
                    subtitle: Text('${r.increasePercent}% - ${DateFormat('yyyy/MM/dd', 'ar').format(r.appliedDate)}'),
                  ),
                )),
              ],
              if (c.status == 'Active') ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showTerminateDialog(context, ref),
                    icon: const Icon(Icons.cancel, color: AppTheme.errorColor),
                    label: const Text('إنهاء العقد', style: TextStyle(color: AppTheme.errorColor)),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.errorColor)),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showTerminateDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إنهاء العقد'),
        content: const Text('هل أنت متأكد من إنهاء هذا العقد؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(
            onPressed: () async {
              try {
                await ContractService().terminateContract(contractId);
                Navigator.pop(ctx);
                ref.refresh(contractDetailProvider(contractId));
                ref.refresh(contractsProvider);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
              }
            },
            child: const Text('تأكيد', style: TextStyle(color: AppTheme.errorColor)),
          ),
        ],
      ),
    );
  }
}
