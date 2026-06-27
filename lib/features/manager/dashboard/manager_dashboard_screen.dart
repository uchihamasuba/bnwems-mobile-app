import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../services/auth_service.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/core_models.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_priority_badge.dart';
import '../widgets/manager_quick_action_tile.dart';
import '../widgets/manager_section_header.dart';
import '../widgets/manager_statistic_card.dart';
import '../widgets/manager_task_card.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayOrders = MockData.orders
        .where(
          (order) =>
              order.orderStatus != OrderStatus.closed &&
              order.orderStatus != OrderStatus.cancelled,
        )
        .toList();
    final urgentNotifications = MockData.notifications
        .where((item) => item.priority == 'High')
        .toList();
    final pendingSurveys = MockData.surveyReports
        .where((item) => item.approvalStatus == 'Pending')
        .toList();
    final pendingChanges = MockData.changeRequests
        .where((item) => item.approvalStatus == 'Pending')
        .toList();
    final pendingPayments = MockData.paymentConfirmations
        .where((item) => item.status == 'Pending')
        .toList();
    final pendingApprovals =
        pendingSurveys.length + pendingChanges.length + pendingPayments.length;
    final focusItems = todayOrders.where((order) => order.hasEmergency).toList();
    final displayItems = focusItems.isNotEmpty ? focusItems : todayOrders.take(2).toList();

    return AppScaffold(
      useSafeArea: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          ManagerAppHeader(
            title: 'Xin chào, Manager',
            subtitle:
                'Hôm nay bạn có ${todayOrders.length} đơn cần theo dõi và $pendingApprovals mục chờ xử lý.',
            trailing: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: IconButton(
                onPressed: () async {
                  await AuthService.logout();
                  if (!context.mounted) {
                    return;
                  }
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.l),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: AppSizes.m,
            mainAxisSpacing: AppSizes.m,
            childAspectRatio: 1.18,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              ManagerStatisticCard(
                label: 'Đơn hàng hôm nay',
                value: '${todayOrders.length}',
                icon: Icons.event_note_rounded,
                color: AppColors.primary,
                highlight: todayOrders.isNotEmpty,
              ),
              ManagerStatisticCard(
                label: 'Task đang xử lý',
                value:
                    '${todayOrders.where((item) => item.fieldProgressStatus != 'Completed').length}',
                icon: Icons.play_circle_outline_rounded,
                color: AppColors.info,
                highlight: true,
              ),
              ManagerStatisticCard(
                label: 'Cảnh báo khẩn',
                value: '${urgentNotifications.length}',
                icon: Icons.crisis_alert_rounded,
                color: AppColors.error,
                highlight: urgentNotifications.isNotEmpty,
              ),
              ManagerStatisticCard(
                label: 'Mục chờ duyệt',
                value: '$pendingApprovals',
                icon: Icons.fact_check_outlined,
                color: AppColors.warning,
                highlight: pendingApprovals > 0,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.l),
          const ManagerSectionHeader(
            title: 'Lối tắt điều hành',
            subtitle: 'Mở nhanh những khu vực Manager dùng thường xuyên nhất.',
          ),
          const SizedBox(height: AppSizes.m),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSizes.m,
            mainAxisSpacing: AppSizes.m,
            childAspectRatio: 1.25,
            children: [
              ManagerQuickActionTile(
                label: 'Đơn hàng hôm nay',
                icon: Icons.today_rounded,
                color: AppColors.primary,
                onTap: () => Navigator.pushNamed(context, AppRoutes.managerToday),
              ),
              ManagerQuickActionTile(
                label: 'Theo dõi tiến độ',
                icon: Icons.timeline_rounded,
                color: AppColors.info,
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.managerFieldProgress),
              ),
              ManagerQuickActionTile(
                label: 'Yêu cầu phát sinh',
                icon: Icons.published_with_changes_rounded,
                color: AppColors.warning,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.managerChangeRequestApproval,
                ),
              ),
              ManagerQuickActionTile(
                label: 'Xác nhận thanh toán',
                icon: Icons.payments_outlined,
                color: AppColors.success,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.managerPaymentConfirmation,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.l),
          const ManagerSectionHeader(
            title: 'Việc cần xử lý hôm nay',
            subtitle: 'Ưu tiên các đơn đang vận hành hoặc có cảnh báo cần phản hồi nhanh.',
          ),
          const SizedBox(height: AppSizes.m),
          ...displayItems.map(
            (order) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.m),
              child: ManagerTaskCard(
                order: order,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.managerOrderDetail,
                  arguments: order.id,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.s),
          const ManagerSectionHeader(
            title: 'Cảnh báo mới nhất',
            subtitle: 'Các thông báo ảnh hưởng tới tiến độ, phát sinh và thanh toán.',
          ),
          const SizedBox(height: AppSizes.m),
          if (urgentNotifications.isEmpty)
            const InfoCard(
              child: Text(
                'Hiện chưa có cảnh báo khẩn nào mới. Hệ thống đang vận hành ổn định.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            )
          else
            ...urgentNotifications.take(3).map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.m),
                child: _AlertCard(notification: item),
              ),
            ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.notification});

  final MobileNotification notification;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.managerNotifications,
      ),
      color: notification.priority == 'High'
          ? AppColors.errorLight.withOpacity(0.55)
          : Colors.white,
      borderColor: notification.priority == 'High'
          ? AppColors.error.withOpacity(0.2)
          : AppColors.divider,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.error,
            ),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const ManagerPriorityBadge(
                      label: 'Khẩn cấp',
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.message,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      notification.orderCode,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    StatusChip(label: notification.type),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
