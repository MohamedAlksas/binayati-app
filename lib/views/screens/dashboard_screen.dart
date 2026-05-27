import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/dashboard_provider.dart';
import '../../theme/app_theme.dart';
import '../widgets/stat_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('بنايتي')),
      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (dash) {
          final currency = NumberFormat('#,##0', 'ar_EG');

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(dashboardProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('ملخص سريع', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'الدخل الشهري',
                        value: '${currency.format(dash.totalMonthlyIncome)} ج.م',
                        icon: Icons.monetization_on,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        title: 'العقود النشطة',
                        value: '${dash.activeContracts}',
                        icon: Icons.description,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'الوحدات الفارغة',
                        value: '${dash.vacantUnits}',
                        icon: Icons.room,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: StatCard(
                        title: 'إجمالي التأمين',
                        value: '${currency.format(dash.totalSecurityDeposits)} ج.م',
                        icon: Icons.security,
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                if (dash.expiringSoon.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('عقود تنتهي قريبًا', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  ...dash.expiringSoon.map((c) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.warning_amber, color: AppTheme.warningColor),
                      title: Text(c.tenantName),
                      subtitle: Text('الوحدة ${c.unitNumber} - ${c.daysUntilExpiry} يوم متبقي'),
                      trailing: Text('${currency.format(c.rentAmount)} ج.م'),
                    ),
                  )),
                ],
                const SizedBox(height: 24),
                Text('الدخل الشهري (آخر ١٢ شهر)', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: dash.monthlyIncome.isEmpty
                          ? 100
                          : dash.monthlyIncome.map((m) => m.total).reduce((a, b) => a > b ? a : b) * 1.2,
                      barGroups: dash.monthlyIncome.asMap().entries.map((entry) {
                        return BarChartGroupData(x: entry.key, barRods: [
                          BarChartRodData(
                            toY: entry.value.total,
                            color: AppTheme.primaryColor,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ]);
                      }).toList(),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value >= 0 && value < dash.monthlyIncome.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(dash.monthlyIncome[value.toInt()].month,
                                      style: const TextStyle(fontSize: 10)),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text('آخر الدفعات', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                ...dash.recentPayments.map((p) => Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.accentColor.withOpacity(0.2),
                      child: const Icon(Icons.check, color: AppTheme.accentColor),
                    ),
                    title: Text(p.tenantName),
                    subtitle: Text('الوحدة ${p.unitNumber} - ${DateFormat('yyyy/MM/dd', 'ar').format(p.paidDate)}'),
                    trailing: Text('${currency.format(p.amount)} ج.م'),
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}
