import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../manager/models/manager_mobile_models.dart';
import '../../manager/models/manager_route_args.dart';
import '../../manager/services/manager_mobile_service.dart';

class SurveyReviewScreen extends StatefulWidget {
  const SurveyReviewScreen({super.key});

  @override
  State<SurveyReviewScreen> createState() => _SurveyReviewScreenState();
}

class _SurveyReviewScreenState extends State<SurveyReviewScreen> {
  late Future<_SurveyReviewData> _future;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _loadData();
  }

  Future<_SurveyReviewData> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? taskId;
    String? orderId;

    if (args is ManagerSurveyRouteArgs) {
      taskId = args.taskId;
      orderId = args.orderId;
    } else if (args is String) {
      orderId = args;
    }

    ManagerTaskSummary? surveyTask;
    if ((taskId == null || taskId.isEmpty) &&
        orderId != null &&
        orderId.isNotEmpty) {
      surveyTask = await ManagerMobileService.getSurveyTaskByOrder(orderId);
      taskId = surveyTask?.workTaskId;
    }

    if (taskId == null || taskId.isEmpty) {
      throw Exception('Không tìm thấy survey task để tải báo cáo.');
    }

    final report = await ManagerMobileService.getSurveyReport(taskId);
    return _SurveyReviewData(
      taskId: taskId,
      orderId: orderId,
      report: report,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_SurveyReviewData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const AppScaffold(
            useSafeArea: true,
            body: LoadingState(),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return AppScaffold(
            useSafeArea: true,
            appBar: const CustomAppBar(
              title: 'Báo cáo khảo sát',
              showBackButton: true,
            ),
            body: ErrorState(
              message: snapshot.error.toString(),
            ),
          );
        }

        final data = snapshot.data!;
        final report = data.report;

        return AppScaffold(
          useSafeArea: true,
          appBar: CustomAppBar(
            title: 'Task khảo sát ${data.taskId}',
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.m),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeaderCard(data),
                AppSizes.spacingL,
                const SectionTitle(title: 'Ghi chú khảo sát'),
                AppSizes.spacingM,
                InfoCard(
                  child: Text(
                    report.notes.isEmpty
                        ? 'Không có ghi chú khảo sát.'
                        : report.notes,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
                AppSizes.spacingL,
                const SectionTitle(title: 'Minh chứng từ survey report'),
                AppSizes.spacingM,
                _buildPhotosGrid(report),
                AppSizes.spacingL,
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        text: 'Từ chối',
                        icon: Icons.close_rounded,
                        isLoading: _submitting,
                        onPressed: _submitting
                            ? null
                            : () => _submitReview(data, 'rejected'),
                      ),
                    ),
                    const SizedBox(width: AppSizes.s),
                    Expanded(
                      child: PrimaryButton(
                        text: 'Phê duyệt',
                        icon: Icons.check_rounded,
                        isLoading: _submitting,
                        onPressed: _submitting
                            ? null
                            : () => _submitReview(data, 'approved'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(_SurveyReviewData data) {
    return InfoCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task: ${data.taskId}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Order: ${data.orderId ?? '--'}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            data.report.submittedAt == null
                ? '--'
                : '${data.report.submittedAt!.day}/${data.report.submittedAt!.month}',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid(ManagerSurveyReport report) {
    if (report.evidences.isEmpty) {
      return const SizedBox(
        height: 220,
        child: EmptyState(
          title: 'Không có minh chứng',
          description: 'Survey report này chưa có minh chứng.',
          icon: Icons.image_not_supported_outlined,
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: report.evidences.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSizes.s,
        mainAxisSpacing: AppSizes.s,
        childAspectRatio: 1.3,
      ),
      itemBuilder: (context, index) {
        final photo = report.evidences[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
          child: Container(
            color: AppColors.primaryLight.withValues(alpha: 0.6),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.image_outlined,
                    color: AppColors.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      photo.fileUrl,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitReview(_SurveyReviewData data, String status) async {
    setState(() => _submitting = true);
    try {
      await ManagerMobileService.reviewSurveyReport(
        taskId: data.taskId,
        status: status,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'approved'
                ? 'Đã phê duyệt báo cáo khảo sát.'
                : 'Đã từ chối báo cáo khảo sát.',
          ),
        ),
      );
      setState(() {
        _future = _loadData();
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }
}

class _SurveyReviewData {
  const _SurveyReviewData({
    required this.taskId,
    required this.orderId,
    required this.report,
  });

  final String taskId;
  final String? orderId;
  final ManagerSurveyReport report;
}
