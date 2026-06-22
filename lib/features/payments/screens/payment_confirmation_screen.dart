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
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/payment_status.dart';
import '../../../shared/models/core_models.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late PaymentConfirmation _payment;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    _loadPayment(args);
  }

  void _loadPayment(String? paymentId) {
    if (paymentId != null) {
      _payment = MockData.paymentConfirmations.firstWhere(
        (p) => p.id == paymentId,
        orElse: () => MockData.paymentConfirmations.first,
      );
    } else {
      // Find first pending or fallback to first
      _payment = MockData.paymentConfirmations.firstWhere(
        (p) => p.status == 'Pending',
        orElse: () => MockData.paymentConfirmations.first,
      );
    }
  }

  void _updateStatus(String newStatus, String snackBarMessage) {
    setState(() {
      _payment.status = newStatus;

      // If approved, update order financial status & overall state in mock data
      if (newStatus == 'Approved') {
        final orderIdx = MockData.orders.indexWhere((o) => o.id == _payment.orderCode);
        if (orderIdx != -1) {
          final o = MockData.orders[orderIdx];
          final newPaid = o.paidAmount + _payment.paidAmount;
          
          OrderStatus newOrderStatus = o.orderStatus;
          PaymentStatus newPaymentStatus = o.paymentStatus;
          
          if (_payment.paymentType == 'Deposit') {
            newOrderStatus = OrderStatus.deposited;
            newPaymentStatus = PaymentStatus.partiallyPaid;
          } else if (_payment.paymentType == 'Final Payment' || newPaid >= o.totalAmount) {
            newOrderStatus = OrderStatus.closed;
            newPaymentStatus = PaymentStatus.paid;
          }

          MockData.orders[orderIdx] = o.copyWith(
            paidAmount: newPaid > o.totalAmount ? o.totalAmount : newPaid,
            orderStatus: newOrderStatus,
            paymentStatus: newPaymentStatus,
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(snackBarMessage)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

    String formatPrice(double price) {
      return '${price.toStringAsFixed(0).replaceAllMapped(currencyFormat, (Match m) => '${m[1]},')} đ';
    }

    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Xác nhận cọc/quyết toán',
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

                  const SectionTitle(title: 'Thông tin giao dịch'),
                  AppSizes.spacingM,
                  _buildTransactionCard(formatPrice),
                  AppSizes.spacingL,

                  const SectionTitle(title: 'Ảnh chụp biên lai chuyển khoản'),
                  AppSizes.spacingM,
                  _buildReceiptImageCard(),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
          if (_payment.status == 'Pending') _buildActionPanel(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return InfoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biên lai: ${_payment.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Khách: ${_payment.customerName} - Đơn: ${_payment.orderCode}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusChip(label: _payment.status),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(String Function(double) formatPrice) {
    return InfoCard(
      child: Column(
        children: [
          _buildDetailRow('Loại thanh toán', _payment.paymentType),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow('Số tiền yêu cầu', formatPrice(_payment.requiredAmount)),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow('Số tiền thực chuyển', formatPrice(_payment.paidAmount), valueColor: AppColors.success),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow('Phương thức chuyển', _payment.paymentMethod),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow('Người gửi báo cáo', _payment.submittedBy),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow(
            'Thời gian báo cáo',
            '${_payment.submittedAt.hour}:${_payment.submittedAt.minute.toString().padLeft(2, '0')} - ${_payment.submittedAt.day}/${_payment.submittedAt.month}',
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptImageCard() {
    return InfoCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        child: Container(
          height: 320,
          color: AppColors.primaryLight.withOpacity(0.4),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.document_scanner_outlined, color: AppColors.primary, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      _payment.evidenceUrl,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Chạm để xem ảnh đầy đủ phóng to',
                      style: TextStyle(fontSize: 11, color: AppColors.textLight, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user, color: AppColors.success, size: 12),
                      SizedBox(width: 4),
                      Text('E-RECEIPT MATCH', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: 'Yêu cầu gửi lại ảnh',
              icon: Icons.sync_problem_outlined,
              onPressed: () => _updateStatus('Needs Evidence', 'Đã yêu cầu khách hàng/Leader chụp lại ảnh minh chứng rõ nét hơn.'),
            ),
          ),
          const SizedBox(width: AppSizes.s),
          Expanded(
            child: PrimaryButton(
              text: 'Xác nhận khớp tiền',
              icon: Icons.check_circle_outline,
              onPressed: () => _updateStatus('Approved', 'Biên lai đã được duyệt. Đã ghi nhận số tiền thanh toán!'),
            ),
          ),
        ],
      ),
    );
  }
}
