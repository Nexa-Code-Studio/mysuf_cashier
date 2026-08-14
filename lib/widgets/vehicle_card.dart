import 'package:flutter/material.dart';
import '../models/cashier_buyer_lookup.dart';
import '../theme/theme.dart';

class VehicleCard extends StatelessWidget {
  final CashierVehicleInfo vehicle;
  final VoidCallback? onSelect;

  const VehicleCard({super.key, required this.vehicle, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  vehicle.vehicleDisplayType.toLowerCase().contains('vario') ||
                          vehicle.vehicleDisplayType.toLowerCase().contains(
                            'nmax',
                          ) ||
                          vehicle.vehicleDisplayType.toLowerCase().contains(
                            'motor',
                          )
                      ? Icons.motorcycle_rounded
                      : Icons.directions_car_rounded,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!vehicle.isPersonal) ...[
                      Text(
                        vehicle.plateNumber,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vehicle.vehicleDisplayType,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ] else ...[
                      Text(
                        vehicle.vehicleDisplayType,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Kategori: ${vehicle.category}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Merek: ${vehicle.brand}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'Warna: ${vehicle.color}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            'No. STNK: ${vehicle.registrationNumber}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSelect,
              child: const Text('Pilih Kendaraan'),
            ),
          ),
        ],
      ),
    );
  }
}
