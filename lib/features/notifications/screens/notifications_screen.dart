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
import '../../manager/widgets/manager_app_header.dart';
import '../../manager/widgets/manager_priority_badge.dart';
import '../../manager/widgets/manager_section_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'Tất cả';
  late List<MobileNotification> _list;

  static const List<String> _filters = [
    'Tất cả',
    'Tác vụ',
    'Khảo sát',
    'Thay đổi',
    'Thanh toán',
    'Hỏng/Mất',
  ];

  @override
  void initState() {
    super.initState();
    _list = MockData.notifications;
  }

  List<MobileNotification> get _filteredNotifications {
    if (_activeFilter == 'Tất cả') {
      return _list;
    }

    String typeFilter = '';
    switch (_activeFilter) {
      case 'Tác vụ':
        typeFilter = 'Field Operation';
        break;
      case 'Khảo sát':
        typeFilter = 'Survey';
        break;
      case 'Thay đổi':
        typeFilter = 'Change Request';
        break;
      case 'Thanh toán':
        typeFilter = 'Payment';
        break;
      case 'Hỏng/Mất':
        typeFilter = 'Damage/Loss';
        break;
    }

    return _list.where((item) => item.type == typeFilter).toList();
  }

  void _markAsRead(int index) {
    setState(() {
      _filteredNotifications[index].isRead = true;
    });
  }

  void _handleTapNotification(MobileNotification notification) {
    final isManager =
        ModalRoute.of(context)?.settings.name?.contains('manager') ?? false;

    if (isManager) {
      switch (notification.type) {
        case 'Survey':
          Navigator.pushNamed(
            context,
            AppRoutes.managerSurveyReview,
            arguments: notification.orderCode,
          );
          break;
        case 'Change Request':
          Navigator.pushNamed(
            context,
            AppRoutes.managerChangeRequestApproval,
            arguments: notification.id,
          );
          break;
        case 'Payment':
          Navigator.pushNamed(
            context,
            AppRoutes.managerPaymentConfirmation,
            arguments: notification.id,
          );
          break;
        default:
          Navigator.pushNamed(
            context,
            AppRoutes.managerOrderDetail,
            arguments: notification.orderCode,
          );
          break;
      }
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.orderDetail,
      arguments: notification.orderCode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredNotifications;

    return AppScaffold(
      useSafeArea: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          ManagerAppHeader(
            title: 'Thông báo khẩn',
            subtitle:
                'Theo dõi task trễ, phát sinh hiện trường, thanh toán và các vấn đề cần phản hồi ngay.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_list.where((item) => !item.isRead).length} mới',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSizes.l),
          const ManagerSectionHeader(
            title: 'Bộ lọc thông báo',
            subtitle: 'Phân loại nhanh theo nhóm nghiệp vụ để xử lý thuận tiện hơn.',
          ),
          const SizedBox(height: AppSizes.m),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _activeFilter == filter;
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
          const ManagerSectionHeader(
            title: 'Danh sách thông báo',
            subtitle: 'Nhấn vào từng thẻ để đọc chi tiết và điều hướng tới màn hình liên quan.',
          ),
          const SizedBox(height: AppSizes.m),
          if (list.isEmpty)
            const SizedBox(
              height: 300,
              child: EmptyState(
                title: 'Không có thông báo phù hợp',
                description: 'Bộ lọc hiện tại chưa có thông báo nào cần hiển thị.',
                icon: Icons.notifications_off_rounded,
              ),
            )
          else
            ...List.generate(
              list.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.m),
                child: _NotificationCard(
                  notification: list[index],
                  onTap: () {
                    _markAsRead(index);
                    _handleTapNotification(list[index]);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  final MobileNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final isUrgent = notification.priority == 'High';

    return InfoCard(
      onTap: onTap,
      color: isUnread ? AppColors.primaryLight.withOpacity(0.5) : Colors.white,
      borderColor: isUrgent
          ? AppColors.error.withOpacity(0.24)
          : isUnread
          ? AppColors.primary.withOpacity(0.18)
          : AppColors.divider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isUrgent
                      ? AppColors.errorLight
                      : AppColors.infoLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForType(notification.type),
                  color: isUrgent ? AppColors.error : AppColors.info,
                ),
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight:
                            isUnread ? FontWeight.w800 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.orderCode,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isUrgent)
                    const ManagerPriorityBadge(
                      label: 'Khẩn cấp',
                      compact: true,
                    )
                  else
                    StatusChip(label: notification.type),
                  const SizedBox(height: 8),
                  Text(
                    '${notification.createdAt.hour.toString().padLeft(2, '0')}:${notification.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: AppColors.textLight,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            notification.message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              if (isUnread) const SizedBox(width: 8),
              Text(
                isUnread ? 'Chưa đọc' : 'Đã đọc',
                style: TextStyle(
                  color: isUnread ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Text(
                'Xem chi tiết',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Survey':
        return Icons.travel_explore_rounded;
      case 'Change Request':
        return Icons.published_with_changes_rounded;
      case 'Payment':
        return Icons.payments_outlined;
      case 'Damage/Loss':
        return Icons.report_problem_outlined;
      default:
        return Icons.assignment_late_outlined;
    }
  }
}
