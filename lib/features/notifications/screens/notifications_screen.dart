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
import '../../manager/models/manager_mobile_models.dart';
import '../../manager/models/manager_route_args.dart';
import '../../manager/services/manager_mobile_service.dart';
import '../../manager/widgets/manager_app_header.dart';
import '../../manager/widgets/manager_priority_badge.dart';
import '../../manager/widgets/manager_section_header.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'Tat ca';
  bool _loading = true;
  String? _error;
  List<ManagerNotificationItem> _list = const [];

  static const List<String> _filters = [
    'Tat ca',
    'Tac vu',
    'Khao sat',
    'Thay doi',
    'Thanh toan',
    'Khac',
  ];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final items = await ManagerMobileService.getNotifications(limit: 50);
      if (!mounted) {
        return;
      }
      setState(() {
        _list = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  List<ManagerNotificationItem> get _filteredNotifications {
    if (_activeFilter == 'Tat ca') {
      return _list;
    }

    return _list.where((item) {
      final type = _notificationBucket(item);
      return switch (_activeFilter) {
        'Tac vu' => type == 'Tac vu',
        'Khao sat' => type == 'Khao sat',
        'Thay doi' => type == 'Thay doi',
        'Thanh toan' => type == 'Thanh toan',
        'Khac' => type == 'Khac',
        _ => true,
      };
    }).toList();
  }

  Future<void> _markAsRead(ManagerNotificationItem notification) async {
    if (notification.isRead) {
      return;
    }

    try {
      await ManagerMobileService.markNotificationRead(notification.notificationId);
      if (!mounted) {
        return;
      }
      setState(() {
        _list = _list.map((item) {
          if (item.notificationId == notification.notificationId) {
            return ManagerNotificationItem(
              notificationId: item.notificationId,
              title: item.title,
              content: item.content,
              type: item.type,
              isRead: true,
              createdAt: item.createdAt,
              refType: item.refType,
              refId: item.refId,
            );
          }
          return item;
        }).toList();
      });
    } catch (_) {}
  }

  void _handleTapNotification(ManagerNotificationItem notification) {
    final refType = (notification.refType ?? notification.type).toLowerCase();
    final refId = notification.refId;

    if (refId == null || refId.isEmpty) {
      return;
    }

    if (refType.contains('survey')) {
      Navigator.pushNamed(
        context,
        AppRoutes.managerSurveyReview,
        arguments: ManagerSurveyRouteArgs(taskId: refId),
      );
      return;
    }

    if (refType.contains('change')) {
      Navigator.pushNamed(
        context,
        AppRoutes.managerChangeRequestApproval,
        arguments: ManagerChangeRequestRouteArgs(changeRequestId: refId),
      );
      return;
    }

    if (refType.contains('payment')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mo don hang lien quan de xem giao dich.'),
        ),
      );
      return;
    }

    if (refType.contains('order')) {
      Navigator.pushNamed(
        context,
        AppRoutes.managerOrderDetail,
        arguments: ManagerOrderRouteArgs(orderId: refId),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppScaffold(
        useSafeArea: true,
        body: LoadingState(),
      );
    }

    if (_error != null) {
      return AppScaffold(
        useSafeArea: true,
        body: ErrorState(
          message: _error!,
          onRetry: _loadNotifications,
        ),
      );
    }

    final list = _filteredNotifications;
    final unreadCount = _list.where((item) => !item.isRead).length;

    return AppScaffold(
      useSafeArea: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          ManagerAppHeader(
            title: 'Thong bao khan',
            subtitle: 'Theo doi thong bao backend va dieu huong nhanh toi man hinh lien quan.',
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '$unreadCount moi',
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
            title: 'Bo loc thong bao',
            subtitle: 'Phan loai nhanh theo nhom nghiep vu tu du lieu backend hien co.',
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
            title: 'Danh sach thong bao',
            subtitle: 'Nhan vao de danh dau da doc va mo man hinh phu hop neu backend co refType/refId.',
          ),
          const SizedBox(height: AppSizes.m),
          if (list.isEmpty)
            const SizedBox(
              height: 300,
                    child: EmptyState(
                      title: 'Khong co thong bao phu hop',
                      description: 'Khong co thong bao nao cho bo loc hien tai.',
                      icon: Icons.notifications_off_rounded,
                    ),
                  )
          else
            ...list.map(
              (notification) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.m),
                child: _NotificationCard(
                  notification: notification,
                  typeLabel: _notificationBucket(notification),
                  onTap: () async {
                    await _markAsRead(notification);
                    if (!context.mounted) {
                      return;
                    }
                    _handleTapNotification(notification);
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _notificationBucket(ManagerNotificationItem notification) {
    final raw = '${notification.type} ${notification.refType} ${notification.title}'
        .toLowerCase();
    if (raw.contains('survey')) {
      return 'Khao sat';
    }
    if (raw.contains('change')) {
      return 'Thay doi';
    }
    if (raw.contains('payment')) {
      return 'Thanh toan';
    }
    if (raw.contains('task') || raw.contains('order') || raw.contains('field')) {
      return 'Tac vu';
    }
    return 'Khac';
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.typeLabel,
    required this.onTap,
  });

  final ManagerNotificationItem notification;
  final String typeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    final isUrgent = typeLabel == 'Thanh toan' || typeLabel == 'Thay doi';

    return InfoCard(
      onTap: onTap,
      color: isUnread ? AppColors.primaryLight.withValues(alpha: 0.5) : Colors.white,
      borderColor: isUrgent
          ? AppColors.error.withValues(alpha: 0.24)
          : isUnread
              ? AppColors.primary.withValues(alpha: 0.18)
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
                  color: isUrgent ? AppColors.errorLight : AppColors.infoLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _iconForType(typeLabel),
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
                        fontWeight: isUnread ? FontWeight.w800 : FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.refType ?? 'No reference',
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
                      label: 'Can xu ly',
                      compact: true,
                    )
                  else
                    StatusChip(label: typeLabel),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(notification.createdAt),
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
            notification.content.isEmpty
                ? 'Khong co noi dung chi tiet.'
                : notification.content,
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
                isUnread ? 'Chua doc' : 'Da doc',
                style: TextStyle(
                  color: isUnread ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              const Text(
                'Mo lien ket',
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

  String _formatTime(DateTime? value) {
    if (value == null) {
      return '--:--';
    }
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'Khao sat':
        return Icons.travel_explore_rounded;
      case 'Thay doi':
        return Icons.published_with_changes_rounded;
      case 'Thanh toan':
        return Icons.payments_outlined;
      case 'Tac vu':
        return Icons.assignment_late_outlined;
      default:
        return Icons.notifications_active_outlined;
    }
  }
}
