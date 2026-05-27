import 'api_client.dart';
import '../models/notification.dart';

class NotificationService {
  final ApiClient _api = ApiClient();

  Future<List<AppNotification>> getNotifications() async {
    final response = await _api.get('/notifications');
    return (response.data as List).map((n) => AppNotification.fromJson(n)).toList();
  }

  Future<int> getUnreadCount() async {
    final response = await _api.get('/notifications/unread-count');
    return response.data['count'] ?? 0;
  }

  Future<void> markAsRead(int id) async {
    await _api.put('/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _api.put('/notifications/read-all');
  }
}
