import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../manager/models/manager_mobile_models.dart';
import '../../manager/models/manager_route_args.dart';
import '../../manager/services/manager_mobile_service.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  State<PaymentConfirmationScreen> createState() =>
      _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late Future<_PaymentScreenData> _future;
  String? _submittingPaymentRequestId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _loadData();
  }

  Future<_PaymentScreenData> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? paymentId;
    String? paymentRequestId;
    String? orderId;

    if (args is ManagerPaymentRouteArgs) {
      paymentId = args.paymentId;
      paymentRequestId = args.paymentRequestId;
      orderId = args.orderId;
    } else if (args is String) {
      orderId = args;
    }

    if (orderId != null && orderId.isNotEmpty) {
      final payments = await ManagerMobileService.getPaymentsByOrder(orderId);
      return _PaymentScreenData(
        orderId: orderId,
        paymentId: paymentId,
        paymentRequestId: paymentRequestId,
        payments: payments,
      );
    }

    if (paymentRequestId != null && paymentRequestId.isNotEmpty) {
      final payment =
          await ManagerMobileService.getPaymentRequestDetail(paymentRequestId);
      return _PaymentScreenData(
        orderId: null,
        paymentId: paymentId,
        paymentRequestId: paymentRequestId,
        payments: [payment],
      );
    }

    return _PaymentScreenData(
      orderId: null,
      paymentId: paymentId,
      paymentRequestId: paymentRequestId,
      payments: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PaymentScreenData>(
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
              title: 'Thanh toán',
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
          appBar: const CustomAppBar(
            title: 'Thanh toán',
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(data),
                AppSizes.spacingL,
                const SectionTitle(title: 'Danh sách giao dịch'),
                AppSizes.spacingM,
                if (data.payments.isEmpty)
                  const SizedBox(
                    height: 240,
                    child: EmptyState(
                      title: 'Không có dữ liệu giao dịch',
                      description:
                          'Hãy mở từ chi tiết đơn hàng hoặc notification payment để xem giao dịch.',
                      icon: Icons.payments_outlined,
                    ),
                  )
                else
                  ...data.payments.map(
                    (payment) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.m),
                      child: _PaymentCard(
                        payment: payment,
                        isSubmitting:
                            _submittingPaymentRequestId == payment.paymentRequestId,
                        highlighted:
                            (data.paymentRequestId != null &&
                                    data.paymentRequestId ==
                                        payment.paymentRequestId) ||
                                (data.paymentId != null &&
                                    data.paymentId == payment.paymentId),
                        onConfirmCompleted: payment.paymentRequestId == null
                            ? null
                            : () => _submitPaymentDecision(
                                  payment.paymentRequestId!,
                                  'completed',
                                ),
                        onConfirmFailed: payment.paymentRequestId == null
                            ? null
                            : () => _submitPaymentDecision(
                                  payment.paymentRequestId!,
                                  'failed',
                                ),
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

  Widget _buildHeaderCard(_PaymentScreenData data) {
    return InfoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn hàng: ${data.orderId ?? '--'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Số giao dịch: ${data.payments.length}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (data.paymentRequestId != null &&
              data.paymentRequestId!.isNotEmpty)
            StatusChip(label: data.paymentRequestId!)
          else if (data.paymentId != null && data.paymentId!.isNotEmpty)
            StatusChip(label: data.paymentId!)
          else
            const StatusChip(label: 'API'),
        ],
      ),
    );
  }

  Future<void> _submitPaymentDecision(
    String paymentRequestId,
    String status,
  ) async {
    setState(() => _submittingPaymentRequestId = paymentRequestId);
    try {
      await ManagerMobileService.confirmPayment(
        paymentRequestId: paymentRequestId,
        status: status,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'completed'
                ? 'Đã xác nhận thanh toán.'
                : 'Đã ghi nhận giao dịch thất bại.',
          ),
        ),
      );
      setState(() {
        _future = _loadData();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _submittingPaymentRequestId = null);
      }
    }
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.payment,
    required this.highlighted,
    required this.isSubmitting,
    this.onConfirmCompleted,
    this.onConfirmFailed,
  });

  final ManagerPaymentRecord payment;
  final bool highlighted;
  final bool isSubmitting;
  final VoidCallback? onConfirmCompleted;
  final VoidCallback? onConfirmFailed;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      borderColor:
          highlighted ? AppColors.primary.withValues(alpha: 0.32) : null,
      color:
          highlighted ? AppColors.primaryLight.withValues(alpha: 0.35) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Giao dịch ${payment.paymentId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusChip(
                label:
                    payment.status.isEmpty ? 'Chưa xác định' : payment.status,
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DetailRow(label: 'Loại', value: payment.paymentType),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Số tiền',
            value: payment.amount.toStringAsFixed(0),
          ),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Phương thức',
            value: payment.paymentMethod.isEmpty ? '--' : payment.paymentMethod,
          ),
          const SizedBox(height: 8),
          _DetailRow(
            label: 'Ngày ghi nhận',
            value: payment.paymentDate == null
                ? '--'
                : '${payment.paymentDate!.day}/${payment.paymentDate!.month}/${payment.paymentDate!.year}',
          ),
          if (payment.paymentRequestId != null &&
              payment.paymentRequestId!.isNotEmpty &&
              payment.status.toLowerCase() == 'pending') ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Thất bại',
                    icon: Icons.close_rounded,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : onConfirmFailed,
                  ),
                ),
                const SizedBox(width: AppSizes.s),
                Expanded(
                  child: PrimaryButton(
                    text: 'Xác nhận',
                    icon: Icons.check_rounded,
                    isLoading: isSubmitting,
                    onPressed: isSubmitting ? null : onConfirmCompleted,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentScreenData {
  const _PaymentScreenData({
    required this.orderId,
    required this.paymentId,
    required this.paymentRequestId,
    required this.payments,
  });

  final String? orderId;
  final String? paymentId;
  final String? paymentRequestId;
  final List<ManagerPaymentRecord> payments;
}
