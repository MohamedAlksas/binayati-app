class Building {
  final int id;
  final String name;
  final String address;
  final List<Floor> floors;

  Building({required this.id, required this.name, required this.address, required this.floors});

  factory Building.fromJson(Map<String, dynamic> json) {
    return Building(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      floors: (json['floors'] as List? ?? []).map((f) => Floor.fromJson(f)).toList(),
    );
  }
}

class Floor {
  final int id;
  final int floorNumber;
  final String label;
  final List<Unit> units;

  Floor({required this.id, required this.floorNumber, required this.label, required this.units});

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'] ?? 0,
      floorNumber: json['floorNumber'] ?? 0,
      label: json['label'] ?? '',
      units: (json['units'] as List? ?? []).map((u) => Unit.fromJson(u)).toList(),
    );
  }
}

class Unit {
  final int id;
  final String unitNumber;
  final String type;
  final bool isOwnerUnit;
  final String description;
  final bool isOccupied;
  final int floorId;
  final ContractSummary? activeContract;

  Unit({
    required this.id,
    required this.unitNumber,
    required this.type,
    required this.isOwnerUnit,
    required this.description,
    required this.isOccupied,
    required this.floorId,
    this.activeContract,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      unitNumber: json['unitNumber'] ?? '',
      type: json['type'] ?? 'Apartment',
      isOwnerUnit: json['isOwnerUnit'] ?? false,
      description: json['description'] ?? '',
      isOccupied: json['isOccupied'] ?? false,
      floorId: json['floorId'] ?? 0,
      activeContract: json['activeContract'] != null ? ContractSummary.fromJson(json['activeContract']) : null,
    );
  }
}
