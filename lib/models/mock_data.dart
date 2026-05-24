import 'package:flutter/material.dart';

class ScanMethodItem {
  final IconData icon;
  final String title;
  final String subtitle;

  const ScanMethodItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class RecentScanItem {
  final String name;
  final String nik;
  final String timeAgo;

  const RecentScanItem({
    required this.name,
    required this.nik,
    required this.timeAgo,
  });
}

class TransactionItem {
  final String id;
  final String status;
  final String date;
  final String userName;
  final String userNik;
  final String plate;
  final String fuel;
  final String liters;
  final String total;
  final String payment;
  final String cashier;

  const TransactionItem({
    required this.id,
    required this.status,
    required this.date,
    required this.userName,
    required this.userNik,
    required this.plate,
    required this.fuel,
    required this.liters,
    required this.total,
    required this.payment,
    required this.cashier,
  });
}

class PendingTransactionItem {
  final String id;
  final String time;
  final String name;
  final String plate;
  final String fuel;
  final String liters;
  final String total;

  const PendingTransactionItem({
    required this.id,
    required this.time,
    required this.name,
    required this.plate,
    required this.fuel,
    required this.liters,
    required this.total,
  });
}

class ProfileInfo {
  final String name;
  final String role;
  final String id;
  final String station;
  final String joined;

  const ProfileInfo({
    required this.name,
    required this.role,
    required this.id,
    required this.station,
    required this.joined,
  });
}

class StatItem {
  final String label;
  final String value;
  final bool highlight;

  const StatItem({
    required this.label,
    required this.value,
    this.highlight = false,
  });
}

class UserInfo {
  final String name;
  final String nik;

  const UserInfo({required this.name, required this.nik});
}

class VehicleItem {
  final String plate;
  final String type;
  final String category;
  final String brand;
  final String color;

