class TransactionDraft {
  final String userName;
  final String userNik;
  final String plate;
  final String fuel;
  final String fuelTypeId;
  final double liters;
  final int total;
  final bool isPinActive;

  const TransactionDraft({
    required this.userName,
    required this.userNik,
    required this.plate,
    required this.fuel,
    required this.fuelTypeId,
    required this.liters,
    required this.total,
    required this.isPinActive,
  });
}
