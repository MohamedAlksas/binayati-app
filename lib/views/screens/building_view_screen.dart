import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/building_provider.dart';
import '../../theme/app_theme.dart';
import 'unit_detail_screen.dart';

class BuildingViewScreen extends ConsumerWidget {
  const BuildingViewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buildingAsync = ref.watch(buildingProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المبنى')),
      body: buildingAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (building) {
          if (building == null) {
            return const Center(child: Text('لم يتم إعداد المبنى بعد'));
          }

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(buildingProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: building.floors.length,
              itemBuilder: (context, index) {
                final floor = building.floors.reversed.toList()[index];
                return _FloorCard(floor: floor);
              },
            ),
          );
        },
      ),
    );
  }
}

class _FloorCard extends StatelessWidget {
  final dynamic floor;

  const _FloorCard({required this.floor});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    floor.label.isNotEmpty ? floor.label : 'الطابق ${floor.floorNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                  ),
                ),
                const Spacer(),
                Text('${floor.units.length} وحدة', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: floor.units.map<Widget>((unit) {
                Color bgColor;
                IconData icon;
                String label;

                if (unit.isOwnerUnit) {
                  bgColor = AppTheme.primaryColor.withOpacity(0.15);
                  icon = Icons.home;
                  label = '${unit.unitNumber}\n(سكنك)';
                } else if (unit.isOccupied) {
                  bgColor = AppTheme.accentColor.withOpacity(0.15);
                  icon = Icons.check_circle;
                  label = unit.unitNumber;
                } else {
                  bgColor = AppTheme.errorColor.withOpacity(0.1);
                  icon = Icons.cancel;
                  label = unit.unitNumber;
                }

                return GestureDetector(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => UnitDetailScreen(unitId: unit.id, unit: unit),
                    ));
                  },
                  child: Container(
                    width: 100,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: unit.isOwnerUnit ? AppTheme.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icon, color: unit.isOwnerUnit
                            ? AppTheme.primaryColor
                            : unit.isOccupied
                                ? AppTheme.accentColor
                                : AppTheme.errorColor),
                        const SizedBox(height: 4),
                        Text(label, textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
