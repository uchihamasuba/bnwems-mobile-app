import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../shared/models/core_models.dart';
import 'manager_priority_badge.dart';

class ManagerTaskCard extends StatelessWidget {
  const ManagerTaskCard({
    super.key,
    required this.order,
    required this.onTap,
  });

  final MobileOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasUrgency =
        order.urgencyMessage != null && order.urgencyMessage!.isNotEmpty;
    final priorityLabel = hasUrgency ? 'Khẩn cấp' : 'Đang xử lý';
    final accentColor = hasUrgency ? AppColors.error : AppColors.info;

    return InfoCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 6,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusLarge),
                  bottomLeft: Radius.circular(AppSizes.radiusLarge),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.m),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            order.id,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: ManagerPriorityBadge(
                                label: priorityLabel,
                                compact: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _MetaRow(
                      icon: Icons.location_on_outlined,
                      text: order.location,
                    ),
                    const SizedBox(height: 6),
                    _MetaRow(
                      icon: Icons.schedule_rounded,
                      text:
                          '${order.eventDateTime.hour.toString().padLeft(2, '0')}:${order.eventDateTime.minute.toString().padLeft(2, '0')} • ${order.eventDateTime.day}/${order.eventDateTime.month}/${order.eventDateTime.year}',
                    ),
                    const SizedBox(height: 6),
                    _MetaRow(
                      icon: Icons.badge_outlined,
                      text: 'Phụ trách: ${order.leaderStaffName}',
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        StatusChip(label: order.orderStatus.displayName),
                        StatusChip(label: order.fieldProgressStatus),
                      ],
                    ),
                    if (hasUrgency) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusMedium,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.error,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.urgencyMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    const Row(
                      children: [
                        Text(
                          'Xem chi tiết',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
