import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';

class FieldProgressScreen extends StatefulWidget {
  const FieldProgressScreen({super.key});

  @override
  State<FieldProgressScreen> createState() => _FieldProgressScreenState();
}

class _FieldProgressScreenState extends State<FieldProgressScreen> {
  late String _orderId;
  late List<FieldProgressStep> _steps;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    _orderId = args ?? 'ORD-2026-001';
    _steps = MockData.fieldProgress[_orderId] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final order = MockData.orders.firstWhere(
      (o) => o.id == _orderId,
      orElse: () => MockData.orders.first,
    );

    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Tiến độ thực địa $_orderId',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Order summary banner at the top
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: AppSizes.m),
            color: AppColors.primaryLight.withOpacity(0.4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.location,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                StatusChip(label: order.fieldProgressStatus),
              ],
            ),
          ),
          
          // Timeline list
          Expanded(
            child: _steps.isEmpty
                ? const Center(
                    child: Text(
                      'Không tìm thấy dữ liệu tiến độ thực địa cho đơn hàng này.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.m),
                    itemCount: _steps.length,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      final isLast = index == _steps.length - 1;
                      return _buildTimelineRow(step, isLast);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(FieldProgressStep step, bool isLast) {
    Color stepColor;
    Widget markerWidget;

    switch (step.status) {
      case 'completed':
        stepColor = AppColors.success;
        markerWidget = Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
          child: const Icon(Icons.check, size: 12, color: Colors.white),
        );
        break;
      case 'inProgress':
        stepColor = AppColors.primary;
        markerWidget = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 3),
          ),
          child: Center(
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            ),
          ),
        );
        break;
      case 'delayed':
        stepColor = AppColors.error;
        markerWidget = Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
          child: const Icon(Icons.warning_rounded, size: 12, color: Colors.white),
        );
        break;
      case 'pending':
      default:
        stepColor = AppColors.textLight;
        markerWidget = Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.textLight, width: 2),
          ),
        );
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left side: Indicator and line
          Column(
            children: [
              markerWidget,
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: stepColor.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSizes.m),
          
          // Right side: Card detail content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: InfoCard(
                borderColor: step.status == 'inProgress' ? AppColors.primary.withOpacity(0.4) : AppColors.divider,
                color: step.status == 'inProgress' ? AppColors.primaryLight.withOpacity(0.2) : Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          step.stepName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: step.status == 'pending' ? AppColors.textSecondary : AppColors.textPrimary,
                          ),
                        ),
                        if (step.status != 'pending')
                          Text(
                            step.updatedAt,
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                          ),
                      ],
                    ),
                    if (step.status != 'pending') ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.account_circle_outlined, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            'Cập nhật: ${step.updatedBy}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                    if (step.note != null && step.note!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                        ),
                        child: Text(
                          step.note!,
                          style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                        ),
                      ),
                    ],
                    if (step.evidenceCount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.photo_library_outlined, size: 14, color: AppColors.primary),
                          const SizedBox(width: 6),
                          Text(
                            '${step.evidenceCount} hình ảnh minh chứng',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
