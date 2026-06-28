import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../models/manager_mobile_models.dart';
import '../services/manager_mobile_service.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_backend_gap_card.dart';
import '../widgets/manager_priority_badge.dart';
import '../widgets/manager_section_header.dart';

class ManagerApprovalsScreen extends StatefulWidget {
  const ManagerApprovalsScreen({super.key});

  @override
  State<ManagerApprovalsScreen> createState() => _ManagerApprovalsScreenState();
}

class _ManagerApprovalsScreenState extends State<ManagerApprovalsScreen> {
  late Future<_ApprovalsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadData();
  }

  Future<_ApprovalsData> _loadData() async {
    final results = await Future.wait([
      ManagerMobileService.getDashboardSummary(),
      ManagerMobileService.getNotifications(limit: 20),
    ]);

    final notifications = results[1] as List<ManagerNotificationItem>;
    return _ApprovalsData(
      summary: results[0] as ManagerDashboardSummary,
      surveyNotifications: notifications.where(_isSurveyNotification).toList(),
      paymentNotifications: notifications.where(_isPaymentNotification).toList(),
    );
  }

  void _reload() {
    setState(() {
      _future = _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_ApprovalsData>(
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

        return AppScaffold(
          useSafeArea: true,
          body: ListView(
            padding: const EdgeInsets.all(AppSizes.m),
            children: [
              const ManagerAppHeader(
                title: 'Duyet nhanh',
                subtitle:
                    'Tap trung cac muc quan trong de Manager xu ly bang du lieu API that va thong bao hien co.',
              ),
              const SizedBox(height: AppSizes.l),
              const ManagerSectionHeader(
                title: 'Trang thai approval hien tai',
                subtitle:
                    'Dashboard hien chi co count change request. Cac nhom khac dang su dung notification feed de dieu huong.',
              ),
              const SizedBox(height: AppSizes.m),
              const ManagerBackendGapCard(
                title: 'Approval queue chua day du API',
                message:
                    'Backend chua co list survey approvals, change request detail/list va payment requests cho manager mobile. Man nay da bo MockData va chi hien thong tin that dang co.',
              ),
              const SizedBox(height: AppSizes.m),
              _ApprovalCard(
                title: 'Bao cao khao sat',
                subtitle: '${data.surveyNotifications.length} thong bao survey',
                description:
                    'Can them API list/detail survey approvals de hien noi dung cho duyet that.',
                priority: 'Can API',
                sender: 'Notifications feed',
                timestamp: 'GET /notifications',
                onView: data.surveyNotifications.isEmpty
                    ? null
                    : () => Navigator.pushNamed(
                          context,
                          AppRoutes.managerNotifications,
                        ),
              ),
              _ApprovalCard(
                title: 'Phat sinh hien truong',
                subtitle:
                    '${data.summary.pendingChangeRequests} muc pending trong dashboard',
                description:
                    'Da co PUT approve, nhung chua co GET detail/list de mobile hien noi dung thuc te.',
                priority: 'Action only',
                sender: 'GET /dashboard/manager',
                timestamp: 'pendingChangeRequests',
                onView: () => Navigator.pushNamed(
                  context,
                  AppRoutes.managerChangeRequestApproval,
                ),
              ),
              _ApprovalCard(
                title: 'Xac nhan thanh toan',
                subtitle: '${data.paymentNotifications.length} thong bao payment',
                description:
                    'Can them GET payment detail/proof hoac payment-request list de Manager review dung nghiep vu.',
                priority: 'Can API',
                sender: 'Notifications feed',
                timestamp: 'GET /notifications',
                onView: () => Navigator.pushNamed(
                  context,
                  AppRoutes.managerPaymentConfirmation,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isSurveyNotification(ManagerNotificationItem item) {
    final raw = '${item.type} ${item.refType} ${item.title}'.toLowerCase();
    return raw.contains('survey');
  }

  bool _isPaymentNotification(ManagerNotificationItem item) {
    final raw = '${item.type} ${item.refType} ${item.title}'.toLowerCase();
    return raw.contains('payment');
  }
}

class _ApprovalsData {
  const _ApprovalsData({
    required this.summary,
    required this.surveyNotifications,
    required this.paymentNotifications,
  });

  final ManagerDashboardSummary summary;
  final List<ManagerNotificationItem> surveyNotifications;
  final List<ManagerNotificationItem> paymentNotifications;
}

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.priority,
    required this.sender,
    required this.timestamp,
    required this.onView,
  });

  final String title;
  final String subtitle;
  final String description;
  final String priority;
  final String sender;
  final String timestamp;
  final VoidCallback? onView;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.m),
      child: InfoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SizedBox.shrink()),
                ManagerPriorityBadge(label: priority, compact: true),
              ],
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Nguon: $sender',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  timestamp,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Thong bao',
                    icon: Icons.notifications_active_outlined,
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.s),
                Expanded(
                  child: PrimaryButton(
                    text: 'Mo man hinh',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: onView,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
