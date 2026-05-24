import 'package:flutter/material.dart';
import '../theme/theme.dart';

class ShiftScheduleScreen extends StatefulWidget {
  const ShiftScheduleScreen({super.key});

  @override
  State<ShiftScheduleScreen> createState() => _ShiftScheduleScreenState();
}

class _ShiftScheduleScreenState extends State<ShiftScheduleScreen> {
  bool _isOnBreak = false;

  void _toggleBreak() {
    setState(() {
      _isOnBreak = !_isOnBreak;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Jadwal Shift',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(19),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: _isOnBreak
                            ? AppColors.statusWarning
                            : AppColors.primary,
                        width: 6,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isOnBreak
                                  ? 'Sedang Istirahat'
                                  : 'Sedang Berlangsung',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: _isOnBreak
                                        ? AppColors.statusWarning
                                        : AppColors.statusSafe,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    (_isOnBreak
                                            ? AppColors.statusWarning
                                            : AppColors.statusSafe)
                                        .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _isOnBreak ? 'Istirahat' : 'Aktif',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: _isOnBreak
                                          ? AppColors.statusWarning
                                          : AppColors.statusSafe,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Shift: Pagi (06:00 - 14:00)',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Waktu Check-in: 05:45 WIB',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sisa Waktu Shift',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                Text(
                                  '2 Jam 15 Menit',
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value:
                                  0.72, // Roughly 5.75 hours elapsed out of 8
                              backgroundColor: AppColors.border,
                              color: AppColors.primary,
                              minHeight: 6,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _toggleBreak,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isOnBreak
                                  ? AppColors.statusSafe
                                  : AppColors.statusWarning,
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                            child: Text(
                              _isOnBreak
                                  ? 'Akhiri Istirahat'
                                  : 'Mulai Istirahat (15 Menit)',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Timeline Hari Ini',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const _TimelineItem(time: '05:45', title: 'Check In', isDone: true),
            const _TimelineItem(
              time: '06:00',
              title: 'Mulai Shift',
              isDone: true,
            ),
            _TimelineItem(
              time: '11:45',
              title: 'Istirahat / Sholat',
              isDone: _isOnBreak,
              isActive: _isOnBreak,
            ),
            const _TimelineItem(
              time: '14:00',
              title: 'Handover / Selesai Shift',
              isDone: false,
              isLast: true,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Permintaan Izin'),
                        content: const Text(
                          'Apakah Anda yakin ingin mengajukan izin keluar di luar jadwal istirahat?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Permintaan Izin Berhasil Dikirim ke Supervisor',
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                            ),
                            child: const Text('Kirim Izin'),
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: const Icon(Icons.logout_outlined, size: 20),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide(color: AppColors.border, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                label: const Text(
                  'Request Izin Keluar Khusus',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String time;
  final String title;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  const _TimelineItem({
    required this.time,
    required this.title,
    required this.isDone,
    this.isActive = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = isActive
        ? AppColors.statusWarning
        : (isDone ? AppColors.statusSafe : AppColors.border);
    final Color lineColor = isDone ? AppColors.statusSafe : AppColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : dotColor,
                border: isActive
                    ? Border.all(color: AppColors.statusWarning, width: 3)
                    : null,
                shape: BoxShape.circle,
              ),
            ),
            if (!isLast) Container(width: 2, height: 42, color: lineColor),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: isActive
                        ? AppColors.statusWarning
                        : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: isActive || isDone
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: isDone || isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
