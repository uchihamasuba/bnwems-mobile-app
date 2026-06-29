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
import '../models/manager_mobile_models.dart';
import '../models/manager_route_args.dart';
import '../services/manager_mobile_service.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_section_header.dart';

class ManagerProgressScreen extends StatefulWidget {
  const ManagerProgressScreen({super.key});

  @override
  State<ManagerProgressScreen> createState() => _ManagerProgressScreenState();
}

class _ManagerProgressScreenState extends State<ManagerProgressScreen> {
  late Future<List<ManagerOrderSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = ManagerMobileService.getFieldProgressFeed();
  }

  void _reload() {
    setState(() {
      _future = ManagerMobileService.getFieldProgressFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ManagerOrderSummary>>(
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

        final orders = snapshot.data!;
        final activeCount = orders.where((o) => o.status.isNotEmpty).length;
        final withTaskCount =
            orders.where((o) => o.currentTask != null && o.currentTask!.isNotEmpty).length;

        return AppScaffold(
          useSafeArea: true,
          body: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.m),
              children: [
                ManagerAppHeader(
                  title: 'Tien do hien truong',
                  subtitle:
                      'Theo doi feed GET /orders/field-progress va di vao man timeline chi tiet.',
                  trailing: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: IconButton(
                      onPressed: _reload,
                      icon: const Icon(
                        Icons.refresh_rounded,
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
                        label: 'Co feed',
                        value: '$activeCount',
                        color: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: AppSizes.s),
                    Expanded(
                      child: _KpiCard(
                        label: 'Co current task',
                        value: '$withTaskCount',
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: AppSizes.s),
                    Expanded(
                      child: _KpiCard(
                        label: 'Tong don',
                        value: '${orders.length}',
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.l),
                const ManagerSectionHeader(
                  title: 'Danh sach dang theo doi',
                  subtitle: 'Du lieu lay truc tiep tu feed tien do backend.',
                ),
                const SizedBox(height: AppSizes.m),
                if (orders.isEmpty)
                  const SizedBox(
                    height: 260,
                    child: EmptyState(
                      title: 'Chua co tien do hien truong',
                      description: 'Backend khong tra ve don nao trong feed field-progress.',
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
          ),
        );
      },
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
      color: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.16),
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

  final ManagerOrderSummary order;

  @override
  Widget build(BuildContext context) {
    final hasCurrentTask = order.currentTask != null && order.currentTask!.isNotEmpty;

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.venueAddress ?? 'Chua co dia diem',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(label: order.status.isEmpty ? 'Unknown' : order.status),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  hasCurrentTask ? 'Current task: ${order.currentTask}' : 'Current task: --',
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
                ? 'Last update: chua co'
                : 'Last update: ${order.lastUpdate!.day}/${order.lastUpdate!.month}/${order.lastUpdate!.year} ${order.lastUpdate!.hour.toString().padLeft(2, '0')}:${order.lastUpdate!.minute.toString().padLeft(2, '0')}',
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
