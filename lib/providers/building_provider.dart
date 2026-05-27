import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/building_service.dart';
import '../models/building.dart';

final buildingProvider = FutureProvider.autoDispose<Building?>((ref) async {
  final service = BuildingService();
  return await service.getBuilding();
});
