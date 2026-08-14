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
    final buyer = lookupResult?.buyer;
    final isRestricted = buyer?.isAccountRestricted ?? false;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Pilih Kendaraan',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
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

            // ── Frozen / Blocked Warning Banner ──────────────────────────
            if (isRestricted) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEEEE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE53935), width: 1.5),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.block_rounded,
                      color: Color(0xFFE53935),
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            buyer!.isBlocked
                                ? 'Akun Diblokir Permanen'
                                : 'Akun Dibekukan Sementara',
                            style: const TextStyle(
                              color: Color(0xFFB71C1C),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            buyer.isBlocked
                                ? 'Akun pembeli ini telah diblokir permanen oleh sistem keamanan karena terdeteksi aktivitas fraud. Transaksi BBM subsidi tidak dapat dilanjutkan.'
                                : 'Akun pembeli ini sedang dibekukan sementara karena terdeteksi pola pembelian mencurigakan. '
                                  '${buyer.frozenUntil != null ? "Dibekukan hingga: ${buyer.frozenUntil}" : ""}'
                                  '\nTransaksi BBM subsidi tidak dapat dilanjutkan.',
                            style: const TextStyle(
                              color: Color(0xFFC62828),
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            // ─────────────────────────────────────────────────────────────

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
                child: Opacity(
                  opacity: isRestricted ? 0.45 : 1.0,
                  child: VehicleCard(
                    vehicle: vehicle,
                    onSelect: isRestricted
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionInputScreen(
                                  vehicle: vehicle,
                                  buyerName: buyerName,
                                  buyerNik: buyerNik,
                                  isPinActive:
                                      lookupResult?.buyer.isPinActive ?? false,
                                  buyer: lookupResult?.buyer,
                                ),
                              ),
                            );
                          },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

