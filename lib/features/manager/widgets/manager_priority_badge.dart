import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';

class ManagerPriorityBadge extends StatelessWidget {
  const ManagerPriorityBadge({
    super.key,
    required this.label,
    this.compact = false,
  });

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final normalized = label.toLowerCase();
    Color color = AppColors.info;
    Color background = AppColors.infoLight;
    IconData icon = Icons.bolt_rounded;

    if (normalized.contains('high') || normalized.contains('khẩn')) {
      color = AppColors.error;
      background = AppColors.errorLight;
      icon = Icons.priority_high_rounded;
    } else if (normalized.contains('medium') || normalized.contains('xử lý')) {
      color = AppColors.warning;
      background = AppColors.warningLight;
      icon = Icons.timelapse_rounded;
    } else if (normalized.contains('low') || normalized.contains('hoàn thành')) {
      color = AppColors.success;
      background = AppColors.successLight;
      icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 12 : 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 10 : 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
