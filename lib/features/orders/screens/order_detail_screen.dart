import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/routes/app_routes.dart';
import '../../manager/models/manager_route_args.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/core_models.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late MobileOrder _order;
  String _orderId = 'ORD-2026-001';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ManagerOrderRouteArgs) {
      _orderId = args.orderId;
    } else if (args is String) {
      _orderId = args;
    }
    _loadOrderData();
  }

  void _loadOrderData() {
    _order = MockData.orders.firstWhere(
      (o) => o.id == _orderId,
      orElse: () => MockData.orders.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isManager = ModalRoute.of(context)?.settings.name?.contains('manager') ?? false;

    final relatedEvidence = MockData.evidenceItems
        .where((item) => item.orderCode == _order.id)
        .toList();

    final hasPendingSurvey = MockData.surveyReports.any(
      (r) => r.orderCode == _order.id && r.approvalStatus == 'Pending',
    );
    final hasPendingChange = MockData.changeRequests.any(
      (cr) => cr.orderCode == _order.id && cr.approvalStatus == 'Pending',
    );
    final pendingPayment = MockData.paymentConfirmations.cast<dynamic>().firstWhere(
      (p) => p.orderCode == _order.id && p.status == 'Pending',
      orElse: () => null,
    );

    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Chi tiết ${_order.id}',
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
                  _buildHeaderCard(),
                  AppSizes.spacingL,

                  // Important action notifications (only visible for Manager or if action is pending)
                  if (isManager && (hasPendingSurvey || hasPendingChange || pendingPayment != null)) ...[
                    _buildUrgentActionBanner(
                      hasPendingSurvey: hasPendingSurvey,
                      hasPendingChange: hasPendingChange,
                      hasPendingPayment: pendingPayment != null,
                    ),
                    AppSizes.spacingL,
                  ],

                  const SectionTitle(title: 'Thông tin khách hàng'),
                  AppSizes.spacingM,
                  _buildCustomerCard(),
                  AppSizes.spacingL,

                  const SectionTitle(title: 'Tổng chi phí & Thanh toán'),
                  AppSizes.spacingM,
                  _buildPaymentSummaryCard(),
                  AppSizes.spacingL,

                  const SectionTitle(title: 'Vận hành & Tiến độ hiện trường'),
                  AppSizes.spacingM,
                  _buildOperationsCard(isManager),
                  AppSizes.spacingL,

                  const SectionTitle(title: 'Minh chứng hiện trường mới nhất'),
                  AppSizes.spacingM,
                  _buildEvidencePreview(relatedEvidence),
                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ),
          if (isManager) _buildActionPanel(pendingPayment != null),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MÃ ĐƠN: ${_order.id}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              StatusChip(label: _order.orderStatus.displayName),
            ],
          ),
          const SizedBox(height: AppSizes.s),
          Row(
            children: [
              const Icon(Icons.location_on_rounded, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _order.location,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, color: AppColors.textSecondary, size: 14),
              const SizedBox(width: 8),
              Text(
                'Ngày tổ chức: ${_order.eventDateTime.day}/${_order.eventDateTime.month}/${_order.eventDateTime.year}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded, color: AppColors.textSecondary, size: 16),
              const SizedBox(width: 8),
              Text(
                'Phụ trách hiện trường: ${_order.leaderStaffName}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (_order.urgencyMessage != null) ...[
            const Divider(height: 24, color: AppColors.divider),
            Container(
              padding: const EdgeInsets.all(AppSizes.s),
              decoration: BoxDecoration(
                color: AppColors.errorLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _order.urgencyMessage!,
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUrgentActionBanner({
    required bool hasPendingSurvey,
    required bool hasPendingChange,
    required bool hasPendingPayment,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: AppColors.warningLight.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.gpp_maybe_rounded, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                'Yêu cầu cần phê duyệt',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (hasPendingSurvey)
            _buildActionBannerItem(
              title: 'Báo cáo khảo sát thực địa chờ duyệt',
              onTap: () => Navigator.pushNamed(context, AppRoutes.managerSurveyReview, arguments: _order.id),
            ),
          if (hasPendingChange)
            _buildActionBannerItem(
              title: 'Yêu cầu đổi thiết bị/vật tư phát sinh',
              onTap: () => Navigator.pushNamed(context, AppRoutes.managerChangeRequestApproval, arguments: _order.id),
            ),
          if (hasPendingPayment)
            _buildActionBannerItem(
              title: 'Biên lai chuyển khoản cọc/thanh toán cần xác nhận',
              onTap: () => Navigator.pushNamed(context, AppRoutes.managerPaymentConfirmation, arguments: _order.id),
            ),
        ],
      ),
    );
  }

  Widget _buildActionBannerItem({required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            const Icon(Icons.arrow_right_rounded, color: AppColors.textPrimary, size: 18),
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
            const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textSecondary, size: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return InfoCard(
      child: Column(
        children: [
          _buildDetailRow('Họ và tên', _order.customerName, Icons.person_outline_rounded),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow('Số điện thoại', _order.customerPhone, Icons.phone_android_rounded),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow('Địa chỉ Email', 'khachhang@gmail.com', Icons.mail_outline_rounded),
        ],
      ),
    );
  }

  Widget _buildPaymentSummaryCard() {
    return InfoCard(
      child: Column(
        children: [
          _buildFinanceRow('Tổng giá trị hợp đồng', _order.totalAmount, isBold: true),
          const SizedBox(height: 8),
          _buildFinanceRow('Khách đã thanh toán', _order.paidAmount, valueColor: AppColors.success),
          const Divider(height: 24, color: AppColors.divider),
          _buildFinanceRow(
            'Còn lại cần thu',
            _order.balanceDue,
            isBold: true,
            valueColor: _order.balanceDue > 0 ? AppColors.warning : AppColors.success,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trạng thái thanh toán', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              StatusChip(label: _order.paymentStatus.name.toUpperCase()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOperationsCard(bool isManager) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Khảo sát hiện trường', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              StatusChip(label: _order.surveyStatus),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Trạng thái thi công', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              StatusChip(label: _order.fieldProgressStatus),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          InkWell(
            onTap: () {
              Navigator.pushNamed(
                context,
                isManager ? AppRoutes.managerFieldProgress : AppRoutes.fieldProgress,
                arguments: _order.id,
              );
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timeline_rounded, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Xem tiến trình chi tiết (Timeline)',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primary, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidencePreview(List<EvidenceItem> items) {
    if (items.isEmpty) {
      return const InfoCard(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Center(
            child: Text(
              'Chưa có ảnh minh chứng được gửi lên.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ),
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
                _buildMockImage(item.imageUrl),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      item.title,
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

  Widget _buildMockImage(String imageName) {
    return Container(
      color: AppColors.primaryLight.withOpacity(0.6),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined, color: AppColors.primary, size: 20),
            const SizedBox(height: 2),
            Text(
              imageName,
              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
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
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildFinanceRow(String label, double val, {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          '${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} đ',
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary,
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildActionPanel(bool hasPendingPayment) {
    List<Widget> buttons = [];

    if (_order.orderStatus == OrderStatus.pendingDeposit) {
      buttons.add(
        Expanded(
          child: PrimaryButton(
            text: 'Duyệt đặt cọc sự kiện',
            icon: Icons.check_circle_outline,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.managerPaymentConfirmation, arguments: _order.id);
            },
          ),
        ),
      );
    } else if (_order.orderStatus == OrderStatus.deposited) {
      buttons.add(
        Expanded(
          child: PrimaryButton(
            text: 'Kích hoạt thi công',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              setState(() {
                final idx = MockData.orders.indexWhere((o) => o.id == _order.id);
                if (idx != -1) {
                  MockData.orders[idx] = _order.copyWith(
                    orderStatus: OrderStatus.executing,
                    fieldProgressStatus: 'Installation',
                  );
                  _loadOrderData();
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sự kiện đã bắt đầu thi công lắp đặt!')),
              );
            },
          ),
        ),
      );
    } else if (_order.orderStatus == OrderStatus.executing) {
      buttons.add(
        Expanded(
          child: PrimaryButton(
            text: 'Duyệt Change Request',
            icon: Icons.published_with_changes_rounded,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.managerChangeRequestApproval, arguments: _order.id);
            },
          ),
        ),
      );
      buttons.add(const SizedBox(width: AppSizes.s));
      buttons.add(
        Expanded(
          child: SecondaryButton(
            text: 'Quyết toán',
            icon: Icons.account_balance_wallet_outlined,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.managerPaymentConfirmation, arguments: _order.id);
            },
          ),
        ),
      );
    } else if (_order.orderStatus == OrderStatus.handedOver) {
      buttons.add(
        Expanded(
          child: PrimaryButton(
            text: 'Xác nhận quyết toán',
            icon: Icons.check_circle_outline,
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.managerPaymentConfirmation, arguments: _order.id);
            },
          ),
        ),
      );
    } else {
      buttons.add(
        const Expanded(
          child: Center(
            child: Text(
              'Đơn hàng đã hoàn tất vận hành.',
              style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontSize: 13),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(children: buttons),
    );
  }
}
