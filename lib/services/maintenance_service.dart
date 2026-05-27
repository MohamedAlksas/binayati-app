import 'api_client.dart';
import '../models/maintenance.dart';

class MaintenanceService {
  final ApiClient _api = ApiClient();

  Future<List<MaintenanceRequest>> getRequests({String? status}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;

    final response = await _api.get('/maintenance', queryParameters: params.isNotEmpty ? params : null);
    return (response.data as List).map((m) => MaintenanceRequest.fromJson(m)).toList();
  }

  Future<int> createRequest(Map<String, dynamic> data) async {
    final response = await _api.post('/maintenance', data: data);
    return response.data['id'];
  }

  Future<void> updateStatus(int id, String status) async {
    await _api.put('/maintenance/$id/status', data: {'status': status});
  }
}
