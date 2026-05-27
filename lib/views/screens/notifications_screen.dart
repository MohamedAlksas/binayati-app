import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              await NotificationService().markAllAsRead();
              ref.refresh(notificationsProvider);
              ref.refresh(unreadCountProvider);
            },
          ),
        ],
      ),
      body: notificationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('لا توجد إشعارات', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              IconData icon;
              Color color;

              switch (n.type) {
                case 'ContractExpiring':
                  icon = Icons.warning_amber;
                  color = AppTheme.warningColor;
                  break;
                case 'RentIncrease':
                case 'RentIncreaseApplied':
                  icon = Icons.trending_up;
                  color = AppTheme.secondaryColor;
                  break;
                default:
                  icon = Icons.notifications;
                  color = AppTheme.primaryColor;
              }

              return Card(
                color: n.isRead ? null : AppTheme.primaryColor.withOpacity(0.05),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: color.withOpacity(0.2),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.message, maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(DateFormat('yyyy/MM/dd HH:mm', 'ar').format(n.createdAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                  onTap: () async {
                    if (!n.isRead) {
                      await NotificationService().markAsRead(n.id);
                      ref.refresh(notificationsProvider);
                      ref.refresh(unreadCountProvider);
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
