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

class LeaderWarehouseReturnReportScreen extends StatefulWidget {
  const LeaderWarehouseReturnReportScreen({super.key});

  @override
  State<LeaderWarehouseReturnReportScreen> createState() =>
      _LeaderWarehouseReturnReportScreenState();
}

class _LeaderWarehouseReturnReportScreenState
    extends State<LeaderWarehouseReturnReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOrder = 'ORD-2026-003';
  final _returnedQtyController = TextEditingController(text: '98');
  final _damagedQtyController = TextEditingController(text: '2');
  final _lostQtyController = TextEditingController(text: '0');
  final _equipController =
      TextEditingController(text: 'Ghế Chiavari trắng nệm đỏ');
  final _noteController = TextEditingController(
      text:
          'Đã bốc xếp và bàn giao hoàn trả kho Quận 7 đầy đủ. Phát hiện 2 ghế bị gãy chân gỗ trong quá trình làm lễ.');
  final List<String> _photos = ['evidence_return_warehouse_check'];
  bool _isSubmitting = false;

  void _submitReturnReport() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        // Update Order fieldProgressStatus & status
        final orderIdx =
            MockData.orders.indexWhere((o) => o.id == _selectedOrder);
        if (orderIdx != -1) {
          final o = MockData.orders[orderIdx];
          MockData.orders[orderIdx] = o.copyWith(
            orderStatus: OrderStatus.closed,
            fieldProgressStatus: 'Warehouse Return',
          );
        }

        // Add to evidence gallery
        for (final photo in _photos) {
          MockData.evidenceItems.add(
            EvidenceItem(
              id: 'EVI-${DateTime.now().millisecondsSinceEpoch}-$photo',
              orderCode: _selectedOrder,
              type: EvidenceType.warehouseReturn,
              imageUrl: photo,
              title: 'Ảnh hoàn kho $_selectedOrder',
              uploadedBy: 'Phan Anh Tuấn (Leader)',
              uploadedAt: DateTime.now(),
              note: _noteController.text,
            ),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Báo cáo hoàn kho đã được nộp thành công!')),
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
        title: 'Báo cáo hoàn kho',
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
                    const Text('Kiểm đếm thiết bị hoàn trả:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildSpecsCard(),
                    AppSizes.spacingL,
                    const Text('Chi tiết ghi chú hoàn trả:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildNotesCard(),
                    AppSizes.spacingL,
                    const Text('Ảnh chụp biên bản bàn giao hoàn kho:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildSpecsCard() {
    return InfoCard(
      child: Column(
        children: [
          TextFormField(
            controller: _equipController,
            decoration:
                const InputDecoration(labelText: 'Tên thiết bị hoàn trả'),
            validator: (val) => val == null || val.isEmpty
                ? 'Không để trống tên thiết bị'
                : null,
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _returnedQtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
                labelText: 'Số lượng nguyên vẹn (Returned)'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Nhập số lượng' : null,
          ),
          const SizedBox(height: AppSizes.m),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _damagedQtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số lượng hỏng'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Nhập số lượng' : null,
                ),
              ),
              const SizedBox(width: AppSizes.m),
              Expanded(
                child: TextFormField(
                  controller: _lostQtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Số lượng mất'),
                  validator: (val) =>
                      val == null || val.isEmpty ? 'Nhập số lượng' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesCard() {
    return InfoCard(
      child: TextFormField(
        controller: _noteController,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Mô tả chi tiết tình trạng vật tư thiết bị hoàn trả...',
          border: InputBorder.none,
        ),
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
                  _photos.add('evidence_return_${_photos.length + 1}');
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                      style: BorderStyle.values[1]),
                ),
                child: const Icon(Icons.add_a_photo_outlined,
                    color: AppColors.primary),
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
                    style: const TextStyle(
                        fontSize: 8, fontWeight: FontWeight.bold),
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
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child:
                        const Icon(Icons.close, size: 10, color: Colors.white),
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
              text: 'Nộp biên bản hoàn kho',
              icon: Icons.assignment_return_rounded,
              onPressed: _submitReturnReport,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}
