import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
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
  late Future<_FieldProgressData> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _loadData(_resolveOrderId());
  }

  String _resolveOrderId() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ManagerOrderRouteArgs) {
      return args.orderId;
    }
    if (args is String) {
      return args;
    }
    return '';
  }

  Future<_FieldProgressData> _loadData(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Khong tim thay orderId de tai tien do hien truong.');
    }

    final order = await ManagerMobileService.getOrderDetail(orderId);
    final tasks = await ManagerMobileService.getTasks(orderId: orderId, limit: 50);
    ManagerVerificationSummary? verification;
    try {
      verification = await ManagerMobileService.getVerificationSummary(orderId);
    } catch (_) {
      verification = null;
    }

    return _FieldProgressData(
      order: order,
      tasks: tasks,
      verification: verification,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_FieldProgressData>(
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
              title: 'Tien do hien truong',
              showBackButton: true,
            ),
            body: ErrorState(
              message: snapshot.error.toString(),
            ),
          );
        }

        final data = snapshot.data!;
        final tasks = [...data.tasks]
          ..sort((a, b) {
            final aTime = a.scheduledStart ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bTime = b.scheduledStart ?? DateTime.fromMillisecondsSinceEpoch(0);
            return aTime.compareTo(bTime);
          });

        return AppScaffold(
          useSafeArea: true,
          appBar: CustomAppBar(
            title: 'Tien do ${data.order.orderNumber}',
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
                            data.order.venueAddress ?? 'Chua co dia diem',
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
                              title: 'Chua co task',
                              description: 'Order nay chua co task nao tu backend.',
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
                                    'Verification summary',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tasks completed: ${data.verification!.tasksCompleted}/${data.verification!.totalTasks}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Handover: ${data.verification!.handoverStatus}'),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Damage/loss recorded: ${data.verification!.damageLossRecorded}',
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Verification status: ${data.verification!.verificationStatus}',
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
      },
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
                        'Start: ${_formatDateTime(task.scheduledStart!)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (task.scheduledEnd != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'End: ${_formatDateTime(task.scheduledEnd!)}',
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
