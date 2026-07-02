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
  late Future<List<ManagerApprovalItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = ManagerMobileService.getManagerApprovals();
  }

  void _reload() {
    setState(() {
      _future = ManagerMobileService.getManagerApprovals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ManagerApprovalItem>>(
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

        final items = snapshot.data!;

        return AppScaffold(
          useSafeArea: true,
          body: RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ListView(
              padding: const EdgeInsets.all(AppSizes.m),
              children: [
                const ManagerAppHeader(
                  title: 'Duyet nhanh',
                  subtitle: 'Du lieu lay truc tiep tu manager approvals backend.',
                ),
                const SizedBox(height: AppSizes.l),
                const ManagerSectionHeader(
                  title: 'Muc can xu ly',
                  subtitle:
                      'Survey report va change request duoc lay tu approval queue cua BE.',
                ),
                const SizedBox(height: AppSizes.m),
                if (items.isEmpty)
                  const SizedBox(
                    height: 260,
                    child: EmptyState(
                      title: 'Khong co muc can xu ly',
                      description: 'Backend khong tra ve approval nao.',
                      icon: Icons.fact_check_outlined,
                    ),
                  )
                else
                  ...items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.m),
                      child: _ApprovalCard(approval: item),
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

class _ApprovalCard extends StatelessWidget {
  const _ApprovalCard({required this.approval});

  final ManagerApprovalItem approval;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      onTap: () => _open(context, approval),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  approval.title ?? approval.referenceId,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              StatusChip(
                label: approval.status?.isNotEmpty == true
                    ? approval.status!
                    : approval.approvalType,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            approval.subtitle?.isNotEmpty == true ? approval.subtitle! : '--',
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
                approval.approvalType,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                approval.orderId ?? approval.referenceId,
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

  void _open(BuildContext context, ManagerApprovalItem item) {
    if (item.approvalType == 'survey_report') {
      final taskId = item.taskId;
      if (taskId == null || taskId.isEmpty) {
        return;
      }
      Navigator.pushNamed(
        context,
        AppRoutes.managerSurveyReview,
        arguments: ManagerSurveyRouteArgs(
          taskId: taskId,
          orderId: item.orderId,
        ),
      );
      return;
    }

    if (item.approvalType == 'change_request') {
      Navigator.pushNamed(
        context,
        AppRoutes.managerChangeRequestApproval,
        arguments: ManagerChangeRequestRouteArgs(
          changeRequestId: item.referenceId,
          orderId: item.orderId,
        ),
      );
    }
  }
}
