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
    final theme = Theme.of(context);

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
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text('ملخص سريع', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'الدخل الشهري',
                        value: '${currency.format(dash.totalMonthlyIncome)} ج.م',
                        icon: Icons.trending_up_rounded,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'العقود النشطة',
                        value: '${dash.activeContracts}',
                        icon: Icons.description_rounded,
                        color: AppTheme.ctaColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'الوحدات الفارغة',
                        value: '${dash.vacantUnits}',
                        icon: Icons.meeting_room_rounded,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'إجمالي التأمين',
                        value: '${currency.format(dash.totalSecurityDeposits)} ج.م',
                        icon: Icons.verified_user_rounded,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (dash.expiringSoon.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Text('عقود تنتهي قريبًا', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  ...dash.expiringSoon.map((c) => Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.warningColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.warning_amber_rounded, color: AppTheme.warningColor, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(c.tenantName, style: theme.textTheme.titleMedium),
                                const SizedBox(height: 2),
                                Text('الوحدة ${c.unitNumber} - ${c.daysUntilExpiry} يوم متبقي',
                                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          Text('${currency.format(c.rentAmount)} ج.م',
                              style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor)),
                        ],
                      ),
                    ),
                  )),
                ],
                const SizedBox(height: 32),
                Text('الدخل الشهري (آخر ١٢ شهر)', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
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
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
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
                                          style: const TextStyle(fontSize: 10, color: AppTheme.textColor)),
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
                  ),
                ),
                const SizedBox(height: 32),
                Text('آخر الدفعات', style: theme.textTheme.titleLarge),
                const SizedBox(height: 12),
                ...dash.recentPayments.map((p) => Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.check_circle_rounded, color: AppTheme.accentColor, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.tenantName, style: theme.textTheme.titleMedium),
                              const SizedBox(height: 2),
                              Text('الوحدة ${p.unitNumber}',
                                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${currency.format(p.amount)} ج.م',
                                style: theme.textTheme.titleMedium?.copyWith(color: AppTheme.primaryColor)),
                            const SizedBox(height: 2),
                            Text(DateFormat('yyyy/MM/dd', 'ar').format(p.paidDate),
                                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500)),
                          ],
                        ),
                      ],
                    ),
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
