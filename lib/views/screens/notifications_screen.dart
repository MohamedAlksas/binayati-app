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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all_rounded),
            tooltip: 'تحديد الكل كمقروء',
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
                  Icon(Icons.notifications_off_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('لا توجد إشعارات', style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final n = notifications[index];
              IconData icon;
              Color color;

              switch (n.type) {
                case 'ContractExpiring':
                  icon = Icons.warning_amber_rounded;
                  color = AppTheme.warningColor;
                  break;
                case 'RentIncrease':
                case 'RentIncreaseApplied':
                  icon = Icons.trending_up_rounded;
                  color = AppTheme.secondaryColor;
                  break;
                default:
                  icon = Icons.notifications_rounded;
                  color = AppTheme.primaryColor;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: n.isRead ? null : AppTheme.primaryColor.withValues(alpha: 0.03),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () async {
                    if (!n.isRead) {
                      await NotificationService().markAsRead(n.id);
                      ref.refresh(notificationsProvider);
                      ref.refresh(unreadCountProvider);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(n.title, style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                              )),
                              const SizedBox(height: 4),
                              Text(n.message, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade600)),
                              const SizedBox(height: 6),
                              Text(DateFormat('yyyy/MM/dd HH:mm', 'ar').format(n.createdAt),
                                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade400, fontSize: 11)),
                            ],
                          ),
                        ),
                        if (!n.isRead)
                          Container(
                            width: 8, height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
