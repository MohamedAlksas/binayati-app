import 'api_client.dart';
import '../models/contract.dart';
import '../models/dashboard.dart';

class ContractService {
  final ApiClient _api = ApiClient();

  Future<List<ContractSummary>> getContracts({String? status, bool? expiringSoon}) async {
    final params = <String, dynamic>{};
    if (status != null) params['status'] = status;
    if (expiringSoon != null) params['expiringSoon'] = expiringSoon;

    final response = await _api.get('/contracts', queryParameters: params.isNotEmpty ? params : null);
    return (response.data as List).map((c) => ContractSummary.fromJson(c)).toList();
  }

  Future<Contract> getContract(int id) async {
    final response = await _api.get('/contracts/$id');
    return Contract.fromJson(response.data);
  }

  Future<int> createContract(Map<String, dynamic> data) async {
    final response = await _api.post('/contracts', data: data);
    return response.data['id'];
  }

  Future<void> updateContract(int id, Map<String, dynamic> data) async {
    await _api.put('/contracts/$id', data: data);
  }

  Future<void> terminateContract(int id) async {
    await _api.put('/contracts/$id/terminate');
  }

  Future<Dashboard> getDashboard() async {
    final response = await _api.get('/dashboard');
    return Dashboard.fromJson(response.data);
  }

  Future<Map<String, dynamic>> applyIncrease(int id, double percent) async {
    final response = await _api.post('/contracts/$id/apply-increase', data: {
      'increasePercent': percent,
    });
    return response.data;
  }
}
