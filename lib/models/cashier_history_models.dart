String formatCashierDate(DateTime value) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final localValue = value.toLocal();
  final day = localValue.day.toString().padLeft(2, '0');
  final month = months[localValue.month - 1];
  final year = localValue.year;
  final hour = localValue.hour.toString().padLeft(2, '0');
  final minute = localValue.minute.toString().padLeft(2, '0');
  return '$day $month $year, $hour:$minute';
}

String formatCurrencyValue(num value) {
  final rounded = value.round();
  final buffer = StringBuffer();
  final digits = rounded.abs().toString();
  for (var i = 0; i < digits.length; i++) {
    final remaining = digits.length - i;
    buffer.write(digits[i]);
    if (remaining > 1 && (remaining - 1) % 3 == 0) {
      buffer.write('.');
    }
  }
  final prefix = rounded < 0 ? '-' : '';
  return 'Rp $prefix${buffer.toString()}';
}

String formatCompactCurrencyValue(num value) {
  final absolute = value.abs().toDouble();
  final prefix = value < 0 ? '-Rp ' : 'Rp ';
  if (absolute >= 1000000) {
    return '$prefix${(absolute / 1000000).toStringAsFixed(absolute >= 10000000 ? 0 : 1)} jt';
  }
  if (absolute >= 1000) {
    return '$prefix${(absolute / 1000).toStringAsFixed(absolute >= 100000 ? 0 : 1)} rb';
  }
  return '$prefix${absolute.round()}';
}

String formatLitersValue(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
}

class CashierTransactionSummary {
  const CashierTransactionSummary({
    required this.totalTransactions,
    required this.completedTransactions,
    required this.failedTransactions,
    required this.pendingTransactions,
    required this.totalLiters,
    required this.totalRevenue,
  });

  final int totalTransactions;
  final int completedTransactions;
  final int failedTransactions;
  final int pendingTransactions;
  final double totalLiters;
  final double totalRevenue;

