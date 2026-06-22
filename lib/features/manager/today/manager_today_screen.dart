import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';

class ManagerTodayScreen extends StatelessWidget {
  const ManagerTodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final list = MockData.orders;

    return AppScaffold(
      useSafeArea: true,
      appBar: const CustomAppBar(
        title: 'Đơn hàng Hôm nay & Tiến độ',
        showBackButton: false,
      ),
      body: list.isEmpty
          ? const Center(child: Text('Hôm nay không có đơn sự kiện nào.'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSizes.m),
              itemCount: list.length,
              separatorBuilder: (_, __) => AppSizes.spacingM,
              itemBuilder: (context, index) {
                final order = list[index];
                return _buildTodayOrderCard(context, order);
              },
            ),
    );
  }

  Widget _buildTodayOrderCard(BuildContext context, MobileOrder order) {
    final hasUrgency = order.urgencyMessage != null;

    return InfoCard(
      borderColor: hasUrgency ? AppColors.error.withOpacity(0.5) : AppColors.divider,
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.managerOrderDetail,
          arguments: order.id,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.id,
                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              StatusChip(label: order.orderStatus.displayName),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.customerName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          
          // Venue Location
          Row(
            children: [
              const Icon(Icons.location_on_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.location,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Leader Assigned
          Row(
            children: [
              const Icon(Icons.person_rounded, size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Phụ trách: ${order.leaderStaffName}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Operational Status step
          Row(
            children: [
              const Icon(Icons.run_circle_outlined, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                'Bước hiện trường: ${order.fieldProgressStatus}',
                style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          if (hasUrgency) ...[
            const Divider(height: 20, color: AppColors.divider),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorLight.withOpacity(0.4),
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_rounded, color: AppColors.error, size: 16),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.urgencyMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
