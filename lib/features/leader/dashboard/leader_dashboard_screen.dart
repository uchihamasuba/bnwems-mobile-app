import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/routes/app_routes.dart';
import '../../../services/auth_service.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';
import '../../../shared/models/user_role.dart';

class LeaderDashboardScreen extends StatelessWidget {
  const LeaderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderTasks = MockData.tasks
        .where(
            (t) => t.assignedRole == UserRole.leader && t.status != 'completed')
        .toList();

    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Leader Field Dashboard',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () async {
              await AuthService.logout();
              if (!context.mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (route) => false,
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLeaderWelcome(),
            AppSizes.spacingM,
            _buildTaskSummaryBanner(leaderTasks.length),
            AppSizes.spacingL,
            const SectionTitle(title: 'Nghiệp vụ thực địa'),
            AppSizes.spacingM,
            _buildQuickActionsGrid(context),
            AppSizes.spacingL,
            const SectionTitle(title: 'Nhiệm vụ đang thực hiện'),
            AppSizes.spacingM,
            if (leaderTasks.isEmpty)
              const InfoCard(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Không có nhiệm vụ hiện trường nào được giao.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              ...leaderTasks.map((t) => _buildTaskItemCard(context, t)),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderWelcome() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: const Icon(Icons.engineering_rounded,
              color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppSizes.m),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, Phan Anh Tuấn!',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary),
              ),
              Text(
                'Leader giám sát và điều hành hiện trường',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskSummaryBanner(int count) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.assignment_turned_in_rounded,
              color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Hôm nay bạn có $count nhiệm vụ giám sát đang chờ hoàn thành.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSizes.s,
      mainAxisSpacing: AppSizes.s,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      children: [
        _buildActionCard(context, 'Báo Cáo Khảo Sát', Icons.explore_rounded,
            AppColors.info, AppRoutes.leaderSurveyReport),
        _buildActionCard(
            context,
            'Tạo Yêu Cầu Đổi',
            Icons.change_circle_rounded,
            AppColors.warning,
            AppRoutes.leaderCreateChangeRequest),
        _buildActionCard(
            context,
            'Ký Bàn Giao',
            Icons.assignment_turned_in_rounded,
            AppColors.success,
            AppRoutes.leaderHandoverReport),
        _buildActionCard(
            context,
            'Báo Hỏng / Mất',
            Icons.report_problem_rounded,
            AppColors.error,
            AppRoutes.leaderDamageLossReport),
        _buildActionCard(
            context,
            'Tải Biên Lai Cọc',
            Icons.receipt_long_rounded,
            AppColors.primary,
            AppRoutes.leaderPaymentEvidenceUpload),
        _buildActionCard(
            context,
            'Báo Cáo Hoàn Kho',
            Icons.keyboard_return_rounded,
            AppColors.secondary,
            AppRoutes.leaderWarehouseReturnReport),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, String route) {
    return InfoCard(
      borderColor: color.withOpacity(0.2),
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItemCard(BuildContext context, MobileTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s),
      child: InfoCard(
        onTap: () => Navigator.pushNamed(context, AppRoutes.leaderTaskDetail,
            arguments: task.id),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: task.priority == 'High'
                    ? AppColors.errorLight
                    : AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_late_outlined,
                color: task.priority == 'High'
                    ? AppColors.error
                    : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: AppSizes.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.taskName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đơn: ${task.orderCode} - Đơn vị: ${task.location}',
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 12, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
