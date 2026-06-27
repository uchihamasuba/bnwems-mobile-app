import 'package:flutter/material.dart';

import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/search_input.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/core_models.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_priority_badge.dart';
import '../widgets/manager_section_header.dart';
import '../widgets/manager_statistic_card.dart';
import '../widgets/manager_task_card.dart';

class ManagerTodayScreen extends StatefulWidget {
  const ManagerTodayScreen({super.key});

  @override
  State<ManagerTodayScreen> createState() => _ManagerTodayScreenState();
}

class _ManagerTodayScreenState extends State<ManagerTodayScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _activeFilter = 'Tất cả';
  String _query = '';

  static const List<String> _filters = [
    'Tất cả',
    'Khẩn cấp',
    'Đang xử lý',
    'Chờ duyệt',
    'Hoàn tất',
  ];

  List<MobileOrder> get _filteredOrders {
    return MockData.orders.where((order) {
      final matchesQuery =
          _query.isEmpty ||
          order.id.toLowerCase().contains(_query.toLowerCase()) ||
          order.customerName.toLowerCase().contains(_query.toLowerCase()) ||
          order.location.toLowerCase().contains(_query.toLowerCase());

      final matchesFilter = switch (_activeFilter) {
        'Khẩn cấp' => order.hasEmergency,
        'Đang xử lý' => order.fieldProgressStatus != 'Completed',
        'Chờ duyệt' => order.surveyStatus == 'Pending',
        'Hoàn tất' => order.fieldProgressStatus == 'Completed',
        _ => true,
      };

      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredOrders;
    final allOrders = MockData.orders;
    final urgentCount = allOrders.where((item) => item.hasEmergency).length;
    final activeCount = allOrders
        .where((item) => item.orderStatus != OrderStatus.closed)
        .length;
    final pendingCount = allOrders
        .where((item) => item.surveyStatus == 'Pending')
        .length;
    final latestUrgent = allOrders.cast<MobileOrder?>().firstWhere(
      (item) => item?.urgencyMessage != null,
      orElse: () => null,
    );

    return AppScaffold(
      useSafeArea: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          const ManagerAppHeader(
            title: 'Đơn hàng và task hôm nay',
            subtitle:
                'Tập trung các đầu việc phát sinh trong ngày để Manager theo dõi và phản hồi nhanh.',
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
                    label: 'Hôm nay',
                    value: '${allOrders.length}',
                    icon: Icons.today_rounded,
                    color: Colors.blue,
                    highlight: allOrders.isNotEmpty,
                    compact: true,
                  ),
                  ManagerStatisticCard(
                    label: 'Đang xử lý',
                    value: '$activeCount',
                    icon: Icons.sync_rounded,
                    color: Colors.orange,
                    highlight: activeCount > 0,
                    compact: true,
                  ),
                  ManagerStatisticCard(
                    label: 'Khẩn cấp',
                    value: '$urgentCount',
                    icon: Icons.priority_high_rounded,
                    color: Colors.red,
                    highlight: urgentCount > 0,
                    compact: true,
                  ),
                ],
              );
            },
          ),
          if (latestUrgent != null) ...[
            const SizedBox(height: AppSizes.m),
            InfoCard(
              borderColor: Colors.red.withOpacity(0.2),
              color: Colors.red.withOpacity(0.06),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.warning_amber_rounded,
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
                                'Cảnh báo nổi bật hôm nay',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            ManagerPriorityBadge(
                              label: 'Khẩn cấp',
                              compact: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          latestUrgent.urgencyMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          latestUrgent.id,
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
            hintText: 'Tìm theo mã đơn, khách hàng, địa điểm...',
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
                    onSelected: (_) => setState(() => _activeFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSizes.l),
          ManagerSectionHeader(
            title: 'Danh sách cần theo dõi',
            subtitle:
                'Hiển thị ${list.length} mục phù hợp với bộ lọc hiện tại. Có $pendingCount mục chưa duyệt.',
          ),
          const SizedBox(height: AppSizes.m),
          if (list.isEmpty)
            const SizedBox(
              height: 320,
              child: EmptyState(
                title: 'Không có dữ liệu phù hợp',
                description:
                    'Thử đổi bộ lọc hoặc từ khóa tìm kiếm để xem thêm đơn hàng và task khác.',
                icon: Icons.search_off_rounded,
              ),
            )
          else
            ...list.map(
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
        ],
      ),
    );
  }
}
