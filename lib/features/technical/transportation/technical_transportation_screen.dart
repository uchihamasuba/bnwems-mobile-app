import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';

class TechnicalTransportationScreen extends StatefulWidget {
  const TechnicalTransportationScreen({super.key});

  @override
  State<TechnicalTransportationScreen> createState() =>
      _TechnicalTransportationScreenState();
}

class _TechnicalTransportationScreenState
    extends State<TechnicalTransportationScreen> {
  String _currentMilestone = 'In Transit';
  final _noteController = TextEditingController(
      text:
          'Xe tải di chuyển chậm do kẹt xe giờ cao điểm tại ngã tư Nguyễn Hữu Thọ.');
  bool _isSubmitting = false;

  void _submitMilestone() {
    setState(() => _isSubmitting = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Đã cập nhật trạng thái vận chuyển: $_currentMilestone!')),
      );
      Navigator.pop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Báo cáo vận chuyển',
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
                  const Text('Chọn trạng thái vận chuyển hiện tại:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  _buildMilestonesCard(),
                  AppSizes.spacingL,
                  const Text('Báo cáo sự cố hoặc ghi chú trễ:',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 6),
                  _buildNotesCard(),
                  const SizedBox(height: AppSizes.xxl),
                ],
              ),
            ),
          ),
          _buildActionPanel(),
        ],
      ),
    );
  }

  Widget _buildMilestonesCard() {
    return InfoCard(
      child: Column(
        children: [
          _buildRadioMilestone(
              'Loaded', 'Đã chất xếp hàng lên xe tải (Loaded)'),
          const Divider(height: 1, color: AppColors.divider),
          _buildRadioMilestone(
              'In Transit', 'Đang vận chuyển trên đường (In Transit)'),
          const Divider(height: 1, color: AppColors.divider),
          _buildRadioMilestone(
              'Arrived at Site', 'Đã đến địa điểm thi công (Arrived at Site)'),
        ],
      ),
    );
  }

  Widget _buildRadioMilestone(String value, String label) {
    final isSelected = _currentMilestone == value;
    return RadioListTile<String>(
      value: value,
      groupValue: _currentMilestone,
      onChanged: (val) {
        if (val != null) {
          setState(() {
            _currentMilestone = val;
          });
        }
      },
      title: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildNotesCard() {
    return InfoCard(
      child: TextFormField(
        controller: _noteController,
        maxLines: 4,
        decoration: const InputDecoration(
          hintText: 'Mô tả chi tiết vị trí hoặc nguyên nhân chậm trễ...',
          border: InputBorder.none,
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
              text: 'Cập nhật lộ trình',
              icon: Icons.local_shipping_outlined,
              onPressed: _submitMilestone,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}
