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

    return Scaffold(
      appBar: AppBar(title: const Text('المستأجرين')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTenant(context),
        child: const Icon(Icons.person_add),
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
                  Icon(Icons.people, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('لا يوجد مستأجرين', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(tenantsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tenants.length,
              itemBuilder: (context, index) {
                final t = tenants[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(t.name[0], style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                    ),
                    title: Text(t.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (t.phoneNumber.isNotEmpty) Text(t.phoneNumber),
                        if (t.contracts.isNotEmpty)
                          Text('${t.contracts.length} عقد نشط', style: TextStyle(color: AppTheme.accentColor, fontSize: 12)),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_left),
                    isThreeLine: t.phoneNumber.isNotEmpty,
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

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24, right: 24, top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('مستأجر جديد', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                if (nameCtl.text.isEmpty) return;
                try {
                  await TenantService().createTenant({
                    'name': nameCtl.text,
                    'phoneNumber': phoneCtl.text,
                    'email': emailCtl.text,
                    'nationalId': nidCtl.text,
                  });
                  Navigator.pop(ctx);
                  ref.refresh(tenantsProvider);
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
}
