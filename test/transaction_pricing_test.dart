import 'package:flutter_test/flutter_test.dart';
import 'package:subsidia_cashier/models/transaction_draft.dart';

void main() {
  group('FuelPricingBreakdown', () {
    test('uses market price when buyer is not eligible', () {
      final pricing = FuelPricingBreakdown.fromLiters(
        liters: 10,
        marketPricePerLiter: 10000,
        subsidizedPricePerLiter: 6500,
        isSubsidizedFuel: true,
        isEligibleForSubsidy: false,
        remainingQuota: 20,
      );

      expect(pricing.subsidizedLiters, 0);
      expect(pricing.nonSubsidizedLiters, 10);
      expect(pricing.totalAmount, 100000);
    });

    test('splits liters when remaining quota is smaller than purchase', () {
      final pricing = FuelPricingBreakdown.fromLiters(
        liters: 50,
        marketPricePerLiter: 10000,
        subsidizedPricePerLiter: 6500,
        isSubsidizedFuel: true,
        isEligibleForSubsidy: true,
        remainingQuota: 20,
      );

      expect(pricing.subsidizedLiters, 20);
      expect(pricing.nonSubsidizedLiters, 30);
      expect(pricing.totalAmount, 430000);
      expect(pricing.usesMixedPricing, isTrue);
    });

    test('consumes subsidy first when cashier inputs amount', () {
      final pricing = FuelPricingBreakdown.fromAmount(
        amount: 430000,
        marketPricePerLiter: 10000,
        subsidizedPricePerLiter: 6500,
        isSubsidizedFuel: true,
        isEligibleForSubsidy: true,
        remainingQuota: 20,
      );

      expect(pricing.subsidizedLiters, closeTo(20, 0.0001));
      expect(pricing.nonSubsidizedLiters, closeTo(30, 0.0001));
      expect(pricing.liters, closeTo(50, 0.0001));
      expect(pricing.totalAmount, 430000);
    });
  });
}
