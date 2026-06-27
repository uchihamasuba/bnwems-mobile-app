import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_section_header.dart';

class ManagerProgressScreen extends StatelessWidget {
  const ManagerProgressScreen({super.key});

  static const List<String> _steps = [
    'Check-out',
    'Transportation',
    'Installation',
    'Handover',
    'Collection',
    'Warehouse Return',
    'Completed',
  ];

  @override
  Widget build(BuildContext context) {
    final orders = MockData.orders;
    final activeCount = orders
        .where((o) => o.fieldProgressStatus != 'Completed')
        .length;
    final delayedCount = orders.where((o) => o.hasEmergency).length;
    final doneCount = orders
        .where((o) => o.fieldProgressStatus == 'Completed')
        .length;

    return AppScaffold(
      useSafeArea: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          ManagerAppHeader(
            title: 'Tiến độ hiện trường',
            subtitle:
                'Theo dõi các bước vận hành, phát hiện điểm nghẽn và xử lý nhanh khi cần.',
            trailing: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.timeline_rounded,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.l),
          Row(
            children: [
              Expanded(
                child: _KpiCard(
                  label: 'Đang thi công',
                  value: '$activeCount',
                  color: AppColors.info,
                ),
              ),
              const SizedBox(width: AppSizes.s),
              Expanded(
                child: _KpiCard(
                  label: 'Trễ tiến độ',
                  value: '$delayedCount',
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: AppSizes.s),
              Expanded(
                child: _KpiCard(
                  label: 'Hoàn thành',
                  value: '$doneCount',
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.l),
          const ManagerSectionHeader(
            title: 'Danh sách đang theo dõi',
            subtitle: 'Mỗi đơn hàng hiển thị bước hiện tại và mức độ rủi ro.',
          ),
          const SizedBox(height: AppSizes.m),
          if (orders.isEmpty)
            const SizedBox(
              height: 260,
              child: EmptyState(
                title: 'Chưa có tiến độ hiện trường',
                description: 'Khi có đơn hàng vận hành, bạn sẽ thấy timeline tại đây.',
                icon: Icons.timeline_rounded,
              ),
            )
          else
            ...orders.map(
              (order) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.m),
                child: _ProgressCard(order: order),
              ),
            ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      color: color.withOpacity(0.08),
      borderColor: color.withOpacity(0.16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.order});

  final MobileOrder order;

  static const List<String> _steps = ManagerProgressScreen._steps;

  @override
  Widget build(BuildContext context) {
    final currentIndex = _steps.indexOf(order.fieldProgressStatus);
    final progressValue = currentIndex < 0 ? 0.12 : (currentIndex + 1) / _steps.length;
    final accent = order.hasEmergency ? AppColors.error : AppColors.info;

    return InfoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.managerFieldProgress,
        arguments: order.id,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.id,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.customerName,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(label: order.fieldProgressStatus),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressValue.clamp(0.0, 1.0),
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            backgroundColor: AppColors.primaryLight,
            color: accent,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bước hiện tại: ${order.fieldProgressStatus}',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(progressValue * 100).round()}%',
                style: TextStyle(
                  color: accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.location,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          if (order.urgencyMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              ),
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
        ],
      ),
    );
  }
}
