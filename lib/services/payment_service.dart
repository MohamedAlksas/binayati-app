import 'api_client.dart';
import '../models/contract.dart';

class PaymentService {
  final ApiClient _api = ApiClient();

  Future<List<Payment>> getPayments(int contractId) async {
    final response = await _api.get('/payments/contract/$contractId');
    return (response.data as List).map((p) => Payment.fromJson(p)).toList();
  }

  Future<int> createPayment(Map<String, dynamic> data) async {
    final response = await _api.post('/payments', data: data);
    return response.data['id'];
  }

  Future<void> deletePayment(int id) async {
    await _api.delete('/payments/$id');
  }
}
