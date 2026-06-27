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

class ChangeRequestApprovalScreen extends StatefulWidget {
  const ChangeRequestApprovalScreen({super.key});

  @override
  State<ChangeRequestApprovalScreen> createState() => _ChangeRequestApprovalScreenState();
}

class _ChangeRequestApprovalScreenState extends State<ChangeRequestApprovalScreen> {
  late ChangeRequest _request;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ManagerChangeRequestRouteArgs) {
      _loadRequest(args.changeRequestId);
    } else if (args is String) {
      _loadRequest(args);
    } else {
      _loadRequest(null);
    }
  }

  void _loadRequest(String? requestId) {
    if (requestId != null) {
      _request = MockData.changeRequests.firstWhere(
        (cr) => cr.id == requestId,
        orElse: () => MockData.changeRequests.first,
      );
    } else {
      _request = MockData.changeRequests.first;
    }
  }

  void _updateStatus(String newStatus, String message) {
    setState(() {
      _request.approvalStatus = newStatus;
      
      // If approved, update the order's total amount by the cost impact
      if (newStatus == 'Approved') {
        final orderIdx = MockData.orders.indexWhere((o) => o.id == _request.orderCode);
        if (orderIdx != -1) {
          final o = MockData.orders[orderIdx];
          MockData.orders[orderIdx] = o.copyWith(
            totalAmount: o.totalAmount + _request.costImpact,
          );
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');

    String formatPrice(double price) {
      return '${price.toStringAsFixed(0).replaceAllMapped(currencyFormat, (Match m) => '${m[1]},')} đ';
    }

    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Duyệt đổi thiết bị ${_request.id}',
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

                  const SectionTitle(title: 'Thông tin thay đổi đề xuất'),
                  AppSizes.spacingM,
                  _buildChangeDetailsCard(formatPrice),
                  AppSizes.spacingL,

                  const SectionTitle(title: 'Lý do & Khả dụng kho'),
                  AppSizes.spacingM,
                  _buildReasonCard(),
                  AppSizes.spacingL,

                  if (_request.evidenceUrls.isNotEmpty) ...[
                    const SectionTitle(title: 'Hình ảnh đính kèm'),
                    AppSizes.spacingM,
                    _buildPhotosGrid(),
                    AppSizes.spacingL,
                  ],

                  const SectionTitle(title: 'Ý kiến của Leader'),
                  AppSizes.spacingM,
                  _buildLeaderNoteCard(),
                  const SizedBox(height: AppSizes.xl),
                ],
              ),
            ),
          ),
          if (_request.approvalStatus == 'Pending') _buildActionPanel(),
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
                  'Yêu cầu: ${_request.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đơn hàng: ${_request.orderCode} - Khách: ${_request.customerName}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          StatusChip(label: _request.approvalStatus),
        ],
      ),
    );
  }

  Widget _buildChangeDetailsCard(String Function(double) formatPrice) {
    Color typeColor;
    switch (_request.requestType.toLowerCase()) {
      case 'add':
        typeColor = AppColors.success;
        break;
      case 'remove':
        typeColor = AppColors.error;
        break;
      default:
        typeColor = AppColors.warning;
        break;
    }

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Loại điều chỉnh',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                ),
                child: Text(
                  _request.requestType.toUpperCase(),
                  style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ),
            ],
          ),
          const Divider(height: 24, color: AppColors.divider),
          _buildInfoRow('Thiết bị / Vật tư đề xuất', _request.itemName),
          const Divider(height: 24, color: AppColors.divider),
          _buildInfoRow('Số lượng thay đổi', 'x${_request.quantity}'),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Biến động chi phí hợp đồng',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Text(
                formatPrice(_request.costImpact),
                style: TextStyle(
                  color: _request.costImpact >= 0 ? AppColors.warning : AppColors.success,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReasonCard() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Lý do điều chỉnh:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            _request.reason,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
          ),
          const Divider(height: 20, color: AppColors.divider),
          const Text(
            'Khả dụng trong kho hàng:',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            _request.inventoryAvailability,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _request.evidenceUrls.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.s,
        mainAxisSpacing: AppSizes.s,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final photo = _request.evidenceUrls[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            color: AppColors.primaryLight.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.photo_outlined, color: AppColors.primary, size: 28),
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

  Widget _buildLeaderNoteCard() {
    return InfoCard(
      borderColor: AppColors.primary.withValues(alpha: 0.2),
      color: AppColors.primaryLight.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Báo cáo từ Leader hiện trường:',
            style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            _request.noteFromLeader,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontStyle: FontStyle.italic, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
        ),
        const SizedBox(width: 12),
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
              text: 'Từ chối',
              icon: Icons.cancel_outlined,
              onPressed: () => _updateStatus('Rejected', 'Đã từ chối yêu cầu thay đổi thiết bị.'),
            ),
          ),
          const SizedBox(width: AppSizes.s),
          Expanded(
            child: PrimaryButton(
              text: 'Duyệt & Cập nhật',
              icon: Icons.check_circle_outline,
              onPressed: () => _updateStatus('Approved', 'Yêu cầu thay đổi thiết bị đã được duyệt và cập nhật chi phí!'),
            ),
          ),
        ],
      ),
    );
  }
}
