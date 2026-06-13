import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum StatCardAccentColor { accent, success, warning }

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sublabel;
  final Widget? icon;
  final StatCardAccentColor accentColor;

  const StatCard({
    Key? key,
    required this.label,
    required this.value,
    this.sublabel,
    this.icon,
    this.accentColor = StatCardAccentColor.accent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color valueColor;
    switch (accentColor) {
      case StatCardAccentColor.accent:
        valueColor = AppColors.accent;
        break;
      case StatCardAccentColor.success:
        valueColor = AppColors.success;
        break;
      case StatCardAccentColor.warning:
        valueColor = AppColors.warning;
        break;
    }

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                SizedBox(width: 20, height: 20, child: Center(child: icon)),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
            ),
          ),
          if (sublabel != null) ...[
            const SizedBox(height: 4),
            Text(
              sublabel!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
