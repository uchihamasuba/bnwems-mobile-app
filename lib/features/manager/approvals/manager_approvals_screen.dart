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

class ManagerApprovalsScreen extends StatefulWidget {
  const ManagerApprovalsScreen({super.key});

  @override
  State<ManagerApprovalsScreen> createState() => _ManagerApprovalsScreenState();
}

class _ManagerApprovalsScreenState extends State<ManagerApprovalsScreen> {
  late Future<List<ManagerNotificationItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = ManagerMobileService.getNotifications(limit: 50);
  }

  void _reload() {
    setState(() {
      _future = ManagerMobileService.getNotifications(limit: 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ManagerNotificationItem>>(
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

        final items = snapshot.data!
            .where((item) => _isApprovalNotification(item))
            .toList();

        return AppScaffold(
          useSafeArea: true,
          body: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.m),
              children: [
                const ManagerAppHeader(
                  title: 'Duyet nhanh',
                  subtitle: 'Danh sach nay dung truc tiep tu notifications backend.',
                ),
                const SizedBox(height: AppSizes.l),
                const ManagerSectionHeader(
                  title: 'Thong bao can xu ly',
                  subtitle: 'Survey, change request va payment se duoc loc tu notification feed.',
                ),
                const SizedBox(height: AppSizes.m),
                if (items.isEmpty)
                  const SizedBox(
                    height: 260,
                    child: EmptyState(
                      title: 'Khong co muc can xu ly',
                      description: 'Khong co thong bao can xu ly.',
                      icon: Icons.fact_check_outlined,
                    ),
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.m),
                      child: _ApprovalNotificationCard(notification: item),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isApprovalNotification(ManagerNotificationItem item) {
    final raw = '${item.type} ${item.refType} ${item.title}'.toLowerCase();
    return raw.contains('survey') || raw.contains('change') || raw.contains('payment');
  }
}

class _ApprovalNotificationCard extends StatelessWidget {
  const _ApprovalNotificationCard({required this.notification});

  final ManagerNotificationItem notification;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: () => _open(context, notification),
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
              StatusChip(label: notification.type.isEmpty ? 'Approval' : notification.type),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification.content.isEmpty ? '--' : notification.content,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                notification.refType ?? '--',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                notification.refId ?? '--',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _open(BuildContext context, ManagerNotificationItem item) {
    final refType = (item.refType ?? item.type).toLowerCase();
    final refId = item.refId;
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
    }
  }
}
