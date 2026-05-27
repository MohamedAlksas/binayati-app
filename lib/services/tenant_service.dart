import 'api_client.dart';
import '../models/tenant.dart';

class TenantService {
  final ApiClient _api = ApiClient();

  Future<List<Tenant>> getTenants() async {
    final response = await _api.get('/tenants');
    return (response.data as List).map((t) => Tenant.fromJson(t)).toList();
  }

  Future<Tenant> getTenant(int id) async {
    final response = await _api.get('/tenants/$id');
    return Tenant.fromJson(response.data);
  }

  Future<Map<String, dynamic>> createTenant(Map<String, dynamic> data) async {
    final response = await _api.post('/tenants', data: data);
    return response.data;
  }

  Future<void> updateTenant(int id, Map<String, dynamic> data) async {
    await _api.put('/tenants/$id', data: data);
  }

  Future<void> deleteTenant(int id) async {
    await _api.delete('/tenants/$id');
  }
}
