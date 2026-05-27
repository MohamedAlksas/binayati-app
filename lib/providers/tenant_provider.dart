import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/tenant_service.dart';
import '../models/tenant.dart';

final tenantsProvider = FutureProvider.autoDispose<List<Tenant>>((ref) async {
  final service = TenantService();
  return await service.getTenants();
});
