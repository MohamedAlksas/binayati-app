import 'contract.dart';

class Tenant {
  final int id;
  final String name;
  final String phoneNumber;
  final String email;
  final String nationalId;
  final String notes;
  final DateTime createdAt;
  final List<ContractSummary> contracts;

  Tenant({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.nationalId,
    required this.notes,
    required this.createdAt,
    required this.contracts,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      nationalId: json['nationalId'] ?? '',
      notes: json['notes'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      contracts: (json['contracts'] as List? ?? []).map((c) => ContractSummary.fromJson(c)).toList(),
    );
  }
}
