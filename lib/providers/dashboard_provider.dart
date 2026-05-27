import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/contract_service.dart';
import '../models/dashboard.dart';

final dashboardProvider = FutureProvider.autoDispose<Dashboard>((ref) async {
  final service = ContractService();
  return await service.getDashboard();
});
