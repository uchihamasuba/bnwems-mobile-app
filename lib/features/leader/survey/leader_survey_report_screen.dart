import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';

class LeaderSurveyReportScreen extends StatefulWidget {
  const LeaderSurveyReportScreen({super.key});

  @override
  State<LeaderSurveyReportScreen> createState() => _LeaderSurveyReportScreenState();
}

class _LeaderSurveyReportScreenState extends State<LeaderSurveyReportScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedOrder = 'ORD-2026-002';
  final _areaController = TextEditingController(text: '85.0');
  final _widthController = TextEditingController(text: '2.5');
  final _siteController = TextEditingController(text: 'Mặt sân xi măng bằng phẳng trước nhà riêng');
  final _transportController = TextEditingController(text: 'Đẩy tay xe kéo thủ công khoảng cách 40m từ bãi đỗ xe tải');
  final _riskController = TextEditingController(text: 'Đường dây điện chăng ngang sân ở độ cao 3.2m');
  final _notesController = TextEditingController(text: 'Khách yêu cầu lắp rạp cao che nắng đỉnh chữ A cao dưới 2.8m');
  final List<String> _photos = ['survey_photo_entrance', 'survey_photo_yard'];
  bool _isSubmitting = false;

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        
        // Add new survey report instance to mock db
        MockData.surveyReports.add(
          SurveyReport(
            id: 'SRV-${DateTime.now().millisecondsSinceEpoch}',
            orderCode: _selectedOrder,
            customerName: 'Khách hàng $_selectedOrder',
            location: 'Địa điểm khảo sát thực địa',
            leaderStaffName: 'Phan Anh Tuấn',
            surveyDate: DateTime.now(),
            areaSize: double.tryParse(_areaController.text) ?? 0.0,
            entranceWidth: double.tryParse(_widthController.text) ?? 0.0,
            installationPosition: _siteController.text,
            transportationCondition: _transportController.text,
            constructionRisk: _riskController.text,
            notes: _notesController.text,
            photoUrls: _photos,
            approvalStatus: 'Pending',
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Báo cáo khảo sát đã được gửi đến Manager!')),
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
        title: 'Báo cáo khảo sát',
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
                    // Select Order
                    const Text('Chọn đơn hàng sự kiện:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    _buildOrderDropdownCard(),
                    AppSizes.spacingL,

                    // Dimensions
                    const Text('Kích thước hiện trường:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    _buildDimensionsCard(),
                    AppSizes.spacingL,

                    // Detail Conditions
                    const Text('Chi tiết khảo sát điều kiện thi công:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    _buildDetailsFormCard(),
                    AppSizes.spacingL,

                    // Attached pictures
                    const Text('Hình ảnh hiện trường mặt bằng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
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

  Widget _buildOrderDropdownCard() {
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

  Widget _buildDimensionsCard() {
    return InfoCard(
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _areaController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Diện tích rạp (m²)',
                prefixIcon: Icon(Icons.aspect_ratio),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Nhập diện tích' : null,
            ),
          ),
          const SizedBox(width: AppSizes.m),
          Expanded(
            child: TextFormField(
              controller: _widthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Lối vào rộng (m)',
                prefixIcon: Icon(Icons.width_normal_rounded),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Nhập chiều rộng' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsFormCard() {
    return InfoCard(
      child: Column(
        children: [
          TextFormField(
            controller: _siteController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Vị trí lắp ráp & Bề mặt nền'),
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _transportController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Điều kiện vận chuyển vật tư'),
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _riskController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Rủi ro thi công'),
          ),
          const SizedBox(height: AppSizes.m),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Ghi chú kiến nghị khác'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosCard() {
    return InfoCard(
      child: Column(
        children: [
          GridView.builder(
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
                      _photos.add('survey_photo_${_photos.length + 1}');
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
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'Nộp báo cáo khảo sát',
              icon: Icons.check_circle_outline,
              onPressed: _submitReport,
              isLoading: _isSubmitting,
            ),
          ),
        ],
      ),
    );
  }
}
