import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/info_card.dart';

class ManagerStatisticCard extends StatelessWidget {
  const ManagerStatisticCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.highlight = false,
    this.compact = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool highlight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      color: highlight ? color.withOpacity(0.08) : Colors.white,
      borderColor: highlight ? color.withOpacity(0.28) : AppColors.divider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 34 : 38,
                height: compact ? 34 : 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: compact ? 18 : 20),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: highlight ? color.withOpacity(0.14) : AppColors.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  compact ? 'Mục' : (highlight ? 'Ưu tiên' : 'Tổng quan'),
                  style: TextStyle(
                    color: highlight ? color : AppColors.textSecondary,
                    fontSize: compact ? 9 : 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 10 : AppSizes.m),
          Text(
            value,
            style: TextStyle(
              fontSize: compact ? 24 : 28,
              fontWeight: FontWeight.w800,
              color: highlight ? color : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 11 : 12,
              height: 1.3,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
