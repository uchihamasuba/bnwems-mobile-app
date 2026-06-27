import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../shared/mock/mock_data.dart';
import '../widgets/manager_app_header.dart';
import '../widgets/manager_priority_badge.dart';
import '../widgets/manager_section_header.dart';

class ManagerApprovalsScreen extends StatelessWidget {
  const ManagerApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final surveyItems = MockData.surveyReports
        .where((item) => item.approvalStatus == 'Pending')
        .toList();
    final changeItems = MockData.changeRequests
        .where((item) => item.approvalStatus == 'Pending')
        .toList();
    final paymentItems = MockData.paymentConfirmations
        .where((item) => item.status == 'Pending')
        .toList();

    return AppScaffold(
      useSafeArea: true,
      body: ListView(
        padding: const EdgeInsets.all(AppSizes.m),
        children: [
          const ManagerAppHeader(
            title: 'Duyệt nhanh',
            subtitle:
                'Tập trung các yêu cầu quan trọng để Manager xác nhận ngay trên điện thoại.',
          ),
          const SizedBox(height: AppSizes.l),
          const ManagerSectionHeader(
            title: 'Danh sách chờ xử lý',
            subtitle: 'Ưu tiên các mục ảnh hưởng trực tiếp tới vận hành và thanh toán.',
          ),
          const SizedBox(height: AppSizes.m),
          if (surveyItems.isEmpty && changeItems.isEmpty && paymentItems.isEmpty)
            const SizedBox(
              height: 320,
              child: EmptyState(
                title: 'Không có yêu cầu chờ duyệt',
                description: 'Tất cả báo cáo, phát sinh và thanh toán đã được xử lý.',
                icon: Icons.verified_rounded,
              ),
            ),
          ...surveyItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.m),
              child: _ApprovalCard(
                title: 'Báo cáo khảo sát',
                subtitle: '${item.orderCode} • ${item.customerName}',
                description: item.notes,
                priority: 'Khẩn cấp',
                sender: item.leaderStaffName,
                timestamp:
                    '${item.surveyDate.hour.toString().padLeft(2, '0')}:${item.surveyDate.minute.toString().padLeft(2, '0')}',
                onView: () => Navigator.pushNamed(
                  context,
                  AppRoutes.managerSurveyReview,
                  arguments: item.orderCode,
                ),
              ),
            ),
          ),
          ...changeItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.m),
              child: _ApprovalCard(
                title: 'Phát sinh hiện trường',
                subtitle: '${item.orderCode} • ${item.itemName}',
                description: item.reason,
                priority: 'Ảnh hưởng chi phí',
                sender: item.noteFromLeader,
                timestamp: 'Mới cập nhật',
                onView: () => Navigator.pushNamed(
                  context,
                  AppRoutes.managerChangeRequestApproval,
                  arguments: item.id,
                ),
              ),
            ),
          ),
          ...paymentItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.m),
              child: _ApprovalCard(
                title: 'Xác nhận thanh toán',
                subtitle: '${item.orderCode} • ${item.customerName}',
                description:
                    '${item.paymentType} • ${item.paidAmount.toStringAsFixed(0)} đ',
                priority: 'Cần xác minh',
                sender: item.submittedBy,
                timestamp:
                    '${item.submittedAt.hour.toString().padLeft(2, '0')}:${item.submittedAt.minute.toString().padLeft(2, '0')}',
                onView: () => Navigator.pushNamed(
                  context,
                  AppRoutes.managerPaymentConfirmation,
                  arguments: item.id,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
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
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: SizedBox.shrink(),
              ),
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
                  'Người gửi: $sender',
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
                  text: 'Từ chối',
                  icon: Icons.close_rounded,
                  onPressed: () => _showConfirmSheet(
                    context,
                    title: 'Xác nhận từ chối',
                    description: 'Bạn có chắc muốn từ chối yêu cầu này không?',
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.s),
              Expanded(
                child: PrimaryButton(
                  text: 'Xem chi tiết',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: onView,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmSheet(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusExtraLarge),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.l,
            AppSizes.l,
            AppSizes.l,
            AppSizes.l,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSizes.l),
              SizedBox(
                width: double.infinity,
                child: SecondaryButton(
                  text: 'Đóng',
                  icon: Icons.check_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
