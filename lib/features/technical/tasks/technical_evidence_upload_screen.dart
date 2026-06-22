import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';
import '../../../shared/models/evidence_type.dart';

class TechnicalEvidenceUploadScreen extends StatefulWidget {
  const TechnicalEvidenceUploadScreen({super.key});

  @override
  State<TechnicalEvidenceUploadScreen> createState() => _TechnicalEvidenceUploadScreenState();
}

class _TechnicalEvidenceUploadScreenState extends State<TechnicalEvidenceUploadScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOrder = 'ORD-2026-001';
  String _evidenceType = 'Checkout';
  final _titleController = TextEditingController(text: 'Ảnh xuất kho rạp VIP');
  final _noteController = TextEditingController(text: 'Đã chất xếp đầy đủ lên xe tải chuẩn bị di chuyển.');
  String _photoName = 'evidence_tech_checkout_01';
  bool _isSubmitting = false;

  void _submitEvidence() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        MockData.evidenceItems.add(
          EvidenceItem(
            id: 'EVI-TEC-${DateTime.now().millisecondsSinceEpoch}',
            orderCode: _selectedOrder,
            type: EvidenceType.fromString(_evidenceType),
            imageUrl: _photoName,
            title: _titleController.text,
            uploadedBy: 'Nguyễn Văn Minh (Technical)',
            uploadedAt: DateTime.now(),
            note: _noteController.text,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tải ảnh minh chứng thực địa thành công!')),
        );
        
        // Clear inputs
        setState(() {
          _photoName = 'evidence_tech_${_evidenceType.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: const CustomAppBar(
        title: 'Nộp ảnh thực địa',
        showBackButton: false,
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
                    const Text('Chọn đơn hàng liên kết:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildOrderDropdown(),
                    AppSizes.spacingL,

                    const Text('Phân loại minh chứng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildTypeDropdown(),
                    AppSizes.spacingL,

                    const Text('Mô tả hình ảnh:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildTextFormCard(),
                    AppSizes.spacingL,

                    const Text('Chụp ảnh hiện trường:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildPhotoInputCard(),
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
        value: _selectedOrder,
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        items: MockData.orders.map((order) {
          return DropdownMenuItem(
            value: order.id,
            child: Text('${order.id} - ${order.customerName}'),
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

  Widget _buildTypeDropdown() {
    return InfoCard(
      child: DropdownButtonFormField<String>(
        value: _evidenceType,
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        items: const [
          DropdownMenuItem(value: 'Checkout', child: Text('Bàn giao xuất kho (Checkout)')),
          DropdownMenuItem(value: 'Installation', child: Text('Thi công hoàn thiện (Installation)')),
          DropdownMenuItem(value: 'Return', child: Text('Hoàn trả thiết bị kho (Return)')),
          DropdownMenuItem(value: 'Damage/Loss', child: Text('Báo cáo hỏng hóc (Damage/Loss)')),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _evidenceType = val;
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

  Widget _buildTextFormCard() {
    return InfoCard(
      child: Column(
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Tiêu đề hình ảnh'),
            validator: (val) => val == null || val.isEmpty ? 'Không để trống tiêu đề' : null,
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _noteController,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Ghi chú mô tả chi tiết'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoInputCard() {
    return InfoCard(
      child: InkWell(
        onTap: () {
          setState(() {
            _photoName = 'evidence_tech_${_evidenceType.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}';
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
                const Icon(Icons.add_a_photo_outlined, color: AppColors.primary, size: 28),
                const SizedBox(height: 6),
                Text(
                  _photoName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Chạm để chụp hình bằng Camera di động',
                  style: TextStyle(fontSize: 10, color: AppColors.textLight, fontStyle: FontStyle.italic),
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
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'Tải ảnh lên hệ thống',
              icon: Icons.cloud_upload_outlined,
              onPressed: _submitEvidence,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}
