class ContractSummary {
  final int id;
  final String tenantName;
  final String unitNumber;
  final DateTime startDate;
  final DateTime endDate;
  final double rentAmount;
  final String status;
  final int daysUntilExpiry;

  ContractSummary({
    required this.id,
    required this.tenantName,
    required this.unitNumber,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    required this.status,
    required this.daysUntilExpiry,
  });

  factory ContractSummary.fromJson(Map<String, dynamic> json) {
    return ContractSummary(
      id: json['id'] ?? 0,
      tenantName: json['tenantName'] ?? '',
      unitNumber: json['unitNumber'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      rentAmount: (json['rentAmount'] ?? 0).toDouble(),
      status: json['status'] ?? '',
      daysUntilExpiry: json['daysUntilExpiry'] ?? 0,
    );
  }
}

class Contract {
  final int id;
  final int unitId;
  final String unitNumber;
  final String unitType;
  final int tenantId;
  final String tenantName;
  final String tenantPhone;
  final DateTime startDate;
  final DateTime endDate;
  final double rentAmount;
  final double annualIncreasePercent;
  final double securityDeposit;
  final bool depositRefunded;
  final String status;
  final String notes;
  final DateTime createdAt;
  final double nextRent;
  final DateTime? nextIncreaseDate;
  final List<Payment> payments;
  final List<RentIncreaseHistory> rentIncreaseHistories;

  Contract({
    required this.id,
    required this.unitId,
    required this.unitNumber,
    required this.unitType,
    required this.tenantId,
    required this.tenantName,
    required this.tenantPhone,
    required this.startDate,
    required this.endDate,
    required this.rentAmount,
    required this.annualIncreasePercent,
    required this.securityDeposit,
    required this.depositRefunded,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.nextRent,
    this.nextIncreaseDate,
    required this.payments,
    required this.rentIncreaseHistories,
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'] ?? 0,
      unitId: json['unitId'] ?? 0,
      unitNumber: json['unitNumber'] ?? '',
      unitType: json['unitType'] ?? '',
      tenantId: json['tenantId'] ?? 0,
      tenantName: json['tenantName'] ?? '',
      tenantPhone: json['tenantPhone'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      rentAmount: (json['rentAmount'] ?? 0).toDouble(),
      annualIncreasePercent: (json['annualIncreasePercent'] ?? 0).toDouble(),
      securityDeposit: (json['securityDeposit'] ?? 0).toDouble(),
      depositRefunded: json['depositRefunded'] ?? false,
      status: json['status'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      nextRent: (json['nextRent'] ?? 0).toDouble(),
      nextIncreaseDate: json['nextIncreaseDate'] != null ? DateTime.parse(json['nextIncreaseDate']) : null,
      payments: (json['payments'] as List? ?? []).map((p) => Payment.fromJson(p)).toList(),
      rentIncreaseHistories: (json['rentIncreaseHistories'] as List? ?? []).map((r) => RentIncreaseHistory.fromJson(r)).toList(),
    );
  }
}

class Payment {
  final int id;
  final int contractId;
  final double amount;
  final DateTime paidDate;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String method;
  final String notes;

  Payment({
    required this.id,
    required this.contractId,
    required this.amount,
    required this.paidDate,
    required this.periodStart,
    required this.periodEnd,
    required this.method,
    required this.notes,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? 0,
      contractId: json['contractId'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
      paidDate: DateTime.parse(json['paidDate']),
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      method: json['method'] ?? '',
      notes: json['notes'] ?? '',
    );
  }
}

class RentIncreaseHistory {
  final int id;
  final int contractId;
  final double oldRent;
  final double newRent;
  final double increasePercent;
  final DateTime appliedDate;

  RentIncreaseHistory({
    required this.id,
    required this.contractId,
    required this.oldRent,
    required this.newRent,
    required this.increasePercent,
    required this.appliedDate,
  });

  factory RentIncreaseHistory.fromJson(Map<String, dynamic> json) {
    return RentIncreaseHistory(
      id: json['id'] ?? 0,
      contractId: json['contractId'] ?? 0,
      oldRent: (json['oldRent'] ?? 0).toDouble(),
      newRent: (json['newRent'] ?? 0).toDouble(),
      increasePercent: (json['increasePercent'] ?? 0).toDouble(),
      appliedDate: DateTime.parse(json['appliedDate']),
    );
  }
}
