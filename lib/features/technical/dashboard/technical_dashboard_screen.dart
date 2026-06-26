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

class TechnicalDashboardScreen extends StatelessWidget {
  const TechnicalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final myTasks = MockData.tasks
        .where((t) => t.assignedRole == UserRole.technical && t.status != 'completed')
        .toList();

    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Technical Dashboard',
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
            _buildTechWelcome(),
            AppSizes.spacingM,
            _buildTaskSummaryBanner(myTasks.length),
            AppSizes.spacingL,

            const SectionTitle(title: 'Nhiệm vụ thi công hiện trường'),
            AppSizes.spacingM,
            _buildQuickActionsGrid(context),
            AppSizes.spacingL,

            const SectionTitle(title: 'Checklist cần xử lý gấp'),
            AppSizes.spacingM,
            if (myTasks.isEmpty)
              const InfoCard(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      'Tất cả công việc đã hoàn thành. Hãy nghỉ ngơi!',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              )
            else
              ...myTasks.map((t) => _buildTaskItemCard(context, t)),
            const SizedBox(height: AppSizes.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTechWelcome() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: const Icon(Icons.construction_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppSizes.m),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, Nguyễn Văn Minh!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                'Kỹ thuật viên / Thợ sự kiện',
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
          const Icon(Icons.engineering_outlined, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bạn còn $count công việc kỹ thuật cần chuẩn bị & hoàn thành.',
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
        _buildActionCard(context, 'Soạn Đồ Xuất Kho', Icons.inventory_outlined, AppColors.info, AppRoutes.technicalPickList),
        _buildActionCard(context, 'Báo Cáo Vận Chuyển', Icons.local_shipping_outlined, AppColors.primary, AppRoutes.technicalTransportation),
        _buildActionCard(context, 'Thi Công Lắp Ráp', Icons.build_outlined, AppColors.warning, AppRoutes.technicalInstallationChecklist),
        _buildActionCard(context, 'Tháo Dỡ Thu Hồi', Icons.backspace_outlined, AppColors.error, AppRoutes.technicalCollectionChecklist),
        _buildActionCard(context, 'Hoàn Trả Kho', Icons.warehouse_outlined, AppColors.success, AppRoutes.technicalWarehouseReturn),
        _buildActionCard(context, 'Nộp Ảnh Thực Địa', Icons.add_a_photo_outlined, AppColors.secondary, AppRoutes.technicalEvidenceUpload),
      ],
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, String route) {
    return InfoCard(
      borderColor: color.withOpacity(0.2),
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 18),
          ),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItemCard(BuildContext context, MobileTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.s),
      child: InfoCard(
        onTap: () => Navigator.pushNamed(context, AppRoutes.technicalTaskDetail, arguments: task.id),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.construction_outlined,
                color: AppColors.primary,
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
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Đơn: ${task.orderCode} - Nơi: ${task.location}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
