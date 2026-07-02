import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../../core/routes/app_routes.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';
import '../../../shared/models/user_role.dart';

class TechnicalTaskListScreen extends StatefulWidget {
  const TechnicalTaskListScreen({super.key});

  @override
  State<TechnicalTaskListScreen> createState() =>
      _TechnicalTaskListScreenState();
}

class _TechnicalTaskListScreenState extends State<TechnicalTaskListScreen> {
  String _activeTab = 'Đang làm';

  List<MobileTask> get _filteredTasks {
    final techTasks = MockData.tasks
        .where((t) => t.assignedRole == UserRole.technical)
        .toList();
    if (_activeTab == 'Đang làm') {
      return techTasks.where((t) => t.status != 'completed').toList();
    } else {
      return techTasks.where((t) => t.status == 'completed').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: const CustomAppBar(
        title: 'Công việc kỹ thuật',
        showBackButton: false,
      ),
      body: Column(
        children: [
          Row(
            children: [
              _buildTabItem('Đang làm'),
              _buildTabItem('Hoàn thành'),
            ],
          ),
          const Divider(height: 1, color: AppColors.divider),
          Expanded(
            child: _filteredTasks.isEmpty
                ? const Center(
                    child: Text(
                      'Không có công việc nào cần xử lý.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppSizes.m),
                    itemCount: _filteredTasks.length,
                    separatorBuilder: (_, __) => AppSizes.spacingM,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      return _buildTaskCard(task);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label) {
    final isSelected = _activeTab == label;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = label;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(MobileTask task) {
    final doneCount = task.checklistItems.where((i) => i.isCompleted).length;
    final totalCount = task.checklistItems.length;
    final percent = totalCount == 0 ? 0.0 : doneCount / totalCount;

    return InfoCard(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.technicalTaskDetail,
          arguments: task.id,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.orderCode,
                style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12),
              ),
              StatusChip(label: task.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            task.taskName,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  task.location,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ: $doneCount/$totalCount mục checklist',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${(percent * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: AppColors.primaryLight,
              color: AppColors.primary,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
