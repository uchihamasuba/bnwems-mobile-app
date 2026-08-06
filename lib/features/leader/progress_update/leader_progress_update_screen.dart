import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';

class LeaderProgressUpdateScreen extends StatefulWidget {
  const LeaderProgressUpdateScreen({super.key});

  @override
  State<LeaderProgressUpdateScreen> createState() =>
      _LeaderProgressUpdateScreenState();
}

class _LeaderProgressUpdateScreenState
    extends State<LeaderProgressUpdateScreen> {
  String _selectedOrder = 'ORD-2026-001';
  late List<FieldProgressStep> _steps;

  @override
  void initState() {
    super.initState();
    _loadSteps();
  }

  void _loadSteps() {
    _steps = MockData.fieldProgress[_selectedOrder] ?? [];
  }

  void _updateStepStatus(int index, String newStatus) {
    setState(() {
      _steps[index].status = newStatus;

      // Update overall order status based on step
      final orderIdx =
          MockData.orders.indexWhere((o) => o.id == _selectedOrder);
      if (orderIdx != -1) {
        final currentOrder = MockData.orders[orderIdx];
        String overallStatus = currentOrder.fieldProgressStatus;
        if (newStatus == 'completed') {
          overallStatus = _steps[index].stepName;
        }
        MockData.orders[orderIdx] = currentOrder.copyWith(
          fieldProgressStatus: overallStatus,
        );
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Đã cập nhật trạng thái bước "${_steps[index].stepName}" thành "$newStatus"')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: const CustomAppBar(
        title: 'Cập nhật tiến độ hiện trường',
        showBackButton: false,
      ),
      body: Column(
        children: [
          // Order Selector
          Container(
            padding: const EdgeInsets.all(AppSizes.m),
            color: Colors.white,
            child: Row(
              children: [
                const Text('Chọn đơn hàng:',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusMedium),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedOrder,
                        isExpanded: true,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            fontSize: 13),
                        items: MockData.orders.map((o) {
                          return DropdownMenuItem(
                            value: o.id,
                            child: Text('${o.id} - ${o.customerName}'),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedOrder = val;
                              _loadSteps();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.divider),

          Expanded(
            child: _steps.isEmpty
                ? const Center(
                    child:
                        Text('Không tìm thấy sơ đồ tiến độ cho đơn hàng này.'))
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.m),
                    itemCount: _steps.length,
                    separatorBuilder: (_, __) => AppSizes.spacingM,
                    itemBuilder: (context, index) {
                      final step = _steps[index];
                      return _buildStepCard(step, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(FieldProgressStep step, int index) {
    final isDone = step.status == 'completed';
    final isWorking = step.status == 'inProgress';
    final isDelayed = step.status == 'delayed';

    Color markerColor = AppColors.textLight;
    if (isDone) markerColor = AppColors.success;
    if (isWorking) markerColor = AppColors.primary;
    if (isDelayed) markerColor = AppColors.error;

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                        color: markerColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    step.stepName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
              StatusChip(label: step.status),
            ],
          ),
          if (step.note != null && step.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Ghi chú: ${step.note}',
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
          const Divider(height: 20, color: AppColors.divider),

          // Action Buttons to change state
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildStepActionButton(
                  index, 'Trễ hạn', 'delayed', AppColors.error),
              const SizedBox(width: 8),
              _buildStepActionButton(
                  index, 'Đang làm', 'inProgress', AppColors.primary),
              const SizedBox(width: 8),
              _buildStepActionButton(
                  index, 'Hoàn thành', 'completed', AppColors.success),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepActionButton(
      int index, String label, String statusValue, Color color) {
    final currentStatus = _steps[index].status;
    final isCurrent = currentStatus == statusValue;

    return ElevatedButton(
      onPressed: isWorkingOrChangeNeeded(index, statusValue)
          ? () => _updateStepStatus(index, statusValue)
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrent ? color : Colors.white,
        foregroundColor: isCurrent ? Colors.white : color,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        minimumSize: const Size(60, 28),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
              color: isCurrent ? Colors.transparent : AppColors.divider),
        ),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  bool isWorkingOrChangeNeeded(int index, String targetStatus) {
    // Basic business rule: you can toggle status of any steps
    return _steps[index].status != targetStatus;
  }
}
