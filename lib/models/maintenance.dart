class MaintenanceRequest {
  final int id;
  final int unitId;
  final String unitNumber;
  final int? tenantId;
  final String tenantName;
  final String title;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  MaintenanceRequest({
    required this.id,
    required this.unitId,
    required this.unitNumber,
    this.tenantId,
    required this.tenantName,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.resolvedAt,
  });

  factory MaintenanceRequest.fromJson(Map<String, dynamic> json) {
    return MaintenanceRequest(
      id: json['id'] ?? 0,
      unitId: json['unitId'] ?? 0,
      unitNumber: json['unitNumber'] ?? '',
      tenantId: json['tenantId'],
      tenantName: json['tenantName'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt']) : null,
    );
  }
}
