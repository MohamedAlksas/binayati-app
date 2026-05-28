import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'notifications_screen.dart';
import 'maintenance_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('المزيد')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          userAsync.when(
            data: (user) => Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          (user?['fullName'] ?? 'O')[0].toString(),
                          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?['fullName'] ?? 'Owner', style: theme.textTheme.titleMedium),
                          Text(user?['email'] ?? '', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            loading: () => const Card(child: ListTile(leading: CircularProgressIndicator(), title: Text('Loading...'))),
            error: (_, __) => const Card(child: ListTile(title: Text('Error'))),
          ),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
                  title: const Text('الإشعارات'),
                  trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  )),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.build_outlined, color: AppTheme.warningColor),
                  title: const Text('الصيانة'),
                  trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const MaintenanceScreen(),
                  )),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.bar_chart_rounded, color: AppTheme.secondaryColor),
                  title: const Text('التقارير'),
                  trailing: const Icon(Icons.chevron_left, color: Colors.grey),
                  onTap: () => _showReports(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
              title: const Text('تسجيل الخروج'),
              onTap: () {
                ref.read(authProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showReports(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('التقارير', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.monetization_on_rounded, color: AppTheme.accentColor),
              title: const Text('تقرير الدخل'),
              onTap: () { Navigator.pop(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: AppTheme.errorColor),
              title: const Text('المتأخرات'),
              onTap: () { Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }
}
