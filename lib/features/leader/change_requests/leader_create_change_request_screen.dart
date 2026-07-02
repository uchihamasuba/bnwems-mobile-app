import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';

class LeaderCreateChangeRequestScreen extends StatefulWidget {
  const LeaderCreateChangeRequestScreen({super.key});

  @override
  State<LeaderCreateChangeRequestScreen> createState() =>
      _LeaderCreateChangeRequestScreenState();
}

class _LeaderCreateChangeRequestScreenState
    extends State<LeaderCreateChangeRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOrder = 'ORD-2026-001';
  String _requestType = 'Add';
  final _itemController =
      TextEditingController(text: 'Dây thừng gai treo đèn Par ngoài trời');
  final _qtyController = TextEditingController(text: '5');
  final _reasonController = TextEditingController(
      text: 'Khách muốn căng thêm đèn dây gai để tạo cảm giác lung linh hơn');
  final _costController = TextEditingController(text: '500000.0');
  final _availabilityController =
      TextEditingController(text: 'Sẵn có tại Kho Q7 (còn 12 cuộn)');
  bool _isSubmitting = false;

  void _submitRequest() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);

        MockData.changeRequests.add(
          ChangeRequest(
            id: 'CR-${DateTime.now().millisecondsSinceEpoch}',
            orderCode: _selectedOrder,
            customerName: 'Khách hàng $_selectedOrder',
            requestType: _requestType,
            itemName: _itemController.text,
            quantity: int.tryParse(_qtyController.text) ?? 1,
            reason: _reasonController.text,
            costImpact: double.tryParse(_costController.text) ?? 0.0,
            inventoryAvailability: _availabilityController.text,
            noteFromLeader:
                'Thợ lắp ráp đang đợi lệnh thi công sau khi Manager duyệt',
            evidenceUrls: const ['cr_rope_photo'],
            approvalStatus: 'Pending',
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('Yêu cầu đổi thiết bị đã gửi đến Manager thành công!')),
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
        title: 'Tạo đổi thiết bị',
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
                    // Order
                    const Text('Chọn đơn hàng sự kiện:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildOrderDropdown(),
                    AppSizes.spacingL,

                    // Request Type
                    const Text('Loại điều chỉnh:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildTypeDropdown(),
                    AppSizes.spacingL,

                    // Material Spec
                    const Text('Thông số thiết bị / vật tư:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildItemSpecsCard(),
                    AppSizes.spacingL,

                    // Details
                    const Text('Lý do & Tác động tài chính:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    _buildFinancialCard(),
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

  Widget _buildTypeDropdown() {
    return InfoCard(
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: _requestType,
        style: const TextStyle(
            color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        items: const [
          DropdownMenuItem(
              value: 'Add',
              child:
                  Text('Thêm thiết bị (ADD)', overflow: TextOverflow.ellipsis)),
          DropdownMenuItem(
              value: 'Remove',
              child: Text('Bớt thiết bị (REMOVE)',
                  overflow: TextOverflow.ellipsis)),
          DropdownMenuItem(
              value: 'Replace',
              child: Text('Thay thế thiết bị (REPLACE)',
                  overflow: TextOverflow.ellipsis)),
          DropdownMenuItem(
              value: 'Change Plan',
              child: Text('Đổi phương án setup (CHANGE PLAN)',
                  overflow: TextOverflow.ellipsis)),
        ],
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _requestType = val;
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

  Widget _buildItemSpecsCard() {
    return InfoCard(
      child: Column(
        children: [
          TextFormField(
            controller: _itemController,
            decoration: const InputDecoration(
                labelText: 'Tên thiết bị / Dịch vụ phát sinh'),
            validator: (val) => val == null || val.isEmpty
                ? 'Không để trống tên thiết bị'
                : null,
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _qtyController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Số lượng'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Không để trống số lượng' : null,
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _availabilityController,
            decoration:
                const InputDecoration(labelText: 'Khả dụng kho (nếu nắm được)'),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard() {
    return InfoCard(
      child: Column(
        children: [
          TextFormField(
            controller: _costController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Chi phí phát sinh ước tính (VNĐ)',
              prefixText: 'đ ',
            ),
            validator: (val) =>
                val == null || val.isEmpty ? 'Nhập chi phí phát sinh' : null,
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _reasonController,
            maxLines: 3,
            decoration:
                const InputDecoration(labelText: 'Lý do thay đổi/phát sinh'),
            validator: (val) =>
                val == null || val.isEmpty ? 'Nhập lý do thay đổi' : null,
          ),
        ],
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
              text: 'Gửi yêu cầu phát sinh',
              icon: Icons.check_circle_outline,
              onPressed: _submitRequest,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}
