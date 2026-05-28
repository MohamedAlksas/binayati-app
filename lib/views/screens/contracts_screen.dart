import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/contract_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/contract_service.dart';
import '../../services/tenant_service.dart';
import '../../services/unit_service.dart';
import 'contract_detail_screen.dart';

class ContractsListScreen extends ConsumerStatefulWidget {
  const ContractsListScreen({super.key});

  @override
  ConsumerState<ContractsListScreen> createState() => _ContractsListScreenState();
}

class _ContractsListScreenState extends ConsumerState<ContractsListScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final contractsAsync = ref.watch(contractsProvider);
    final currency = NumberFormat('#,##0', 'ar_EG');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('العقود'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list_rounded),
            onSelected: (v) {
              setState(() => _filter = v);
              ref.refresh(contractsProvider);
            },
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'All', child: Text('الكل')),
              const PopupMenuItem(value: 'Active', child: Text('النشطة')),
              const PopupMenuItem(value: 'Terminated', child: Text('المنتهية')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContract(context),
        child: const Icon(Icons.add_rounded),
      ),
      body: contractsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (contracts) {
          final filtered = _filter == 'All'
              ? contracts
              : contracts.where((c) => c.status == _filter).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('لا توجد عقود', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(contractsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final c = filtered[index];
                final remaining = c.daysUntilExpiry;
                final isExpiring = remaining > 0 && remaining <= 30;

                return Card(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) => ContractDetailScreen(contractId: c.id),
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: c.status == 'Active'
                                      ? AppTheme.accentColor.withValues(alpha: 0.1)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: c.status == 'Active' ? AppTheme.accentColor : Colors.grey,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(c.tenantName, style: theme.textTheme.titleMedium),
                                    Text('الوحدة ${c.unitNumber}',
                                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${currency.format(c.rentAmount)} ج.م',
                                      style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isExpiring
                                          ? AppTheme.warningColor.withValues(alpha: 0.15)
                                          : c.status == 'Active'
                                              ? AppTheme.accentColor.withValues(alpha: 0.15)
                                              : Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      c.status == 'Active'
                                          ? (isExpiring ? 'ينتهي قريبًا' : 'نشط')
                                          : 'منتهي',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: isExpiring
                                            ? AppTheme.warningColor
                                            : c.status == 'Active'
                                                ? AppTheme.accentColor
                                                : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.date_range_rounded, size: 14, color: Colors.grey.shade400),
                              const SizedBox(width: 6),
                              Text(
                                '${DateFormat('yyyy/MM/dd', 'ar').format(c.startDate)} - ${DateFormat('yyyy/MM/dd', 'ar').format(c.endDate)}',
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showAddContract(BuildContext context) async {
    final units = await UnitService().getUnits();
    final tenants = await TenantService().getTenants();

    if (!mounted) return;

    int? selectedUnitId;
    int? selectedTenantId;
    final startCtl = TextEditingController();
    final endCtl = TextEditingController();
    final rentCtl = TextEditingController();
    final increaseCtl = TextEditingController(text: '10');
    final depositCtl = TextEditingController();

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
              Text('عقد جديد', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'الوحدة'),
                items: units.where((u) => !u.isOccupied && !u.isOwnerUnit).map((u) => DropdownMenuItem(
                  value: u.id, child: Text('${u.unitNumber} - ${u.type}'),
                )).toList(),
                onChanged: (v) => selectedUnitId = v,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'المستأجر'),
                items: tenants.map((t) => DropdownMenuItem(
                  value: t.id, child: Text(t.name),
                )).toList(),
                onChanged: (v) => selectedTenantId = v,
              ),
              const SizedBox(height: 12),
              TextField(controller: startCtl, decoration: const InputDecoration(labelText: 'تاريخ البداية (YYYY-MM-DD)'),
                  textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: endCtl, decoration: const InputDecoration(labelText: 'تاريخ النهاية (YYYY-MM-DD)'),
                  textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: rentCtl, decoration: const InputDecoration(labelText: 'قيمة الإيجار'),
                  keyboardType: TextInputType.number, textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: increaseCtl, decoration: const InputDecoration(labelText: 'نسبة الزيادة السنوية (%)'),
                  keyboardType: TextInputType.number, textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: depositCtl, decoration: const InputDecoration(labelText: 'التأمين'),
                  keyboardType: TextInputType.number, textAlign: TextAlign.right),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (selectedUnitId == null || selectedTenantId == null) return;
                    try {
                      await ContractService().createContract({
                        'unitId': selectedUnitId,
                        'tenantId': selectedTenantId,
                        'startDate': startCtl.text,
                        'endDate': endCtl.text,
                        'rentAmount': double.parse(rentCtl.text),
                        'annualIncreasePercent': double.parse(increaseCtl.text),
                        'securityDeposit': double.parse(depositCtl.text.isEmpty ? '0' : depositCtl.text),
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      ref.refresh(contractsProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      }
                    }
                  },
                  child: const Text('إنشاء العقد'),
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
