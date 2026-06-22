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

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _activeFilter = 'Tất cả';
  late List<MobileNotification> _list;

  @override
  void initState() {
    super.initState();
    _list = MockData.notifications;
  }

  List<MobileNotification> get _filteredNotifications {
    if (_activeFilter == 'Tất cả') return _list;
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
    return _list.where((n) => n.type == typeFilter).toList();
  }

  void _markAsRead(int index) {
    setState(() {
      _filteredNotifications[index].isRead = true;
    });
  }

  void _handleTapNotification(MobileNotification n) {
    final isManager = ModalRoute.of(context)?.settings.name?.contains('manager') ?? false;
    if (isManager) {
      switch (n.type) {
        case 'Survey':
          Navigator.pushNamed(context, AppRoutes.managerSurveyReview, arguments: n.orderCode);
          break;
        case 'Change Request':
          Navigator.pushNamed(context, AppRoutes.managerChangeRequestApproval, arguments: n.id);
          break;
        case 'Payment':
          Navigator.pushNamed(context, AppRoutes.managerPaymentConfirmation, arguments: n.id);
          break;
        default:
          Navigator.pushNamed(context, AppRoutes.managerOrderDetail, arguments: n.orderCode);
          break;
      }
    } else {
      Navigator.pushNamed(context, AppRoutes.orderDetail, arguments: n.orderCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final types = ['Tất cả', 'Tác vụ', 'Khảo sát', 'Thay đổi', 'Thanh toán', 'Hỏng/Mất'];

    return AppScaffold(
      useSafeArea: true,
      appBar: const CustomAppBar(
        title: 'Thông báo khẩn cấp',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Filter Tabs scroll
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: 8),
              itemCount: types.length,
              itemBuilder: (context, index) {
                final type = types[index];
                final isSelected = _activeFilter == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: isSelected,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _activeFilter = type);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),
          
          Expanded(
            child: _filteredNotifications.isEmpty
                ? const Center(child: Text('Không có thông báo nào trong mục này.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.m),
                    itemCount: _filteredNotifications.length,
                    separatorBuilder: (_, __) => AppSizes.spacingM,
                    itemBuilder: (context, index) {
                      final n = _filteredNotifications[index];
                      return _buildNotificationCard(n, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(MobileNotification n, int index) {
    final isUnread = !n.isRead;
    final isHigh = n.priority == 'High';

    return InfoCard(
      color: isUnread ? AppColors.primaryLight.withOpacity(0.15) : Colors.white,
      borderColor: isUnread
          ? AppColors.primary.withOpacity(0.3)
          : isHigh
              ? AppColors.error.withOpacity(0.2)
              : AppColors.divider,
      onTap: () {
        _markAsRead(index);
        _handleTapNotification(n);
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indicator circle
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isUnread ? AppColors.primary : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      n.orderCode,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                    Row(
                      children: [
                        if (isHigh)
                          const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: StatusChip(label: 'URGENT'),
                          ),
                        Text(
                          '${n.createdAt.hour}:${n.createdAt.minute.toString().padLeft(2, '0')}',
                          style: const TextStyle(color: AppColors.textLight, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  n.title,
                  style: TextStyle(
                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  n.message,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
