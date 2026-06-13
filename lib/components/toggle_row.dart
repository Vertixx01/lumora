import 'package:flutter/material.dart';
import '../theme/colors.dart';

class ToggleRow extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool> onValueChange;
  final Widget? icon;

  const ToggleRow({
    Key? key,
    required this.label,
    this.description,
    required this.value,
    required this.onValueChange,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onValueChange(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch(
              value: value,
              onChanged: onValueChange,
              activeColor: AppColors.background,
              activeTrackColor: AppColors.accent,
              inactiveThumbColor: AppColors.textPrimary,
              inactiveTrackColor: AppColors.surfaceAlt,
              trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
            ),
          ],
        ),
      ),
    );
  }
}
