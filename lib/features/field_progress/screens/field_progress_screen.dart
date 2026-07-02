import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/status_chip.dart';
import '../../manager/models/manager_mobile_models.dart';
import '../../manager/models/manager_route_args.dart';
import '../../manager/services/manager_mobile_service.dart';

class FieldProgressScreen extends StatefulWidget {
  const FieldProgressScreen({super.key});

  @override
  State<FieldProgressScreen> createState() => _FieldProgressScreenState();
}

class _FieldProgressScreenState extends State<FieldProgressScreen> {
  late Future<_FieldProgressViewData> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _loadData(_resolveOrderId());
  }

  String? _resolveOrderId() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ManagerOrderRouteArgs) {
      return args.orderId.isEmpty ? null : args.orderId;
    }
    if (args is String) {
      return args.isEmpty ? null : args;
    }
    return null;
  }

  Future<_FieldProgressViewData> _loadData(String? orderId) async {
    if (orderId == null || orderId.isEmpty) {
      final feed = await ManagerMobileService.getFieldProgressFeed();
      return _FieldProgressViewData.feed(feed);
    }

    final order = await ManagerMobileService.getOrderDetail(orderId);
    final tasks = await ManagerMobileService.getTasks(orderId: orderId, limit: 50);

    ManagerVerificationSummary? verification;
    try {
      verification = await ManagerMobileService.getVerificationSummary(orderId);
    } catch (_) {
      verification = null;
    }

    return _FieldProgressViewData.detail(
      _FieldProgressData(
        order: order,
        tasks: tasks,
        verification: verification,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FieldProgressViewData>(
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
            appBar: const CustomAppBar(
              title: 'Tiến độ hiện trường',
              showBackButton: true,
            ),
            body: ErrorState(
              message: snapshot.error.toString(),
            ),
          );
        }

        final viewData = snapshot.data!;
        if (viewData.feed != null) {
          return _buildFeedScreen(viewData.feed!);
        }

        return _buildDetailScreen(viewData.detail!);
      },
    );
  }

  Widget _buildFeedScreen(List<ManagerOrderSummary> orders) {
    final sortedOrders = [...orders]..sort((a, b) {
        final aTime = a.lastUpdate ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.lastUpdate ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bTime.compareTo(aTime);
      });

    return AppScaffold(
      useSafeArea: true,
      appBar: const CustomAppBar(
        title: 'Tiến độ hiện trường',
        showBackButton: true,
      ),
      body: sortedOrders.isEmpty
          ? const EmptyState(
              title: 'Chưa có tiến độ hiện trường',
              description:
                  'Backend không trả về đơn nào trong feed field progress.',
              icon: Icons.timeline_rounded,
            )
          : ListView(
              padding: const EdgeInsets.all(AppSizes.m),
              children: [
                InfoCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.timeline_rounded,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSizes.s),
                      Expanded(
                        child: Text(
                          'Chọn một đơn để xem timeline tiến độ chi tiết.',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                AppSizes.spacingM,
                ...sortedOrders.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSizes.m),
                    child: _FeedOrderCard(order: order),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDetailScreen(_FieldProgressData data) {
    final tasks = [...data.tasks]..sort((a, b) {
        final aTime = a.scheduledStart ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bTime = b.scheduledStart ?? DateTime.fromMillisecondsSinceEpoch(0);
        return aTime.compareTo(bTime);
      });

    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Tiến độ ${data.order.orderNumber}',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: AppSizes.m,
            ),
            color: AppColors.primaryLight.withValues(alpha: 0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.order.customer?.fullName.isNotEmpty == true
                            ? data.order.customer!.fullName
                            : data.order.orderNumber,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        data.order.venueAddress ?? 'Chưa có địa điểm',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusChip(label: data.order.status),
              ],
            ),
          ),
          Expanded(
            child: tasks.isEmpty
                ? ListView(
                    padding: const EdgeInsets.all(AppSizes.m),
                    children: const [
                      SizedBox(
                        height: 240,
                        child: EmptyState(
                          title: 'Chưa có task',
                          description:
                              'Đơn hàng này chưa có task nào từ backend.',
                          icon: Icons.assignment_outlined,
                        ),
                      ),
                    ],
                  )
                : ListView(
                    padding: const EdgeInsets.all(AppSizes.m),
                    children: [
                      ...List.generate(
                        tasks.length,
                        (index) => _buildTimelineRow(
                          tasks[index],
                          index == tasks.length - 1,
                        ),
                      ),
                      if (data.verification != null) ...[
                        const SizedBox(height: AppSizes.m),
                        InfoCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tổng hợp xác minh',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Task hoàn thành: ${data.verification!.tasksCompleted}/${data.verification!.totalTasks}',
                              ),
                              const SizedBox(height: 4),
                              Text('Bàn giao: ${data.verification!.handoverStatus}'),
                              const SizedBox(height: 4),
                              Text(
                                'Hỏng hóc/thiếu hụt đã ghi nhận: ${data.verification!.damageLossRecorded}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Trạng thái xác minh: ${data.verification!.verificationStatus}',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(ManagerTaskSummary task, bool isLast) {
    final stepColor = _colorForStatus(task.status);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: stepColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: stepColor.withValues(alpha: 0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: InfoCard(
                borderColor: stepColor.withValues(alpha: 0.35),
                color: stepColor.withValues(alpha: 0.05),
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            task.taskType,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        StatusChip(label: task.status),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (task.location != null && task.location!.isNotEmpty)
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              task.location!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (task.scheduledStart != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Bắt đầu: ${_formatDateTime(task.scheduledStart!)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (task.scheduledEnd != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Kết thúc: ${_formatDateTime(task.scheduledEnd!)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForStatus(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('done') || normalized.contains('complete')) {
      return AppColors.success;
    }
    if (normalized.contains('progress')) {
      return AppColors.primary;
    }
    if (normalized.contains('assign')) {
      return AppColors.warning;
    }
    return AppColors.textLight;
  }

  String _formatDateTime(DateTime value) {
    return '${value.day}/${value.month}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }
}

class _FeedOrderCard extends StatelessWidget {
  const _FeedOrderCard({required this.order});

  final ManagerOrderSummary order;

  @override
  Widget build(BuildContext context) {
    final hasCurrentTask =
        order.currentTask != null && order.currentTask!.isNotEmpty;

    return InfoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.managerFieldProgress,
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
              StatusChip(
                label: order.status.isEmpty ? 'Chưa xác định' : order.status,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.venueAddress ?? 'Chưa có địa điểm',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasCurrentTask
                      ? 'Task hiện tại: ${order.currentTask}'
                      : 'Task hiện tại: --',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (hasCurrentTask) const StatusChip(label: 'Live'),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            order.lastUpdate == null
                ? 'Cập nhật gần nhất: chưa có'
                : 'Cập nhật gần nhất: ${order.lastUpdate!.day}/${order.lastUpdate!.month}/${order.lastUpdate!.year} ${order.lastUpdate!.hour.toString().padLeft(2, '0')}:${order.lastUpdate!.minute.toString().padLeft(2, '0')}',
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

class _FieldProgressViewData {
  const _FieldProgressViewData({
    this.feed,
    this.detail,
  });

  factory _FieldProgressViewData.feed(List<ManagerOrderSummary> feed) {
    return _FieldProgressViewData(feed: feed);
  }

  factory _FieldProgressViewData.detail(_FieldProgressData detail) {
    return _FieldProgressViewData(detail: detail);
  }

  final List<ManagerOrderSummary>? feed;
  final _FieldProgressData? detail;
}

class _FieldProgressData {
  const _FieldProgressData({
    required this.order,
    required this.tasks,
    required this.verification,
  });

  final ManagerOrderDetail order;
  final List<ManagerTaskSummary> tasks;
  final ManagerVerificationSummary? verification;
}
