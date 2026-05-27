import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_service.dart';
import '../models/notification.dart';

final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>((ref) async {
  final service = NotificationService();
  return await service.getNotifications();
});

final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final service = NotificationService();
  return await service.getUnreadCount();
});
