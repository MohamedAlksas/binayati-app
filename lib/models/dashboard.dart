import 'contract.dart';

class Dashboard {
  final double totalMonthlyIncome;
  final int activeContracts;
  final int vacantUnits;
  final int totalUnits;
  final double totalSecurityDeposits;
  final List<ContractSummary> expiringSoon;
  final List<RecentPayment> recentPayments;
  final List<MonthlyIncome> monthlyIncome;

  Dashboard({
    required this.totalMonthlyIncome,
    required this.activeContracts,
    required this.vacantUnits,
    required this.totalUnits,
    required this.totalSecurityDeposits,
    required this.expiringSoon,
    required this.recentPayments,
    required this.monthlyIncome,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    return Dashboard(
      totalMonthlyIncome: (json['totalMonthlyIncome'] ?? 0).toDouble(),
      activeContracts: json['activeContracts'] ?? 0,
      vacantUnits: json['vacantUnits'] ?? 0,
      totalUnits: json['totalUnits'] ?? 0,
      totalSecurityDeposits: (json['totalSecurityDeposits'] ?? 0).toDouble(),
      expiringSoon: (json['expiringSoon'] as List? ?? []).map((c) => ContractSummary.fromJson(c)).toList(),
      recentPayments: (json['recentPayments'] as List? ?? []).map((p) => RecentPayment.fromJson(p)).toList(),
      monthlyIncome: (json['monthlyIncome'] as List? ?? []).map((m) => MonthlyIncome.fromJson(m)).toList(),
    );
  }
}

class RecentPayment {
  final int id;
  final String tenantName;
  final String unitNumber;
  final double amount;
  final DateTime paidDate;
  final String method;

  RecentPayment({
    required this.id,
    required this.tenantName,
    required this.unitNumber,
    required this.amount,
    required this.paidDate,
    required this.method,
  });

  factory RecentPayment.fromJson(Map<String, dynamic> json) {
    return RecentPayment(
      id: json['id'] ?? 0,
      tenantName: json['tenantName'] ?? '',
      unitNumber: json['unitNumber'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paidDate: DateTime.parse(json['paidDate']),
      method: json['method'] ?? '',
    );
  }
}

class MonthlyIncome {
  final String month;
  final int year;
  final double total;

  MonthlyIncome({required this.month, required this.year, required this.total});

  factory MonthlyIncome.fromJson(Map<String, dynamic> json) {
    return MonthlyIncome(
      month: json['month'] ?? '',
      year: json['year'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}
