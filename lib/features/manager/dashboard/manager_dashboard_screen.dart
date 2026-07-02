import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../services/auth_service.dart';
import '../models/manager_mobile_models.dart';
import '../models/manager_route_args.dart';
import '../services/manager_mobile_service.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_priority_badge.dart';
import '../widgets/manager_quick_action_tile.dart';
import '../widgets/manager_section_header.dart';
import '../widgets/manager_statistic_card.dart';

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() => _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  late Future<_DashboardData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_DashboardData> _loadData() async {
    final now = DateTime.now();
    final results = await Future.wait([
      ManagerMobileService.getDashboardSummary(),
      ManagerMobileService.getNotifications(limit: 10),
      ManagerMobileService.getOrders(
        startDate: DateTime(now.year, now.month, now.day),
        endDate: DateTime(now.year, now.month, now.day),
        limit: 10,
      ),
      ManagerMobileService.getFieldProgressFeed(),
    ]);

    return _DashboardData(
      summary: results[0] as ManagerDashboardSummary,
      notifications: results[1] as List<ManagerNotificationItem>,
      todayOrders: results[2] as List<ManagerOrderSummary>,
      fieldProgress: results[3] as List<ManagerOrderSummary>,
    );
  }

  void _reload() {
    setState(() {
      _future = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AppScaffold(
            useSafeArea: true,
            body: LoadingState(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return AppScaffold(
            useSafeArea: true,
            body: ErrorState(
              message: snapshot.error.toString(),
              onRetry: _reload,
            ),
          );
        }

        final data = snapshot.data!;
        final unreadNotifications =
            data.notifications.where((item) => !item.isRead).length;

        return AppScaffold(
          useSafeArea: true,
          body: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.m),
              children: [
                ManagerAppHeader(
                  title: 'Xin chào, Quản lý',
                  subtitle:
                      'Hôm nay có ${data.todayOrders.length} đơn cần theo dõi và $unreadNotifications thông báo chưa đọc.',
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
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
                      icon:
                          const Icon(Icons.logout_rounded, color: Colors.white),
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
                      label: 'Đơn đang xử lý',
                      value: '${data.summary.ordersInProgress}',
                      icon: Icons.event_note_rounded,
                      color: AppColors.primary,
                      highlight: data.summary.ordersInProgress > 0,
                    ),
                    ManagerStatisticCard(
                      label: 'Task hôm nay',
                      value: '${data.summary.tasksToday}',
                      icon: Icons.play_circle_outline_rounded,
                      color: AppColors.info,
                      highlight: data.summary.tasksToday > 0,
                    ),
                    ManagerStatisticCard(
                      label: 'Cảnh báo',
                      value: '${data.summary.alerts.length}',
                      icon: Icons.crisis_alert_rounded,
                      color: AppColors.error,
                      highlight: data.summary.alerts.isNotEmpty,
                    ),
                    ManagerStatisticCard(
                      label: 'Phát sinh chờ duyệt',
                      value: '${data.summary.pendingChangeRequests}',
                      icon: Icons.fact_check_outlined,
                      color: AppColors.warning,
                      highlight: data.summary.pendingChangeRequests > 0,
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.l),
                const ManagerSectionHeader(
                  title: 'Lối tắt điều hành',
                  subtitle:
                      'Mở nhanh các tác vụ quản lý trọng tâm, không lặp lại danh sách đơn bên dưới.',
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
                      label: 'Tiến độ hiện trường',
                      icon: Icons.timeline_rounded,
                      color: AppColors.info,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.managerFieldProgress,
                      ),
                    ),
                    ManagerQuickActionTile(
                      label: 'Duyệt phát sinh',
                      icon: Icons.published_with_changes_rounded,
                      color: AppColors.warning,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.managerChangeRequestApproval,
                      ),
                    ),
                    ManagerQuickActionTile(
                      label: 'Thông báo khẩn',
                      icon: Icons.notifications_active_rounded,
                      color: AppColors.error,
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.managerNotifications,
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
                  title: 'Đơn hôm nay',
                  subtitle: 'Danh sách lấy từ GET /orders theo ngày hiện tại.',
                ),
                const SizedBox(height: AppSizes.m),
                if (data.todayOrders.isEmpty)
                  const SizedBox(
                    height: 220,
                    child: EmptyState(
                      title: 'Chưa có đơn hôm nay',
                      description: 'Không có đơn nào trong ngày hiện tại.',
                      icon: Icons.event_busy_outlined,
                    ),
                  )
                else
                  ...data.todayOrders.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.m),
                      child: _DashboardOrderCard(order: order),
                    ),
                  ),
                const SizedBox(height: AppSizes.s),
                const ManagerSectionHeader(
                  title: 'Thông báo mới nhất',
                  subtitle: 'Nguồn dữ liệu từ GET /notifications.',
                ),
                const SizedBox(height: AppSizes.m),
                if (data.notifications.isEmpty)
                  const SizedBox(
                    height: 220,
                    child: EmptyState(
                      title: 'Chưa có thông báo',
                      description: 'Không có thông báo nào cho quản lý.',
                      icon: Icons.notifications_off_outlined,
                    ),
                  )
                else
                  ...data.notifications.take(3).map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.m),
                          child: _AlertCard(notification: item),
                        ),
                      ),
                if (data.summary.alerts.isNotEmpty) ...[
                  const SizedBox(height: AppSizes.s),
                  ...data.summary.alerts.map(
                    (alert) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.m),
                      child: InfoCard(
                        color: AppColors.errorLight.withValues(alpha: 0.35),
                        borderColor: AppColors.error.withValues(alpha: 0.2),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: AppColors.error,
                            ),
                            const SizedBox(width: AppSizes.m),
                            Expanded(
                              child: Text(
                                alert.type.isEmpty ? 'Cảnh báo' : alert.type,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if ((alert.orderId ?? '').isNotEmpty)
                              StatusChip(label: alert.orderId!),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardData {
  const _DashboardData({
    required this.summary,
    required this.notifications,
    required this.todayOrders,
    required this.fieldProgress,
  });

  final ManagerDashboardSummary summary;
  final List<ManagerNotificationItem> notifications;
  final List<ManagerOrderSummary> todayOrders;
  final List<ManagerOrderSummary> fieldProgress;
}

class _DashboardOrderCard extends StatelessWidget {
  const _DashboardOrderCard({required this.order});

  final ManagerOrderSummary order;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.managerOrderDetail,
        arguments: ManagerOrderRouteArgs(orderId: order.orderId),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.orderNumber,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (order.currentTask != null && order.currentTask!.isNotEmpty)
                const ManagerPriorityBadge(label: 'Live', compact: true),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.venueAddress ?? 'Chưa có địa điểm',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusChip(
                label: order.status.isEmpty ? 'Chưa xác định' : order.status,
              ),
              if (order.currentTask != null && order.currentTask!.isNotEmpty)
                StatusChip(label: order.currentTask!),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.eventStartDate == null
                ? 'Chưa có ngày tổ chức'
                : 'Ngày tổ chức: ${_formatDate(order.eventStartDate!)}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.notification});

  final ManagerNotificationItem notification;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.managerNotifications),
      color: AppColors.errorLight.withValues(alpha: 0.35),
      borderColor: AppColors.error.withValues(alpha: 0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.12),
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
                      label: 'Mới',
                      compact: true,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  notification.content.isEmpty
                      ? 'Thông báo này chưa có nội dung chi tiết.'
                      : notification.content,
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
                      notification.refType ?? 'notification',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    StatusChip(
                      label: notification.type.isEmpty
                          ? 'Chung'
                          : notification.type,
                    ),
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

String _formatDate(DateTime value) {
  return '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year}';
}
