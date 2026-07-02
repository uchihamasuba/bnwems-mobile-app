import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/search_input.dart';
import '../../../core/widgets/status_chip.dart';
import '../models/manager_mobile_models.dart';
import '../models/manager_route_args.dart';
import '../services/manager_mobile_service.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_priority_badge.dart';
import '../widgets/manager_section_header.dart';
import '../widgets/manager_statistic_card.dart';

class ManagerTodayScreen extends StatefulWidget {
  const ManagerTodayScreen({super.key});

  @override
  State<ManagerTodayScreen> createState() => _ManagerTodayScreenState();
}

class _ManagerTodayScreenState extends State<ManagerTodayScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'Tất cả';
  String _query = '';
  late Future<_TodayData> _future;

  static const List<String> _filters = [
    'Tất cả',
    'Đang xử lý',
    'Có task',
    'Có tiến độ',
  ];

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_TodayData> _loadData() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = DateTime(now.year, now.month, now.day);

    final results = await Future.wait([
      ManagerMobileService.getOrders(startDate: start, endDate: end, limit: 50),
      ManagerMobileService.getTasks(status: 'in_progress', limit: 50),
      ManagerMobileService.getFieldProgressFeed(),
    ]);

    return _TodayData(
      orders: results[0] as List<ManagerOrderSummary>,
      tasks: results[1] as List<ManagerTaskSummary>,
      fieldProgress: results[2] as List<ManagerOrderSummary>,
    );
  }

  void _reload() {
    setState(() {
      _future = _loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_TodayData>(
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
        final list = _filterOrders(data);
        final latestProgress =
            data.fieldProgress.isNotEmpty ? data.fieldProgress.first : null;

        return AppScaffold(
          useSafeArea: true,
          body: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.m),
              children: [
                const ManagerAppHeader(
                  title: 'Đơn hàng và task hôm nay',
                  subtitle:
                      'Tập trung các đầu việc trong ngày để quản lý theo dõi bằng dữ liệu backend thật.',
                ),
                const SizedBox(height: AppSizes.l),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompactPhone = constraints.maxWidth < 380;
                    return GridView.count(
                      crossAxisCount: isCompactPhone ? 2 : 3,
                      crossAxisSpacing: AppSizes.s,
                      mainAxisSpacing: AppSizes.s,
                      childAspectRatio: isCompactPhone ? 1.18 : 1.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        ManagerStatisticCard(
                          label: 'Đơn hôm nay',
                          value: '${data.orders.length}',
                          icon: Icons.today_rounded,
                          color: Colors.blue,
                          highlight: data.orders.isNotEmpty,
                          compact: true,
                        ),
                        ManagerStatisticCard(
                          label: 'Task đang chạy',
                          value: '${data.tasks.length}',
                          icon: Icons.sync_rounded,
                          color: Colors.orange,
                          highlight: data.tasks.isNotEmpty,
                          compact: true,
                        ),
                        ManagerStatisticCard(
                          label: 'Feed tiến độ',
                          value: '${data.fieldProgress.length}',
                          icon: Icons.timeline_rounded,
                          color: Colors.red,
                          highlight: data.fieldProgress.isNotEmpty,
                          compact: true,
                        ),
                      ],
                    );
                  },
                ),
                if (latestProgress != null) ...[
                  const SizedBox(height: AppSizes.m),
                  InfoCard(
                    borderColor: Colors.red.withValues(alpha: 0.2),
                    color: Colors.red.withValues(alpha: 0.06),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.timeline_rounded,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: AppSizes.m),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Cập nhật tiến độ mới nhất',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  ManagerPriorityBadge(
                                    label: 'API',
                                    compact: true,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                latestProgress.currentTask ?? '--',
                                style:
                                    const TextStyle(fontSize: 12, height: 1.4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                latestProgress.orderNumber,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSizes.l),
                SearchInput(
                  controller: _searchController,
                  hintText: 'Tìm theo mã đơn, địa điểm...',
                  onChanged: (value) => setState(() => _query = value.trim()),
                  onClear: () => setState(() => _query = ''),
                ),
                const SizedBox(height: AppSizes.m),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = filter == _activeFilter;
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSizes.s),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _activeFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: AppSizes.l),
                ManagerSectionHeader(
                  title: 'Danh sách cần theo dõi',
                  subtitle:
                      'Đang hiển thị ${list.length} đơn theo dữ liệu GET /orders trong ngày.',
                ),
                const SizedBox(height: AppSizes.m),
                if (list.isEmpty)
                  const SizedBox(
                    height: 320,
                    child: EmptyState(
                      title: 'Không có dữ liệu phù hợp',
                      description:
                          'Không có đơn nào phù hợp với bộ lọc hiện tại.',
                      icon: Icons.search_off_rounded,
                    ),
                  )
                else
                  ...list.map(
                    (order) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.m),
                      child: _TodayOrderCard(
                        order: order,
                        hasLiveTask: data.tasks
                            .any((task) => task.orderId == order.orderId),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<ManagerOrderSummary> _filterOrders(_TodayData data) {
    return data.orders.where((order) {
      final matchesQuery = _query.isEmpty ||
          order.orderNumber.toLowerCase().contains(_query.toLowerCase()) ||
          (order.venueAddress ?? '')
              .toLowerCase()
              .contains(_query.toLowerCase());

      final matchesFilter = switch (_activeFilter) {
        'Đang xử lý' => order.status.toLowerCase().contains('progress'),
        'Có task' => data.tasks.any((task) => task.orderId == order.orderId),
        'Có tiến độ' =>
          data.fieldProgress.any((item) => item.orderId == order.orderId),
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }
}

class _TodayData {
  const _TodayData({
    required this.orders,
    required this.tasks,
    required this.fieldProgress,
  });

  final List<ManagerOrderSummary> orders;
  final List<ManagerTaskSummary> tasks;
  final List<ManagerOrderSummary> fieldProgress;
}

class _TodayOrderCard extends StatelessWidget {
  const _TodayOrderCard({
    required this.order,
    required this.hasLiveTask,
  });

  final ManagerOrderSummary order;
  final bool hasLiveTask;

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
              if (hasLiveTask)
                const ManagerPriorityBadge(
                  label: 'Task đang chạy',
                  compact: true,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            order.venueAddress ?? 'Chưa có địa điểm',
            style: const TextStyle(
              fontSize: 15,
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
          const SizedBox(height: 8),
          Text(
            order.eventStartDate == null
                ? 'Ngày tổ chức: chưa có'
                : 'Ngày tổ chức: ${order.eventStartDate!.day}/${order.eventStartDate!.month}/${order.eventStartDate!.year}',
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
