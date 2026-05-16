import 'package:flutter/material.dart';

class ScannerFrame extends StatelessWidget {
  final String helperText;
  final VoidCallback onSimulate;
  final String buttonLabel;

  const ScannerFrame({
    super.key,
    required this.helperText,
    required this.onSimulate,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF101214),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.7),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Text(
            helperText,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSimulate,
              child: Text(buttonLabel),
            ),
          ),
        ],
      ),
    );
  }
}
