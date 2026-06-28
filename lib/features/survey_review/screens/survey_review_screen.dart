import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/section_title.dart';
import '../../manager/models/manager_mobile_models.dart';
import '../../manager/models/manager_route_args.dart';
import '../../manager/services/manager_mobile_service.dart';
import '../../manager/widgets/manager_backend_gap_card.dart';

class SurveyReviewScreen extends StatefulWidget {
  const SurveyReviewScreen({super.key});

  @override
  State<SurveyReviewScreen> createState() => _SurveyReviewScreenState();
}

class _SurveyReviewScreenState extends State<SurveyReviewScreen> {
  late Future<_SurveyReviewData> _future;

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
    if ((taskId == null || taskId.isEmpty) && orderId != null && orderId.isNotEmpty) {
      surveyTask = await ManagerMobileService.getSurveyTaskByOrder(orderId);
      taskId = surveyTask?.workTaskId;
    }

    if (taskId == null || taskId.isEmpty) {
      throw Exception(
        'Khong tim thay survey task de tai bao cao. Backend can tra ve taskId hoac can co API list survey report theo order.',
      );
    }

    final report = await ManagerMobileService.getSurveyReport(taskId);
    return _SurveyReviewData(
      taskId: taskId,
      orderId: orderId,
      report: report,
    );
  }

  void _showMissingApiMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Backend chua co API manager review survey report. Can bo sung PUT /tasks/:id/survey-report/review.',
        ),
      ),
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
              title: 'Duyet khao sat',
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
            title: 'Survey task ${data.taskId}',
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
                      _buildHeaderCard(data),
                      AppSizes.spacingL,
                      const ManagerBackendGapCard(
                        title: 'Review action chua co API',
                        message:
                            'Man nay dang doc survey report that tu GET /tasks/:id/survey-report. Hai nut duyet/yeu cau bo sung chua submit that duoc vi backend chua co endpoint review.',
                      ),
                      AppSizes.spacingL,
                      const SectionTitle(title: 'Ghi chu survey'),
                      AppSizes.spacingM,
                      InfoCard(
                        child: Text(
                          report.notes.isEmpty ? 'Khong co ghi chu survey.' : report.notes,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      AppSizes.spacingL,
                      const SectionTitle(title: 'Evidence tu survey report'),
                      AppSizes.spacingM,
                      _buildPhotosGrid(report),
                      AppSizes.spacingL,
                      const SectionTitle(title: 'Thong tin ky thuat con thieu'),
                      AppSizes.spacingM,
                      const ManagerBackendGapCard(
                        title: 'Schema survey report chua du field',
                        message:
                            'Area size, entrance width, installation position, transportation condition va construction risk chua duoc backend tra ve tu survey report hien tai.',
                      ),
                    ],
                  ),
                ),
              ),
              _buildActionPanel(),
            ],
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
                  'Order: ${data.orderId ?? 'Chua xac dinh'}',
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
      return const InfoCard(
        child: Text(
          'Khong co evidence nao trong survey report nay.',
          style: TextStyle(color: AppColors.textSecondary),
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
            color: AppColors.primaryLight.withOpacity(0.6),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.image_outlined, color: AppColors.primary, size: 28),
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

  Widget _buildActionPanel() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.m),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: SecondaryButton(
              text: 'Yeu cau bo sung',
              icon: Icons.assignment_return_outlined,
              onPressed: _showMissingApiMessage,
            ),
          ),
          const SizedBox(width: AppSizes.s),
          Expanded(
            child: PrimaryButton(
              text: 'Phe duyet',
              icon: Icons.check_circle_outline,
              onPressed: _showMissingApiMessage,
            ),
          ),
        ],
      ),
    );
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
