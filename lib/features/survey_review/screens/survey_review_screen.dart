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
import '../../manager/models/manager_route_args.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';

class SurveyReviewScreen extends StatefulWidget {
  const SurveyReviewScreen({super.key});

  @override
  State<SurveyReviewScreen> createState() => _SurveyReviewScreenState();
}

class _SurveyReviewScreenState extends State<SurveyReviewScreen> {
  late SurveyReport _report;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ManagerSurveyRouteArgs) {
      _loadReport(args.orderId);
    } else if (args is String) {
      _loadReport(args);
    } else {
      _loadReport(null);
    }
  }

  void _loadReport(String? orderCode) {
    if (orderCode != null) {
      _report = MockData.surveyReports.firstWhere(
        (r) => r.orderCode == orderCode,
        orElse: () => MockData.surveyReports.first,
      );
    } else {
      _report = MockData.surveyReports.first;
    }
  }

  void _updateStatus(String newStatus, String message) {
    setState(() {
      _report.approvalStatus = newStatus;
      
      // Sync with Order survey status
      final orderIdx = MockData.orders.indexWhere((o) => o.id == _report.orderCode);
      if (orderIdx != -1) {
        final o = MockData.orders[orderIdx];
        MockData.orders[orderIdx] = o.copyWith(surveyStatus: newStatus);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Duyệt khảo sát ${_report.orderCode}',
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

                  const SectionTitle(title: 'Thông tin mặt bằng & Lắp đặt'),
                  AppSizes.spacingM,
                  _buildSpecsCard(),
                  AppSizes.spacingL,

                  const SectionTitle(title: 'Ảnh hiện trường khảo sát'),
                  AppSizes.spacingM,
                  _buildPhotosGrid(),
                  AppSizes.spacingL,

                  const SectionTitle(title: 'Đánh giá & Kiến nghị của Leader'),
                  AppSizes.spacingM,
                  _buildLeaderAssessmentCard(),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
          if (_report.approvalStatus == 'Pending') _buildActionPanel(),
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
                  'Mã đơn: ${_report.orderCode}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Khách hàng: ${_report.customerName}',
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusChip(label: _report.approvalStatus),
        ],
      ),
    );
  }

  Widget _buildSpecsCard() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Diện tích mặt bằng dựng rạp', '${_report.areaSize} m²'),
          const Divider(height: 20, color: AppColors.divider),
          _buildInfoRow('Lối vào / Chiều rộng ngõ', '${_report.entranceWidth} m'),
          const Divider(height: 20, color: AppColors.divider),
          _buildInfoRow('Bề mặt nơi lắp đặt', _report.installationPosition),
          const Divider(height: 20, color: AppColors.divider),
          _buildInfoRow('Phương thức vận chuyển vật tư', _report.transportationCondition),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _report.photoUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.s,
        mainAxisSpacing: AppSizes.s,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final photo = _report.photoUrls[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            color: AppColors.primaryLight.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_outlined, color: AppColors.primary, size: 28),
                  const SizedBox(height: 6),
                  Text(
                    photo,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLeaderAssessmentCard() {
    return InfoCard(
      borderColor: AppColors.warning.withValues(alpha: 0.3),
      color: AppColors.warningLight.withValues(alpha: 0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.report_problem_outlined, color: AppColors.warning, size: 18),
              SizedBox(width: 6),
              Text(
                'Rủi ro hiện trường:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.warning),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _report.constructionRisk,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
          ),
          const Divider(height: 20, color: AppColors.divider),
          const Text(
            'Phương án khắc phục / Ghi chú:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            _report.notes,
            style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textPrimary, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          desc,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold, height: 1.3),
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
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: 'Yêu cầu khảo sát lại',
              icon: Icons.assignment_return_outlined,
              onPressed: () => _updateStatus('Needs Info', 'Đã yêu cầu Leader khảo sát và bổ sung thêm thông tin!'),
            ),
          ),
          const SizedBox(width: AppSizes.s),
          Expanded(
            child: PrimaryButton(
              text: 'Phê duyệt phương án',
              icon: Icons.check_circle_outline,
              onPressed: () => _updateStatus('Approved', 'Báo cáo khảo sát đã được duyệt thành công!'),
            ),
          ),
        ],
      ),
    );
  }
}
