import 'package:flutter/material.dart';
import '../models/cashier_buyer_lookup.dart';
import '../models/mock_data.dart';
import '../theme/theme.dart';
import '../widgets/vehicle_card.dart';
import '../utils/privacy.dart';
import 'transaction_input_screen.dart';

class VehicleSelectionScreen extends StatelessWidget {
  const VehicleSelectionScreen({super.key, this.lookupResult});

  final CashierBuyerLookupResult? lookupResult;

  List<CashierVehicleInfo> _buildVehicles() {
    if (lookupResult != null) {
      return lookupResult!.vehicles;
    }

    return registeredVehicles
        .map(
          (vehicle) => CashierVehicleInfo(
            ownershipId: '',
            vehicleId: '',
            plateNumber: vehicle.plate,
            registrationNumber: '-',
            typeLabel: vehicle.type,
            category: vehicle.category,
            ownershipStatus: '-',
            usageType: '-',
            brand: vehicle.brand,
            vehicleType: vehicle.type,
            color: vehicle.color,
            manufactureYear: null,
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final buyerName = lookupResult?.buyer.name ?? currentUser.name;
    final buyerNik = lookupResult?.buyer.nikSnapshot ?? currentUser.nik;
    final vehicles = _buildVehicles();

    return Scaffold(
      appBar: AppBar(elevation: 0, backgroundColor: AppColors.background),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Informasi Pengguna',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    buyerName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'NIK: ${maskNik(buyerNik)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (lookupResult != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Status Verifikasi: ${lookupResult!.buyer.verificationStatus}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Kendaraan Terdaftar',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (vehicles.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Text(
                  'Belum ada kendaraan terdaftar untuk NFC ini.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ...vehicles.map(
              (vehicle) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: VehicleCard(
                  vehicle: vehicle,
                  onSelect: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionInputScreen(
                          vehicle: vehicle,
                          buyerName: buyerName,
                          buyerNik: buyerNik,
                          isPinActive: lookupResult?.buyer.isPinActive ?? false,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
