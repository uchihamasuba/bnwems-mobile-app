import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? backgroundColor;

  const StatusChip({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    Color chipColor = AppColors.textSecondary;
    Color chipBg = AppColors.divider.withOpacity(0.5);

    // Map common states if color is not specified
    final normalized = label.toLowerCase().trim();
    if (color == null || backgroundColor == null) {
      if (normalized.contains('chờ') ||
          normalized.contains('pending') ||
          normalized.contains('yêu cầu') ||
          normalized.contains('chưa')) {
        chipColor = AppColors.warning;
        chipBg = AppColors.warningLight;
      } else if (normalized.contains('hoàn thành') ||
          normalized.contains('đã cọc') ||
          normalized.contains('đã thanh toán') ||
          normalized.contains('complete') ||
          normalized.contains('approved') ||
          normalized.contains('phê duyệt') ||
          normalized.contains('đã giao') ||
          normalized.contains('available') ||
          normalized.contains('đã đóng')) {
        chipColor = AppColors.success;
        chipBg = AppColors.successLight;
      } else if (normalized.contains('đang') ||
          normalized.contains('processing') ||
          normalized.contains('thi công') ||
          normalized.contains('khảo sát')) {
        chipColor = AppColors.info;
        chipBg = AppColors.infoLight;
      } else if (normalized.contains('hủy') ||
          normalized.contains('hỏng') ||
          normalized.contains('mất') ||
          normalized.contains('lost') ||
          normalized.contains('damaged') ||
          normalized.contains('vi phạm')) {
        chipColor = AppColors.error;
        chipBg = AppColors.errorLight;
      } else if (normalized.contains('cần cọc') ||
          normalized.contains('nháp') ||
          normalized.contains('draft') ||
          normalized.contains('chờ cọc')) {
        chipColor = AppColors.secondary;
        chipBg = AppColors.primaryLight;
      }
    } else {
      chipColor = color!;
      chipBg = backgroundColor!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
