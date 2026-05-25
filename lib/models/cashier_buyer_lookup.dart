class CashierBuyerLookupResult {
  const CashierBuyerLookupResult({required this.buyer, required this.vehicles});

  final CashierBuyerInfo buyer;
  final List<CashierVehicleInfo> vehicles;

  factory CashierBuyerLookupResult.fromJson(Map<String, dynamic> json) {
    final buyerJson = json['buyer'] as Map<String, dynamic>? ?? const {};
    final vehiclesJson =
        json['vehicles'] as List<dynamic>? ?? const <dynamic>[];

    return CashierBuyerLookupResult(
      buyer: CashierBuyerInfo.fromJson(buyerJson),
      vehicles: vehiclesJson
          .whereType<Map<String, dynamic>>()
          .map(CashierVehicleInfo.fromJson)
          .toList(),
    );
  }
}

class CashierBuyerInfo {
  const CashierBuyerInfo({
    required this.buyerProfileId,
    required this.userId,
    required this.name,
    required this.nikSnapshot,
    required this.verificationStatus,
    required this.riskScore,
    this.isPinActive = false,
  });

  final String buyerProfileId;
  final String userId;
  final String name;
  final String nikSnapshot;
  final String verificationStatus;
  final double riskScore;
  final bool isPinActive;

  factory CashierBuyerInfo.fromJson(Map<String, dynamic> json) {
    return CashierBuyerInfo(
      buyerProfileId: json['buyer_profile_id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '-',
      nikSnapshot: json['nik_snapshot']?.toString() ?? '-',
      verificationStatus: json['verification_status']?.toString() ?? '-',
      riskScore: (json['risk_score'] as num?)?.toDouble() ?? 0,
      isPinActive: json['is_pin_active'] as bool? ?? false,
    );
  }
}

class CashierVehicleInfo {
  const CashierVehicleInfo({
    required this.ownershipId,
    required this.vehicleId,
    required this.plateNumber,
    required this.registrationNumber,
    required this.typeLabel,
    required this.category,
    required this.ownershipStatus,
    required this.usageType,
    required this.brand,
    required this.vehicleType,
    required this.color,
    required this.manufactureYear,
    this.isEligible = false,
    this.quotaLiters = 0.0,
    this.usedLiters = 0.0,
    this.remainingLiters = 0.0,
  });

  final String ownershipId;
  final String vehicleId;
  final String plateNumber;
  final String registrationNumber;
  final String typeLabel;
  final String category;
  final String ownershipStatus;
  final String usageType;
  final String brand;
  final String vehicleType;
  final String color;
  final int? manufactureYear;
  final bool isEligible;
  final double quotaLiters;
  final double usedLiters;
  final double remainingLiters;

  String get vehicleDisplayType =>
      vehicleType.isNotEmpty ? vehicleType : typeLabel;

  factory CashierVehicleInfo.fromJson(Map<String, dynamic> json) {
    return CashierVehicleInfo(
      ownershipId: json['ownership_id']?.toString() ?? '',
      vehicleId: json['vehicle_id']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ?? '-',
      registrationNumber: json['registration_number']?.toString() ?? '-',
      typeLabel: json['type_label']?.toString() ?? '-',
      category: json['category']?.toString() ?? '-',
      ownershipStatus: json['ownership_status']?.toString() ?? '-',
      usageType: json['usage_type']?.toString() ?? '-',
      brand: json['brand']?.toString() ?? '-',
      vehicleType: json['vehicle_type']?.toString() ?? '-',
      color: json['color']?.toString() ?? '-',
      manufactureYear: json['manufacture_year'] as int?,
      isEligible: json['is_eligible'] as bool? ?? false,
      quotaLiters: (json['quota_liters'] as num?)?.toDouble() ?? 0.0,
      usedLiters: (json['used_liters'] as num?)?.toDouble() ?? 0.0,
      remainingLiters: (json['remaining_liters'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
