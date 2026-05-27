import 'api_client.dart';
import '../models/building.dart';
import '../models/contract.dart';
import '../models/maintenance.dart';

class UnitService {
  final ApiClient _api = ApiClient();

  Future<List<Unit>> getUnits() async {
    final response = await _api.get('/units');
    return (response.data as List).map((u) => Unit.fromJson(u)).toList();
  }

  Future<Map<String, dynamic>> getUnitDetail(int id) async {
    final response = await _api.get('/units/$id');
    return response.data;
  }

  Future<void> createUnit(Map<String, dynamic> data) async {
    await _api.post('/units', data: data);
  }

  Future<void> updateUnit(int id, Map<String, dynamic> data) async {
    await _api.put('/units/$id', data: data);
  }

  Future<void> deleteUnit(int id) async {
    await _api.delete('/units/$id');
  }
}
