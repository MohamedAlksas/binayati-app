import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import 'notifications_screen.dart';
import 'maintenance_screen.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المزيد')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          userAsync.when(
            data: (user) => Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.primaryColor,
                  child: Text((user?['fullName'] ?? 'O')[0].toString(),
                      style: const TextStyle(color: Colors.white)),
                ),
                title: Text(user?['fullName'] ?? 'Owner', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(user?['email'] ?? ''),
              ),
            ),
            loading: () => const Card(child: ListTile(leading: CircularProgressIndicator(), title: Text('Loading...'))),
            error: (_, __) => const Card(child: ListTile(title: Text('Error'))),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications, color: AppTheme.primaryColor),
                  title: const Text('الإشعارات'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const NotificationsScreen(),
                  )),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.build, color: AppTheme.warningColor),
                  title: const Text('الصيانة'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => const MaintenanceScreen(),
                  )),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bar_chart, color: AppTheme.secondaryColor),
                  title: const Text('التقارير'),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => _showReports(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: AppTheme.errorColor),
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
            const Text('التقارير', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.monetization_on, color: AppTheme.accentColor),
              title: const Text('تقرير الدخل'),
              onTap: () { Navigator.pop(ctx); },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: AppTheme.errorColor),
              title: const Text('المتأخرات'),
              onTap: () { Navigator.pop(ctx); },
            ),
          ],
        ),
      ),
    );
  }
}
