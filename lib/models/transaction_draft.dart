import 'dart:math' as math;

class FuelPricingBreakdown {
  const FuelPricingBreakdown({
    required this.liters,
    required this.totalAmount,
    required this.subsidizedLiters,
    required this.nonSubsidizedLiters,
    required this.marketPricePerLiter,
    required this.subsidizedPricePerLiter,
    required this.isSubsidizedFuel,
    required this.isEligibleForSubsidy,
  });

  final double liters;
  final int totalAmount;
  final double subsidizedLiters;
  final double nonSubsidizedLiters;
  final double marketPricePerLiter;
  final double? subsidizedPricePerLiter;
  final bool isSubsidizedFuel;
  final bool isEligibleForSubsidy;

  bool get usesSubsidy => subsidizedLiters > 0;
  bool get usesMixedPricing => subsidizedLiters > 0 && nonSubsidizedLiters > 0;
  bool get usesMarketPriceOnly =>
      nonSubsidizedLiters > 0 && subsidizedLiters == 0;

  static FuelPricingBreakdown fromLiters({
    required double liters,
    required double marketPricePerLiter,
    required double? subsidizedPricePerLiter,
    required bool isSubsidizedFuel,
    required bool isEligibleForSubsidy,
    required double remainingQuota,
  }) {
    final normalizedLiters = liters < 0 ? 0.0 : liters;
    final normalizedQuota = remainingQuota < 0 ? 0.0 : remainingQuota;
    final canUseSubsidy =
        isSubsidizedFuel &&
        isEligibleForSubsidy &&
        subsidizedPricePerLiter != null &&
        normalizedQuota > 0;

    final subsidizedLiters = canUseSubsidy
        ? math.min(normalizedLiters, normalizedQuota)
        : 0.0;
    final nonSubsidizedLiters = math.max(
      0.0,
      normalizedLiters - subsidizedLiters,
    );
    final totalAmount =
        (subsidizedLiters * (subsidizedPricePerLiter ?? 0) +
                nonSubsidizedLiters * marketPricePerLiter)
            .round();

    return FuelPricingBreakdown(
      liters: normalizedLiters,
      totalAmount: totalAmount,
      subsidizedLiters: subsidizedLiters,
      nonSubsidizedLiters: nonSubsidizedLiters,
      marketPricePerLiter: marketPricePerLiter,
      subsidizedPricePerLiter: subsidizedPricePerLiter,
      isSubsidizedFuel: isSubsidizedFuel,
      isEligibleForSubsidy: isEligibleForSubsidy,
    );
  }

  static FuelPricingBreakdown fromAmount({
    required int amount,
    required double marketPricePerLiter,
    required double? subsidizedPricePerLiter,
    required bool isSubsidizedFuel,
    required bool isEligibleForSubsidy,
    required double remainingQuota,
  }) {
    final normalizedAmount = amount < 0 ? 0 : amount;
    final normalizedQuota = remainingQuota < 0 ? 0.0 : remainingQuota;
    final canUseSubsidy =
        isSubsidizedFuel &&
        isEligibleForSubsidy &&
        subsidizedPricePerLiter != null &&
        normalizedQuota > 0;

    if (!canUseSubsidy) {
      final liters = normalizedAmount <= 0
          ? 0.0
          : normalizedAmount / marketPricePerLiter;
      return FuelPricingBreakdown(
        liters: liters,
        totalAmount: normalizedAmount,
        subsidizedLiters: 0.0,
        nonSubsidizedLiters: liters,
        marketPricePerLiter: marketPricePerLiter,
        subsidizedPricePerLiter: subsidizedPricePerLiter,
        isSubsidizedFuel: isSubsidizedFuel,
        isEligibleForSubsidy: isEligibleForSubsidy,
      );
    }

    final subsidyUnitPrice = subsidizedPricePerLiter!;
    final subsidyCeilingAmount = normalizedQuota * subsidyUnitPrice;
    final subsidizedAmount = math.min(
      normalizedAmount.toDouble(),
      subsidyCeilingAmount,
    );
    final remainingAmount = math.max(
      0.0,
      normalizedAmount.toDouble() - subsidizedAmount,
    );
    final subsidizedLiters = subsidizedAmount / subsidyUnitPrice;
    final nonSubsidizedLiters = remainingAmount / marketPricePerLiter;

    return FuelPricingBreakdown(
      liters: subsidizedLiters + nonSubsidizedLiters,
      totalAmount: normalizedAmount,
      subsidizedLiters: subsidizedLiters,
      nonSubsidizedLiters: nonSubsidizedLiters,
      marketPricePerLiter: marketPricePerLiter,
      subsidizedPricePerLiter: subsidizedPricePerLiter,
      isSubsidizedFuel: isSubsidizedFuel,
      isEligibleForSubsidy: isEligibleForSubsidy,
    );
  }
}

class TransactionDraft {
  final String userName;
  final String userNik;
  final String plate;
  final String fuel;
  final String fuelTypeId;
  final double liters;
  final int total;
  final bool isPinActive;
  final FuelPricingBreakdown pricingBreakdown;

  const TransactionDraft({
    required this.userName,
    required this.userNik,
    required this.plate,
    required this.fuel,
    required this.fuelTypeId,
    required this.liters,
    required this.total,
    required this.isPinActive,
    required this.pricingBreakdown,
  });
}
