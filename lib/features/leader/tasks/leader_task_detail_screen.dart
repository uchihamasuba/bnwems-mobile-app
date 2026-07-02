import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';
import '../../../shared/models/user_role.dart';

class LeaderTaskDetailScreen extends StatefulWidget {
  const LeaderTaskDetailScreen({super.key});

  @override
  State<LeaderTaskDetailScreen> createState() => _LeaderTaskDetailScreenState();
}

class _LeaderTaskDetailScreenState extends State<LeaderTaskDetailScreen> {
  late MobileTask _task;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      final taskId = args ?? 'TSK-LDR-001';
      _task = MockData.tasks.firstWhere((t) => t.id == taskId,
          orElse: () => MockData.tasks.first);
      _initialized = true;
    }
  }

  void _toggleChecklistItem(int index) {
    setState(() {
      _task.checklistItems[index].isCompleted =
          !_task.checklistItems[index].isCompleted;

      // Calculate overall progress and check if done
      final allDone = _task.checklistItems.every((item) => item.isCompleted);
      if (allDone) {
        _task.status = 'completed';
      } else {
        _task.status = 'inProgress';
      }
    });
  }

  void _submitTask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Báo cáo hoàn thành tác vụ thành công!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    // Find technical crew assigned to this order
    final techStaffList = MockData.tasks
        .where((t) =>
            t.orderCode == _task.orderCode &&
            t.assignedRole == UserRole.technical)
        .map((t) => t.assignedTo)
        .toSet()
        .toList();

    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Chi tiết tác vụ',
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

                  // Assigned tech crew
                  const Text('Kỹ thuật viên cùng tham gia:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary)),
                  AppSizes.spacingM,
                  _buildTechStaffCard(techStaffList),
                  AppSizes.spacingL,

                  // Checklist section
                  const Text('Checklist giám sát & vận hành:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary)),
                  AppSizes.spacingM,
                  _buildChecklistCard(),
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

  Widget _buildHeaderCard() {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MÃ ĐƠN: ${_task.orderCode}',
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
              StatusChip(label: _task.status),
            ],
          ),
          const SizedBox(height: AppSizes.s),
          Text(
            _task.taskName,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textPrimary),
          ),
          const Divider(height: 24, color: AppColors.divider),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _task.location,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                'Thời gian: ${_task.scheduledTime.hour}:${_task.scheduledTime.minute.toString().padLeft(2, '0')} - ${_task.scheduledTime.day}/${_task.scheduledTime.month}/${_task.scheduledTime.year}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTechStaffCard(List<String> list) {
    if (list.isEmpty) {
      return const InfoCard(
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Text('Chưa có thợ kỹ thuật phụ trách trực tiếp.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ),
      );
    }

    return InfoCard(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: AppColors.divider),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.m, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.account_box_outlined,
                    color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Text(
                  list[index],
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                ),
                const Spacer(),
                const StatusChip(label: 'Vận hành'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChecklistCard() {
    return InfoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _task.checklistItems.length,
            itemBuilder: (context, index) {
              final item = _task.checklistItems[index];
              return CheckboxListTile(
                value: item.isCompleted,
                onChanged: (val) => _toggleChecklistItem(index),
                title: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 13,
                    color: item.isCompleted
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                    decoration:
                        item.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                activeColor: AppColors.primary,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: AppSizes.m),
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
              text: 'Nộp báo cáo công việc',
              icon: Icons.cloud_upload_outlined,
              onPressed: _submitTask,
            ),
          ),
        ],
      ),
    );
  }
}