  factory CashierTransactionSummary.fromJson(Map<String, dynamic> json) {
    return CashierTransactionSummary(
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      completedTransactions:
          (json['completed_transactions'] as num?)?.toInt() ?? 0,
      failedTransactions: (json['failed_transactions'] as num?)?.toInt() ?? 0,
      pendingTransactions: (json['pending_transactions'] as num?)?.toInt() ?? 0,
      totalLiters: (json['total_liters'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
    );
  }

  String get totalRevenueLabel => formatCurrencyValue(totalRevenue);
  String get totalLitersLabel =>
      '${totalLiters.toStringAsFixed(totalLiters.truncateToDouble() == totalLiters ? 0 : 2)} L';
}

class CashierTransactionItem {
  const CashierTransactionItem({
    required this.id,
    required this.status,
    required this.date,
    required this.occurredAt,
    required this.userName,
    required this.userNik,
    required this.plate,
    required this.fuel,
    required this.liters,
    required this.total,
    required this.payment,
    required this.cashier,
    this.buyerFotoKtpUrl,
  });

  final String id;
  final String status;
  final String date;
  final DateTime occurredAt;
  final String userName;
  final String userNik;
  final String plate;
  final String fuel;
  final String liters;
  final String total;
  final String payment;
  final String cashier;
  final String? buyerFotoKtpUrl;

  factory CashierTransactionItem.fromJson(Map<String, dynamic> json) {
    final statusRaw = (json['transaction_status'] ?? json['status'] ?? '')
        .toString()
        .toUpperCase();
    final statusLabel = switch (statusRaw) {
      'COMPLETED' => 'Berhasil',
      'FAILED' || 'CANCELLED' => 'Gagal',
      'PENDING' => 'Pending',
      _ => statusRaw.isEmpty ? '-' : statusRaw,
    };
    final occurredAt =
        DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
        DateTime.now();
    final buyerName = json['buyer_name']?.toString().trim();
    final buyerNik = json['nik_snapshot']?.toString().trim();
    final maskedNik = buyerNik == null || buyerNik.isEmpty ? '-' : buyerNik;
    final litersValue = (json['liters'] as num?)?.toDouble() ?? 0.0;
    final totalValue = (json['total_amount'] as num?)?.toDouble() ?? 0.0;

    return CashierTransactionItem(
      id: json['id']?.toString() ?? '-',
      status: statusLabel,
      date: formatCashierDate(occurredAt),
      occurredAt: occurredAt,
      userName: buyerName == null || buyerName.isEmpty ? '-' : buyerName,
      userNik: maskedNik,
      plate: json['plate_number_snapshot']?.toString() ?? '-',
      fuel: json['fuel_name']?.toString() ?? '-',
      liters:
          '${litersValue.toStringAsFixed(litersValue.truncateToDouble() == litersValue ? 0 : 2)} Liter',
      total: formatCurrencyValue(totalValue),
      payment: json['payment_method']?.toString() ?? '-',
      cashier: json['cashier_name']?.toString() ?? '-',
      buyerFotoKtpUrl: json['buyer_foto_ktp_url']?.toString(),
    );
  }
}

class CashierTransactionPage {
  const CashierTransactionPage({
    required this.items,
    required this.summary,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<CashierTransactionItem> items;
  final CashierTransactionSummary? summary;
  final String? nextCursor;
  final bool hasMore;

  factory CashierTransactionPage.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const <dynamic>[];
    final summaryJson = json['summary'] as Map<String, dynamic>?;
    return CashierTransactionPage(
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(CashierTransactionItem.fromJson)
          .toList(),
      summary: summaryJson == null
          ? null
          : CashierTransactionSummary.fromJson(summaryJson),
      nextCursor: json['next_cursor']?.toString(),
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}

class CashierRecentScanItem {
  const CashierRecentScanItem({
    required this.id,
    required this.name,
    required this.nikMasked,
    required this.timeLabel,
    required this.method,
    required this.status,
    required this.result,
    this.errorMessage,
  });

  final String id;
  final String name;
  final String nikMasked;
  final String timeLabel;
  final String method;
  final String status;
  final String result;
  final String? errorMessage;

  factory CashierRecentScanItem.fromJson(Map<String, dynamic> json) {
    final occurredAt =
        DateTime.tryParse(json['created_at']?.toString() ?? '')?.toLocal() ??
        DateTime.now();
    final methodRaw = json['lookup_method']?.toString().toUpperCase() ?? '-';
    final resultRaw = json['result']?.toString().toUpperCase() ?? 'FAILED';
    final name = json['buyer_name']?.toString();
    final nikMasked = json['nik_masked']?.toString();
    return CashierRecentScanItem(
      id: json['id']?.toString() ?? '-',
      name: (name == null || name.isEmpty) ? 'Tidak ditemukan' : name,
      nikMasked: (nikMasked == null || nikMasked.isEmpty) ? '-' : nikMasked,
      timeLabel: formatCashierDate(occurredAt),
      method: methodRaw,
      status: resultRaw == 'SUCCESS' ? 'Berhasil' : 'Gagal',
      result: resultRaw,
      errorMessage: json['error_message']?.toString(),
    );
  }
}

class CashierRecentScanPage {
  const CashierRecentScanPage({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
  });

  final List<CashierRecentScanItem> items;
  final String? nextCursor;
  final bool hasMore;

  factory CashierRecentScanPage.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const <dynamic>[];
    return CashierRecentScanPage(
      items: itemsJson
          .whereType<Map<String, dynamic>>()
          .map(CashierRecentScanItem.fromJson)
          .toList(),
      nextCursor: json['next_cursor']?.toString(),
      hasMore: json['has_more'] as bool? ?? false,
    );
  }
}

class CashierPerformanceSummary {
  const CashierPerformanceSummary({
    required this.totalTransactions,
    required this.completedTransactions,
    required this.failedTransactions,
    required this.cancelledTransactions,
    required this.pendingTransactions,
    required this.servedVehicles,
    required this.totalLiters,
    required this.totalRevenue,
    required this.averageTransactionMinutes,
  });

  final int totalTransactions;
  final int completedTransactions;
  final int failedTransactions;
  final int cancelledTransactions;
  final int pendingTransactions;
  final int servedVehicles;
  final double totalLiters;
  final double totalRevenue;
  final double? averageTransactionMinutes;

  factory CashierPerformanceSummary.fromJson(Map<String, dynamic> json) {
    return CashierPerformanceSummary(
      totalTransactions: (json['total_transactions'] as num?)?.toInt() ?? 0,
      completedTransactions:
          (json['completed_transactions'] as num?)?.toInt() ?? 0,
      failedTransactions: (json['failed_transactions'] as num?)?.toInt() ?? 0,
      cancelledTransactions:
          (json['cancelled_transactions'] as num?)?.toInt() ?? 0,
      pendingTransactions: (json['pending_transactions'] as num?)?.toInt() ?? 0,
      servedVehicles: (json['served_vehicles'] as num?)?.toInt() ?? 0,
      totalLiters: (json['total_liters'] as num?)?.toDouble() ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      averageTransactionMinutes: (json['average_transaction_minutes'] as num?)
          ?.toDouble(),
    );
  }

  int get failedOrRejectedTransactions =>
      failedTransactions + cancelledTransactions;

  String get totalRevenueLabel => formatCurrencyValue(totalRevenue);

  String get totalRevenueCompactLabel =>
      formatCompactCurrencyValue(totalRevenue);

  String get totalLitersLabel => '${formatLitersValue(totalLiters)} Liter';

  String get totalLitersCompactLabel => '${formatLitersValue(totalLiters)} L';

  String get averageTransactionLabel {
    final value = averageTransactionMinutes;
    if (value == null) {
      return '-';
    }
    return '${formatLitersValue(value)} Menit';
  }
}

class CashierPerformanceSnapshot {
  const CashierPerformanceSnapshot({
    required this.summary,
    required this.recentTransactions,
  });

  final CashierPerformanceSummary summary;
  final List<CashierTransactionItem> recentTransactions;

  factory CashierPerformanceSnapshot.fromJson(Map<String, dynamic> json) {
    final summaryJson = json['summary'] as Map<String, dynamic>? ?? const {};
    final recentJson =
        json['recent_transactions'] as List<dynamic>? ?? const <dynamic>[];
    return CashierPerformanceSnapshot(
      summary: CashierPerformanceSummary.fromJson(summaryJson),
      recentTransactions: recentJson
          .whereType<Map<String, dynamic>>()
          .map(CashierTransactionItem.fromJson)
          .toList(),
    );
  }
}
