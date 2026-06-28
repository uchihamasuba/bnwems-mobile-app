import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../../core/widgets/status_chip.dart';
import '../../manager/models/manager_mobile_models.dart';
import '../../manager/models/manager_route_args.dart';
import '../../manager/services/manager_mobile_service.dart';
import '../../manager/widgets/manager_backend_gap_card.dart';

class PaymentConfirmationScreen extends StatefulWidget {
  const PaymentConfirmationScreen({super.key});

  @override
  State<PaymentConfirmationScreen> createState() => _PaymentConfirmationScreenState();
}

class _PaymentConfirmationScreenState extends State<PaymentConfirmationScreen> {
  late Future<_PaymentScreenData> _future;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _loadData();
  }

  Future<_PaymentScreenData> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? paymentId;
    String? orderId;

    if (args is ManagerPaymentRouteArgs) {
      paymentId = args.paymentId;
      orderId = args.orderId;
    } else if (args is String) {
      orderId = args;
    }

    if (orderId != null && orderId.isNotEmpty) {
      final payments = await ManagerMobileService.getPaymentsByOrder(orderId);
      ManagerPaymentRecord? selected;
      if (paymentId == null || paymentId.isEmpty) {
        selected = payments.isNotEmpty ? payments.first : null;
      } else {
        for (final item in payments) {
          if (item.paymentId == paymentId) {
            selected = item;
            break;
          }
        }
        selected ??= payments.isNotEmpty ? payments.first : null;
      }

      return _PaymentScreenData(
        orderId: orderId,
        paymentId: paymentId,
        payment: selected,
      );
    }

    if (paymentId != null && paymentId.isNotEmpty) {
      return _PaymentScreenData(
        orderId: null,
        paymentId: paymentId,
        payment: null,
      );
    }

    throw Exception(
      'Khong tim thay orderId/paymentId de tai man hinh thanh toan.',
    );
  }

  Future<void> _confirmPayment(_PaymentScreenData data) async {
    final payment = data.payment;
    if (payment == null) {
      return;
    }

    try {
      await ManagerMobileService.confirmPayment(
        paymentId: payment.paymentId,
        status: 'completed',
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Da goi API confirm payment thanh cong.')),
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
    }
  }

  void _showMissingProofApi() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Backend chua co payment detail/proof API day du cho luong manager review.',
        ),
      ),
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
              title: 'Xac nhan thanh toan',
              showBackButton: true,
            ),
            body: ErrorState(
              message: snapshot.error.toString(),
            ),
          );
        }

        final data = snapshot.data!;
        final payment = data.payment;

        return AppScaffold(
          useSafeArea: true,
          appBar: const CustomAppBar(
            title: 'Xac nhan coc/quyet toan',
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
                      _buildHeaderCard(data),
                      AppSizes.spacingL,
                      const SectionTitle(title: 'Thong tin giao dich'),
                      AppSizes.spacingM,
                      _buildTransactionCard(payment, data),
                      AppSizes.spacingL,
                      const SectionTitle(title: 'Payment proof'),
                      AppSizes.spacingM,
                      _buildReceiptImageCard(payment, data),
                      const SizedBox(height: AppSizes.xl),
                    ],
                  ),
                ),
              ),
              if (payment != null) _buildActionPanel(data),
            ],
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
                  'Payment: ${data.payment?.paymentId ?? data.paymentId ?? 'Unknown'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order: ${data.orderId ?? 'Chua xac dinh'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusChip(label: data.payment?.status ?? 'No detail'),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(
    ManagerPaymentRecord? payment,
    _PaymentScreenData data,
  ) {
    if (payment == null) {
      return const ManagerBackendGapCard(
        title: 'Khong tai duoc payment detail',
        message:
            'Neu chi co paymentId ma khong co orderId thi mobile chua doc duoc chi tiet, vi backend chua co GET /payments/:id hoac GET /payment-requests/:id.',
      );
    }

    return InfoCard(
      child: Column(
        children: [
          _buildDetailRow('Loai thanh toan', payment.paymentType),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow('So tien', '${payment.amount.toStringAsFixed(0)}'),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow(
            'Phuong thuc',
            payment.paymentMethod.isEmpty ? 'Chua co' : payment.paymentMethod,
          ),
          const Divider(height: 20, color: AppColors.divider),
          _buildDetailRow(
            'Ngay ghi nhan',
            payment.paymentDate == null
                ? 'Chua co'
                : '${payment.paymentDate!.day}/${payment.paymentDate!.month}/${payment.paymentDate!.year}',
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptImageCard(
    ManagerPaymentRecord? payment,
    _PaymentScreenData data,
  ) {
    if (payment == null || payment.evidences.isEmpty) {
      return const ManagerBackendGapCard(
        title: 'Chua co proof image de manager review',
        message:
            'GET /orders/:id/payments hien chua tra proof image/evidence day du. Backend can bo sung payment detail hoac payment proof endpoint.',
      );
    }

    final evidence = payment.evidences.first;
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
                    const Icon(
                      Icons.document_scanner_outlined,
                      color: AppColors.primary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        evidence.fileUrl,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionPanel(_PaymentScreenData data) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: 'Proof chua du',
              icon: Icons.sync_problem_outlined,
              onPressed: _showMissingProofApi,
            ),
          ),
          const SizedBox(width: AppSizes.s),
          Expanded(
            child: PrimaryButton(
              text: 'Xac nhan payment',
              icon: Icons.check_circle_outline,
              onPressed: () => _confirmPayment(data),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentScreenData {
  const _PaymentScreenData({
    required this.orderId,
    required this.paymentId,
    required this.payment,
  });

  final String? orderId;
  final String? paymentId;
  final ManagerPaymentRecord? payment;
}