  const VehicleItem({
    required this.plate,
    required this.type,
    required this.category,
    required this.brand,
    required this.color,
  });
}

const List<ScanMethodItem> scanMethods = [
  ScanMethodItem(
    icon: Icons.qr_code_scanner_outlined,
    title: 'Scan QR Pengguna',
    subtitle: 'Scan kode QR dari aplikasi pengguna',
  ),
  ScanMethodItem(
    icon: Icons.perm_identity_outlined,
    title: 'Scan E-KTP',
    subtitle: 'Gunakan kamera dan NFC untuk E-KTP',
  ),
  ScanMethodItem(
    icon: Icons.keyboard_outlined,
    title: 'Input NIK Manual',
    subtitle: 'Ketik NIK secara manual',
  ),
];

const List<RecentScanItem> recentScans = [
  RecentScanItem(
    name: 'Budi Santoso',
    nik: '32012 4501 1234 0001',
    timeAgo: '5 menit lalu',
  ),
  RecentScanItem(
    name: 'Siti Lestari',
    nik: '32012 4501 1234 0002',
    timeAgo: '12 menit lalu',
  ),
  RecentScanItem(
    name: 'Rizky Pratama',
    nik: '32012 4501 1234 0003',
    timeAgo: '18 menit lalu',
  ),
];

const List<TransactionItem> transactions = [
  TransactionItem(
    id: 'TRX-20240515-001',
    status: 'Berhasil',
    date: '15 Mei 2026, 10:24',
    userName: 'Budi Santoso',
    userNik: '32012 4501 1234 0001',
    plate: 'B 1234 KAT',
    fuel: 'Pertalite',
    liters: '20 Liter',
    total: 'Rp 153.000',
    payment: 'E-Wallet KTP',
    cashier: 'Andi Wijaya',
  ),
  TransactionItem(
    id: 'TRX-20240515-002',
    status: 'Berhasil',
    date: '15 Mei 2026, 10:12',
    userName: 'Siti Lestari',
    userNik: '32012 4501 1234 0002',
    plate: 'D 9087 AU',
    fuel: 'Pertalite',
    liters: '15 Liter',
    total: 'Rp 114.750',
    payment: 'E-Wallet KTP',
    cashier: 'Andi Wijaya',
  ),
  TransactionItem(
    id: 'TRX-20240515-003',
    status: 'Pending',
    date: '15 Mei 2026, 09:58',
    userName: 'Rizky Pratama',
    userNik: '32012 4501 1234 0003',
    plate: 'B 7712 TY',
    fuel: 'Pertalite',
    liters: '10 Liter',
    total: 'Rp 76.500',
    payment: 'E-Wallet KTP',
    cashier: 'Andi Wijaya',
  ),
  TransactionItem(
    id: 'TRX-20240515-004',
    status: 'Berhasil',
    date: '15 Mei 2026, 09:45',
    userName: 'Dewi Anggraeni',
    userNik: '32012 4501 1234 0004',
    plate: 'F 5621 KI',
    fuel: 'Pertamax',
    liters: '18 Liter',
    total: 'Rp 198.000',
    payment: 'E-Wallet KTP',
    cashier: 'Andi Wijaya',
  ),
  TransactionItem(
    id: 'TRX-20240515-005',
    status: 'Gagal',
    date: '15 Mei 2026, 09:20',
    userName: 'Hendra Wijaya',
    userNik: '32012 4501 1234 0005',
    plate: 'B 4432 VP',
    fuel: 'Pertalite',
    liters: '12 Liter',
    total: 'Rp 91.800',
    payment: 'E-Wallet KTP',
    cashier: 'Andi Wijaya',
  ),
  TransactionItem(
    id: 'TRX-20240515-006',
    status: 'Berhasil',
    date: '15 Mei 2026, 09:05',
    userName: 'Maya Kartika',
    userNik: '32012 4501 1234 0006',
    plate: 'B 9911 SQ',
    fuel: 'Pertalite',
    liters: '22 Liter',
    total: 'Rp 168.300',
    payment: 'E-Wallet KTP',
    cashier: 'Andi Wijaya',
  ),
];

const List<PendingTransactionItem> pendingTransactions = [
  PendingTransactionItem(
    id: 'TRX-20240515-019',
    time: '10:30',
    name: 'Rudi Hartono',
    plate: 'B 3321 PQ',
    fuel: 'Pertalite',
    liters: '12 Liter',
    total: 'Rp 91.800',
  ),
  PendingTransactionItem(
    id: 'TRX-20240515-020',
    time: '10:22',
    name: 'Yulia Ambar',
    plate: 'D 1982 UA',
    fuel: 'Pertamax',
    liters: '15 Liter',
    total: 'Rp 165.000',
  ),
  PendingTransactionItem(
    id: 'TRX-20240515-021',
    time: '10:15',
    name: 'Agus Prabowo',
    plate: 'B 8211 KT',
    fuel: 'Pertalite',
    liters: '10 Liter',
    total: 'Rp 76.500',
  ),
];

const ProfileInfo profileInfo = ProfileInfo(
  name: 'Andi Wijaya',
  role: 'Kasir Senior',
  id: 'SPBU-2024-001',
  station: 'SPBU Pertamina 44.501.15',
  joined: 'Bergabung sejak 15 Jan 2022',
);

const List<StatItem> dailyStats = [
  StatItem(label: 'Transaksi', value: '47'),
  StatItem(label: 'Pendapatan', value: 'Rp 3.3 jt', highlight: true),
  StatItem(label: 'Total Liter', value: '425 L'),
  StatItem(label: 'Rata-rata Waktu', value: '3.5 menit'),
];

const UserInfo currentUser = UserInfo(
  name: 'Budi Santoso',
  nik: '320123 4501 1234 0001',
);

const List<VehicleItem> registeredVehicles = [
  VehicleItem(
    plate: 'B 1234 XYZ',
    type: 'Mobil',
    category: 'Non-Commercial',
    brand: 'Toyota Avanza',
    color: 'Silver',
  ),
  VehicleItem(
    plate: 'B 8812 HZ',
    type: 'Motor',
    category: 'Non-Commercial',
    brand: 'Honda Vario',
    color: 'Hitam',
  ),
];

const int remainingQuotaLiters = 120;
