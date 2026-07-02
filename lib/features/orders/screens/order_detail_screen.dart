import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_chip.dart';
import '../../manager/models/manager_mobile_models.dart';
import '../../manager/models/manager_route_args.dart';
import '../../manager/services/manager_mobile_service.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<_OrderDetailData> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _loadData(_resolveOrderId());
  }

  String _resolveOrderId() {
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ManagerOrderRouteArgs) {
      return args.orderId;
    }
    if (args is String) {
      return args;
    }
    return '';
  }

  Future<_OrderDetailData> _loadData(String orderId) async {
    if (orderId.isEmpty) {
      throw Exception('Không tìm thấy orderId để tải chi tiết đơn hàng.');
    }

    final order = await ManagerMobileService.getOrderDetail(orderId);
    final payments = await ManagerMobileService.getPaymentsByOrder(orderId);

    ManagerVerificationSummary? verification;
    try {
      verification = await ManagerMobileService.getVerificationSummary(orderId);
    } catch (_) {
      verification = null;
    }

    ManagerTaskSummary? surveyTask;
    try {
      surveyTask = await ManagerMobileService.getSurveyTaskByOrder(orderId);
    } catch (_) {
      surveyTask = null;
    }

    ManagerSurveyReport? surveyReport;
    if (surveyTask != null) {
      try {
        surveyReport =
            await ManagerMobileService.getSurveyReport(surveyTask.workTaskId);
      } catch (_) {
        surveyReport = null;
      }
    }

    final evidenceBundle = await ManagerMobileService.getEvidenceBundle(
      orderId: orderId,
      surveyTaskId: surveyTask?.workTaskId,
    );

    return _OrderDetailData(
      order: order,
      payments: payments,
      verification: verification,
      surveyTask: surveyTask,
      surveyReport: surveyReport,
      evidenceBundle: evidenceBundle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isManager =
        ModalRoute.of(context)?.settings.name?.contains('manager') ?? false;

    return FutureBuilder<_OrderDetailData>(
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
            appBar: const CustomAppBar(
              title: 'Chi tiết đơn hàng',
              showBackButton: true,
            ),
            body: ErrorState(
              message: snapshot.error.toString(),
            ),
          );
        }

        final data = snapshot.data!;

        return AppScaffold(
          useSafeArea: true,
          appBar: CustomAppBar(
            title: 'Chi tiết ${data.order.orderNumber}',
            showBackButton: true,
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSizes.m),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeaderCard(data.order),
                      AppSizes.spacingL,
                      if (isManager) ...[
                        _buildActionBanner(data),
                        AppSizes.spacingL,
                      ],
                      const SectionTitle(title: 'Thông tin khách hàng'),
                      AppSizes.spacingM,
                      _buildCustomerCard(data.order),
                      AppSizes.spacingL,
                      const SectionTitle(title: 'Thanh toán'),
                      AppSizes.spacingM,
                      _buildPaymentSummaryCard(data.payments),
                      AppSizes.spacingL,
                      const SectionTitle(title: 'Vận hành và tiến độ'),
                      AppSizes.spacingM,
                      _buildOperationsCard(context, isManager, data),
                      AppSizes.spacingL,
                      const SectionTitle(title: 'Minh chứng mới nhất'),
                      AppSizes.spacingM,
                      _buildEvidencePreview(data.evidenceBundle),
                      const SizedBox(height: AppSizes.xxl),
                    ],
                  ),
                ),
              ),
              if (isManager) _buildActionPanel(data),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(ManagerOrderDetail order) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MÃ ĐƠN: ${order.orderNumber}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              StatusChip(label: order.status),
            ],
          ),
          const SizedBox(height: AppSizes.s),
          Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.venueAddress ?? 'Chưa có địa điểm',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded,
                color: AppColors.textSecondary,
                size: 14,
              ),
              const SizedBox(width: 8),
              Text(
                order.eventStartDate == null
                    ? 'Ngày tổ chức: chưa có'
                    : 'Ngày tổ chức: ${order.eventStartDate!.day}/${order.eventStartDate!.month}/${order.eventStartDate!.year}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionBanner(_OrderDetailData data) {
    final hasSurvey = data.surveyTask != null;
    final hasPayments = data.payments.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gpp_maybe_rounded, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                'Tác vụ có thể xử lý',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasSurvey)
            _buildActionBannerItem(
              title: 'Xem báo cáo khảo sát thật từ task survey',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.managerSurveyReview,
                arguments: ManagerSurveyRouteArgs(
                  taskId: data.surveyTask!.workTaskId,
                  orderId: data.order.orderId,
                ),
              ),
            ),
          _buildActionBannerItem(
            title: 'Xem tiến độ field task',
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.managerFieldProgress,
              arguments: ManagerOrderRouteArgs(orderId: data.order.orderId),
            ),
          ),
          if (hasPayments)
            _buildActionBannerItem(
              title: 'Xem danh sách thanh toán',
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.managerPaymentConfirmation,
                arguments: ManagerPaymentRouteArgs(orderId: data.order.orderId),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionBannerItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            const Icon(
              Icons.arrow_right_rounded,
              color: AppColors.textPrimary,
              size: 18,
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.textSecondary,
              size: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(ManagerOrderDetail order) {
    final customer = order.customer;
    return InfoCard(
      child: Column(
        children: [
          _buildDetailRow(
            'Họ và tên',
            customer?.fullName ?? 'Chưa có dữ liệu',
            Icons.person_outline_rounded,
          ),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow(
            'Số điện thoại',
            customer?.phone ?? 'Chưa có dữ liệu',
            Icons.phone_android_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard(List<ManagerPaymentRecord> payments) {
    final totalPaid =
        payments.fold<double>(0, (sum, item) => sum + item.amount);

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số giao dịch: ${payments.length}',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tổng đã ghi nhận: ${_formatCurrency(totalPaid)}',
            style: const TextStyle(
              color: AppColors.success,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (payments.isEmpty)
            const SizedBox(
              height: 180,
              child: EmptyState(
                title: 'Chưa có thanh toán',
                description: 'Không có giao dịch nào cho đơn hàng này.',
                icon: Icons.receipt_long_outlined,
              ),
            )
          else
            ...payments.take(3).map(
                  (payment) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${payment.paymentType} - ${payment.paymentMethod.isEmpty ? 'Chưa rõ phương thức' : payment.paymentMethod}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        StatusChip(label: payment.status),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildOperationsCard(
    BuildContext context,
    bool isManager,
    _OrderDetailData data,
  ) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Survey report',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              StatusChip(
                label: data.surveyReport == null ? 'Chưa có' : 'Đã nộp',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Verification',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              StatusChip(
                label: data.verification?.verificationStatus ?? 'Chưa sẵn sàng',
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                isManager
                    ? AppRoutes.managerFieldProgress
                    : AppRoutes.fieldProgress,
                arguments: ManagerOrderRouteArgs(orderId: data.order.orderId),
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timeline_rounded,
                          color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Xem tiến trình chi tiết',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primary,
                    size: 14,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidencePreview(ManagerEvidenceBundle bundle) {
    final items = [
      ...bundle.surveyEvidences,
      ...bundle.paymentEvidences,
    ];

    if (items.isEmpty) {
      return const SizedBox(
        height: 220,
        child: EmptyState(
          title: 'Chưa có minh chứng',
          description:
              'Không có survey evidence hoặc payment evidence cho đơn hàng này.',
          icon: Icons.photo_library_outlined,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length > 4 ? 4 : items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.s,
        mainAxisSpacing: AppSizes.s,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            color: AppColors.primaryLight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const Center(
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.6),
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: Text(
                      item.fileUrl,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSizes.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionPanel(_OrderDetailData data) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'Thanh toán',
              icon: Icons.payments_outlined,
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.managerPaymentConfirmation,
                  arguments:
                      ManagerPaymentRouteArgs(orderId: data.order.orderId),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailData {
  const _OrderDetailData({
    required this.order,
    required this.payments,
    required this.verification,
    required this.surveyTask,
    required this.surveyReport,
    required this.evidenceBundle,
  });

  final ManagerOrderDetail order;
  final List<ManagerPaymentRecord> payments;
  final ManagerVerificationSummary? verification;
  final ManagerTaskSummary? surveyTask;
  final ManagerSurveyReport? surveyReport;
  final ManagerEvidenceBundle evidenceBundle;
}

String _formatCurrency(double amount) {
  return '${amount.toStringAsFixed(0)} d';
}
