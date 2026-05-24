import 'package:flutter/material.dart';
import '../theme/theme.dart';

class PosAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Future<void> Function() onLogout;

  const PosAppBar({super.key, required this.onLogout});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.background,
      titleSpacing: 16,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.wifi_rounded, color: AppColors.statusSafe, size: 18),
          const SizedBox(width: 8),
          Text(
            'Online',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.statusSafe,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            onLogout();
          },
          tooltip: 'Logout',
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
    );
  }
}
