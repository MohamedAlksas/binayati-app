import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/contract_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/contract_service.dart';

class ContractDetailScreen extends ConsumerWidget {
  final int contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contractAsync = ref.watch(contractDetailProvider(contractId));
    final currency = NumberFormat('#,##0', 'ar_EG');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل العقد')),
      body: contractAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (c) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(c.tenantName[0], style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.primaryColor)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(c.tenantName, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                            Text(c.tenantPhone, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: c.status == 'Active'
                              ? AppTheme.accentColor.withValues(alpha: 0.1)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.status == 'Active' ? 'نشط' : 'منتهي',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.status == 'Active' ? AppTheme.accentColor : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('معلومات العقد', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 12),
                      _row(theme, 'الوحدة', c.unitNumber),
                      _row(theme, 'النوع', c.unitType == 'Shop' ? 'محل' : 'شقة'),
                      _row(theme, 'تاريخ البداية', DateFormat('yyyy/MM/dd', 'ar').format(c.startDate)),
                      _row(theme, 'تاريخ النهاية', DateFormat('yyyy/MM/dd', 'ar').format(c.endDate)),
                      const Divider(height: 24),
                      _row(theme, 'الإيجار الحالي', '${currency.format(c.rentAmount)} ج.م', valueColor: AppTheme.primaryColor),
                      _row(theme, 'الإيجار القادم', '${currency.format(c.nextRent)} ج.م'),
                      _row(theme, 'الزيادة السنوية', '${c.annualIncreasePercent}%'),
                      _row(theme, 'التأمين', '${currency.format(c.securityDeposit)} ج.م'),
                      if (c.depositRefunded)
                        _row(theme, 'التأمين', 'تم رده'),
                    ],
                  ),
                ),
              ),
              if (c.payments.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('سجل الدفعات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...c.payments.map((p) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: AppTheme.accentColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text('${currency.format(p.amount)} ج.م', style: theme.textTheme.titleMedium)),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(DateFormat('yyyy/MM/dd', 'ar').format(p.paidDate), style: theme.textTheme.bodySmall),
                            Text(p.method, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                          ],
                        ),
                      ],
                    ),
                  ),
                )),
              ],
              if (c.rentIncreaseHistories.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('تاريخ الزيادات', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                ...c.rentIncreaseHistories.map((r) => Card(
                  margin: const EdgeInsets.only(bottom: 6),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.warningColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.trending_up_rounded, color: AppTheme.warningColor, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${currency.format(r.oldRent)} → ${currency.format(r.newRent)} ج.م', style: theme.textTheme.titleMedium),
                              Text('${r.increasePercent}% - ${DateFormat('yyyy/MM/dd', 'ar').format(r.appliedDate)}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
              if (c.status == 'Active') ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showTerminateDialog(context, ref),
                    icon: const Icon(Icons.cancel_outlined, color: AppTheme.errorColor),
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

  Widget _row(ThemeData theme, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          const Spacer(),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, color: valueColor)),
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
