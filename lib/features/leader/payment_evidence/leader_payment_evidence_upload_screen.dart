import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';

class LeaderPaymentEvidenceUploadScreen extends StatefulWidget {
  const LeaderPaymentEvidenceUploadScreen({super.key});

  @override
  State<LeaderPaymentEvidenceUploadScreen> createState() =>
      _LeaderPaymentEvidenceUploadScreenState();
}

class _LeaderPaymentEvidenceUploadScreenState
    extends State<LeaderPaymentEvidenceUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOrder = 'ORD-2026-002';
  String _paymentType = 'Deposit';
  String _paymentMethod = 'Chuyển khoản Vietcombank';
  final _amountController = TextEditingController(text: '30000000.0');
  final _noteController = TextEditingController(
      text: 'Khách hàng chuyển khoản cọc online thành công.');
  String _evidencePhoto = 'evidence_receipt_deposit_uploaded';
  bool _isSubmitting = false;

  void _submitPaymentEvidence() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        MockData.paymentConfirmations.add(
          PaymentConfirmation(
            id: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
            orderCode: _selectedOrder,
            customerName: 'Khách hàng $_selectedOrder',
            paymentType: _paymentType,
            requiredAmount: double.tryParse(_amountController.text) ?? 0.0,
            paidAmount: double.tryParse(_amountController.text) ?? 0.0,
            paymentMethod: _paymentMethod,
            evidenceUrl: _evidencePhoto,
            submittedBy: 'Phan Anh Tuấn (Leader)',
            submittedAt: DateTime.now(),
            status: 'Pending',
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Minh chứng thanh toán đã được gửi Manager xác nhận!')),
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Tải minh chứng thanh toán',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.m),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Chọn đơn hàng sự kiện:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildOrderDropdown(),
                    AppSizes.spacingL,
                    const Text('Thông tin thanh toán:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildPaymentInfoCard(),
                    AppSizes.spacingL,
                    const Text('Ảnh chụp biên lai chuyển khoản:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildEvidenceCard(),
                    const SizedBox(height: AppSizes.xxl),
                  ],
                ),
              ),
            ),
          ),
          _buildActionPanel(),
        ],
      ),
    );
  }

  Widget _buildOrderDropdown() {
    return InfoCard(
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: _selectedOrder,
        style: const TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        items: MockData.orders.map((order) {
          return DropdownMenuItem(
            value: order.id,
            child: Text(
              '${order.id} - ${order.customerName}',
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _selectedOrder = val;
            });
          }
        },
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildPaymentInfoCard() {
    return InfoCard(
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _paymentType,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            items: const [
              DropdownMenuItem(
                  value: 'Deposit',
                  child: Text('Đặt cọc sự kiện (Deposit)',
                      overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(
                  value: 'Final Payment',
                  child: Text('Quyết toán hợp đồng (Final Payment)',
                      overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _paymentType = val;
                });
              }
            },
            decoration: const InputDecoration(labelText: 'Loại thanh toán'),
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Số tiền nộp (VNĐ)', prefixText: 'đ '),
            validator: (val) =>
                val == null || val.isEmpty ? 'Không để trống số tiền' : null,
          ),
          const SizedBox(height: AppSizes.m),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: _paymentMethod,
            style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            items: const [
              DropdownMenuItem(
                  value: 'Chuyển khoản Vietcombank',
                  child: Text('Chuyển khoản nhanh Vietcombank',
                      overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(
                  value: 'Chuyển khoản MBBank',
                  child: Text('Chuyển khoản nhanh MBBank',
                      overflow: TextOverflow.ellipsis)),
              DropdownMenuItem(
                  value: 'Tiền mặt tại chỗ',
                  child: Text('Nhận tiền mặt tại hiện trường',
                      overflow: TextOverflow.ellipsis)),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() {
                  _paymentMethod = val;
                });
              }
            },
            decoration:
                const InputDecoration(labelText: 'Phương thức thanh toán'),
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _noteController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Ghi chú thanh toán'),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceCard() {
    return InfoCard(
      child: InkWell(
        onTap: () {
          setState(() {
            _evidencePhoto =
                'evidence_receipt_uploaded_${DateTime.now().millisecondsSinceEpoch}';
          });
        },
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withOpacity(0.4),
            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
            border: Border.all(color: AppColors.primary.withOpacity(0.15)),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.document_scanner_outlined,
                    color: AppColors.primary, size: 28),
                const SizedBox(height: 6),
                Text(
                  _evidencePhoto,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chạm để chụp ảnh biên lai mới',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textLight,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'Nộp biên lai cọc/thanh toán',
              icon: Icons.cloud_upload_outlined,
              onPressed: _submitPaymentEvidence,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}
