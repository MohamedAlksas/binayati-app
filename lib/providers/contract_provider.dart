import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/contract_service.dart';
import '../models/contract.dart';

final contractsProvider = FutureProvider.autoDispose<List<ContractSummary>>((ref) async {
  final service = ContractService();
  return await service.getContracts();
});

final expiringContractsProvider = FutureProvider.autoDispose<List<ContractSummary>>((ref) async {
  final service = ContractService();
  return await service.getContracts(expiringSoon: true);
});

final contractDetailProvider = FutureProvider.autoDispose.family<Contract, int>((ref, id) async {
  final service = ContractService();
  return await service.getContract(id);
});
