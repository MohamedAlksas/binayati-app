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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
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
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    floor.label.isNotEmpty ? floor.label : 'الطابق ${floor.floorNumber}',
                    style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor),
                  ),
                ),
                const Spacer(),
                Text('${floor.units.length} وحدة', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: floor.units.map<Widget>((unit) {
                Color bgColor;
                IconData icon;
                String label;

                if (unit.isOwnerUnit) {
                  bgColor = AppTheme.primaryColor.withValues(alpha: 0.1);
                  icon = Icons.home_rounded;
                  label = '${unit.unitNumber}\n(سكنك)';
                } else if (unit.isOccupied) {
                  bgColor = AppTheme.accentColor.withValues(alpha: 0.1);
                  icon = Icons.check_circle_rounded;
                  label = unit.unitNumber;
                } else {
                  bgColor = AppTheme.errorColor.withValues(alpha: 0.08);
                  icon = Icons.cancel_rounded;
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
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: unit.isOwnerUnit ? AppTheme.primaryColor : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(icon, size: 24, color: unit.isOwnerUnit
                            ? AppTheme.primaryColor
                            : unit.isOccupied
                                ? AppTheme.accentColor
                                : AppTheme.errorColor),
                        const SizedBox(height: 6),
                        Text(label, textAlign: TextAlign.center,
                            style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
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
