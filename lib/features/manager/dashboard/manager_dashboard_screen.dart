import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/core_models.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayOrdersCount = MockData.orders.where((o) => o.orderStatus != OrderStatus.closed && o.orderStatus != OrderStatus.cancelled).length;
    final pendingSurveys = MockData.surveyReports.where((r) => r.approvalStatus == 'Pending').toList();
    final pendingChanges = MockData.changeRequests.where((cr) => cr.approvalStatus == 'Pending').toList();
    final pendingPayments = MockData.paymentConfirmations.where((p) => p.status == 'Pending').toList();
    final totalPendingApprovals = pendingSurveys.length + pendingChanges.length + pendingPayments.length;

    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Manager Mobile App',
        showBackButton: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWelcomeHeader(),
            AppSizes.spacingM,
            
            // Emergency Alert Box if there are critical pending tasks/warnings
            _buildEmergencyAlertBox(),
            AppSizes.spacingL,

            const SectionTitle(title: 'Công việc cần duyệt gấp'),
            AppSizes.spacingM,
            _buildActionStatsGrid(
              todayOrders: todayOrdersCount,
              surveys: pendingSurveys.length,
              changes: pendingChanges.length,
              payments: pendingPayments.length,
            ),
            AppSizes.spacingL,

            // Quick navigation panel
            const SectionTitle(title: 'Lối tắt điều hành'),
            AppSizes.spacingM,
            _buildQuickActions(context),
            AppSizes.spacingL,

            // Lists of pending action items
            if (totalPendingApprovals > 0) ...[
              const SectionTitle(title: 'Danh sách hồ sơ chờ duyệt'),
              AppSizes.spacingM,
              ...pendingSurveys.map((survey) => _buildSurveyPendingCard(context, survey)),
              const SizedBox(height: 8),
              ...pendingChanges.map((cr) => _buildChangePendingCard(context, cr)),
              const SizedBox(height: 8),
              ...pendingPayments.map((p) => _buildPaymentPendingCard(context, p)),
              const SizedBox(height: AppSizes.xl),
            ] else ...[
              const InfoCard(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Tất cả hồ sơ hiện trường đã được xử lý hoàn thành!',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.xl),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primaryLight,
          child: const Icon(Icons.support_agent_rounded, color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: AppSizes.m),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Xin chào, Manager!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                'Ứng dụng di động duyệt khẩn cấp',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmergencyAlertBox() {
    final delayedTasks = MockData.notifications.where((n) => n.priority == 'High').toList();
    if (delayedTasks.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: AppColors.errorLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cảnh báo khẩn cấp hiện trường (${delayedTasks.length})',
                  style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  delayedTasks.first.message,
                  style: TextStyle(color: AppColors.error.withOpacity(0.9), fontSize: 12, height: 1.4),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionStatsGrid({
    required int todayOrders,
    required int surveys,
    required int changes,
    required int payments,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppSizes.m,
      mainAxisSpacing: AppSizes.m,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _buildStatCard('Khảo sát chờ duyệt', '$surveys', Icons.explore_outlined, AppColors.info, surveys > 0),
        _buildStatCard('Đổi thiết bị chờ duyệt', '$changes', Icons.change_circle_outlined, AppColors.warning, changes > 0),
        _buildStatCard('Biên lai chờ duyệt', '$payments', Icons.payments_outlined, AppColors.success, payments > 0),
        _buildStatCard('Đơn hàng vận hành', '$todayOrders', Icons.local_shipping_outlined, AppColors.primary, todayOrders > 0),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color, bool highlight) {
    return InfoCard(
      color: highlight ? color.withOpacity(0.04) : Colors.white,
      borderColor: highlight ? color.withOpacity(0.4) : AppColors.divider,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, color: color, size: 18),
            ],
          ),
          Text(
            count,
            style: TextStyle(
              color: highlight ? color : AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return InfoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(context, 'Hôm nay', Icons.today_rounded, AppRoutes.managerToday),
          _buildQuickActionItem(context, 'Bộ ảnh', Icons.photo_library_outlined, AppRoutes.managerEvidenceGallery),
          _buildQuickActionItem(context, 'Yêu cầu đổi', Icons.published_with_changes_rounded, AppRoutes.managerChangeRequestApproval),
          _buildQuickActionItem(context, 'Xác nhận cọc', Icons.account_balance_wallet_outlined, AppRoutes.managerPaymentConfirmation),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem(BuildContext context, String label, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withOpacity(0.6),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyPendingCard(BuildContext context, SurveyReport survey) {
    return InfoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.managerSurveyReview, arguments: survey.orderCode),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.infoLight, shape: BoxShape.circle),
            child: const Icon(Icons.explore_rounded, color: AppColors.info, size: 20),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Báo cáo khảo sát chờ duyệt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('Đơn: ${survey.orderCode} - Khách: ${survey.customerName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          StatusChip(label: survey.approvalStatus),
        ],
      ),
    );
  }

  Widget _buildChangePendingCard(BuildContext context, ChangeRequest cr) {
    return InfoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.managerChangeRequestApproval, arguments: cr.id),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.warningLight, shape: BoxShape.circle),
            child: const Icon(Icons.change_circle_rounded, color: AppColors.warning, size: 20),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Yêu cầu đổi thiết bị', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${cr.requestType}: ${cr.itemName} (x${cr.quantity})', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          StatusChip(label: cr.approvalStatus),
        ],
      ),
    );
  }

  Widget _buildPaymentPendingCard(BuildContext context, PaymentConfirmation payment) {
    return InfoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.managerPaymentConfirmation, arguments: payment.id),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(color: AppColors.successLight, shape: BoxShape.circle),
            child: const Icon(Icons.payments_rounded, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Xác nhận thanh toán', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text('${payment.paymentType} - Khách: ${payment.customerName}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          StatusChip(label: payment.status),
        ],
      ),
    );
  }
}
