import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';
import '../../../shared/models/order_status.dart';
import '../../../shared/models/evidence_type.dart';

class LeaderHandoverReportScreen extends StatefulWidget {
  const LeaderHandoverReportScreen({super.key});

  @override
  State<LeaderHandoverReportScreen> createState() => _LeaderHandoverReportScreenState();
}

class _LeaderHandoverReportScreenState extends State<LeaderHandoverReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOrder = 'ORD-2026-001';
  final _noteController = TextEditingController(text: 'Khách hàng đã ký nghiệm thu mặt bằng, bàn giao đầy đủ 15 bàn tròn cưới và bạt che không rò rỉ.');
  final List<String> _photos = ['evidence_handover_01', 'evidence_handover_signature'];
  bool _isSubmitting = false;

  void _submitHandover() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        // Update Order fieldProgressStatus & status
        final orderIdx = MockData.orders.indexWhere((o) => o.id == _selectedOrder);
        if (orderIdx != -1) {
          final o = MockData.orders[orderIdx];
          MockData.orders[orderIdx] = o.copyWith(
            orderStatus: OrderStatus.handedOver,
            fieldProgressStatus: 'Handover',
          );
        }

        // Add to evidence gallery
        for (final photo in _photos) {
          MockData.evidenceItems.add(
            EvidenceItem(
              id: 'EVI-${DateTime.now().millisecondsSinceEpoch}-$photo',
              orderCode: _selectedOrder,
              type: EvidenceType.handover,
              imageUrl: photo,
              title: 'Ảnh nghiệm thu bàn giao $_selectedOrder',
              uploadedBy: 'Phan Anh Tuấn (Leader)',
              uploadedAt: DateTime.now(),
              note: _noteController.text,
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Báo cáo bàn giao đã được nộp thành công!')),
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
        title: 'Báo cáo bàn giao',
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
                    const Text('Chọn đơn hàng bàn giao:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildOrderDropdown(),
                    AppSizes.spacingL,

                    const Text('Ghi chú tình trạng bàn giao:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildNotesCard(),
                    AppSizes.spacingL,

                    const Text('Hình ảnh nghiệm thu / Chữ ký khách hàng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildPhotosCard(),
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
        style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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

  Widget _buildNotesCard() {
    return InfoCard(
      child: TextFormField(
        controller: _noteController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Nhập ghi chú chi tiết bàn giao...',
          border: InputBorder.none,
        ),
        validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập ghi chú bàn giao' : null,
      ),
    );
  }

  Widget _buildPhotosCard() {
    return InfoCard(
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _photos.length + 1,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          if (index == _photos.length) {
            return InkWell(
              onTap: () {
                setState(() {
                  _photos.add('evidence_handover_${_photos.length + 1}');
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3), style: BorderStyle.values[1]),
                ),
                child: const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
              ),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Center(
                  child: Text(
                    _photos[index],
                    style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                top: 2,
                right: 2,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _photos.removeAt(index);
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 10, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
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
              text: 'Nộp biên bản bàn giao',
              icon: Icons.assignment_turned_in_rounded,
              onPressed: _submitHandover,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}
