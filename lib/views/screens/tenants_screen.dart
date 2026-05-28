import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/tenant_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/tenant_service.dart';

class TenantsListScreen extends ConsumerStatefulWidget {
  const TenantsListScreen({super.key});

  @override
  ConsumerState<TenantsListScreen> createState() => _TenantsListScreenState();
}

class _TenantsListScreenState extends ConsumerState<TenantsListScreen> {
  @override
  Widget build(BuildContext context) {
    final tenantsAsync = ref.watch(tenantsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('المستأجرين')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTenant(context),
        child: const Icon(Icons.person_add_rounded),
      ),
      body: tenantsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tenants) {
          if (tenants.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('لا يوجد مستأجرين', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(tenantsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final t = tenants[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(t.name[0],
                                style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.name, style: theme.textTheme.titleMedium),
                              if (t.phoneNumber.isNotEmpty)
                                Text(t.phoneNumber, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                              if (t.contracts.isNotEmpty)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('${t.contracts.length} عقد نشط',
                                      style: TextStyle(fontSize: 11, color: AppTheme.accentColor)),
                                ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left, color: Colors.grey),
                      ],
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

  void _showAddTenant(BuildContext context) {
    final nameCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final nidCtl = TextEditingController();
    final theme = Theme.of(context);

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
              Text('مستأجر جديد', style: theme.textTheme.titleLarge),
              const SizedBox(height: 20),
              TextField(controller: nameCtl, decoration: const InputDecoration(labelText: 'الاسم'),
                  textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: phoneCtl, decoration: const InputDecoration(labelText: 'رقم الهاتف'),
                  keyboardType: TextInputType.phone, textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: emailCtl, decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                  textAlign: TextAlign.right),
              const SizedBox(height: 12),
              TextField(controller: nidCtl, decoration: const InputDecoration(labelText: 'الرقم القومي'),
                  textAlign: TextAlign.right),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtl.text.isEmpty) return;
                    try {
                      await TenantService().createTenant({
                        'name': nameCtl.text,
                        'phoneNumber': phoneCtl.text,
                        'email': emailCtl.text,
                        'nationalId': nidCtl.text,
                      });
                      if (ctx.mounted) Navigator.pop(ctx);
                      ref.refresh(tenantsProvider);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
                      }
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
}
