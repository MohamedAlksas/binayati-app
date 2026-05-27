import 'api_client.dart';
import '../models/building.dart';

class BuildingService {
  final ApiClient _api = ApiClient();

  Future<Building?> getBuilding() async {
    try {
      final response = await _api.get('/building');
      if (response.data == null || (response.data is Map && response.data.isEmpty)) {
        return null;
      }
      return Building.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateBuilding(String name, String address) async {
    await _api.put('/building', data: {'name': name, 'address': address});
  }
}
