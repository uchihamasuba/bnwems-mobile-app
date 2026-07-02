import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/loading_state.dart';
import '../../manager/models/manager_mobile_models.dart';
import '../../manager/models/manager_route_args.dart';
import '../../manager/services/manager_mobile_service.dart';

class EvidenceGalleryScreen extends StatefulWidget {
  const EvidenceGalleryScreen({super.key});

  @override
  State<EvidenceGalleryScreen> createState() => _EvidenceGalleryScreenState();
}

class _EvidenceGalleryScreenState extends State<EvidenceGalleryScreen> {
  String _selectedType = 'Tất cả';
  late Future<_EvidenceScreenData> _future;

  final List<String> _filters = [
    'Tất cả',
    'Survey',
    'Payment',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _future = _loadData();
  }

  Future<_EvidenceScreenData> _loadData() async {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? orderId;
    String? taskId;

    if (args is ManagerEvidenceRouteArgs) {
      orderId = args.orderId;
      taskId = args.taskId;
    }

    if (orderId == null || orderId.isEmpty) {
      return const _EvidenceScreenData(
        orderId: null,
        bundle: null,
      );
    }

    final surveyTaskId = taskId ??
        (await ManagerMobileService.getSurveyTaskByOrder(orderId))?.workTaskId;
    final bundle = await ManagerMobileService.getEvidenceBundle(
      orderId: orderId,
      surveyTaskId: surveyTaskId,
    );

    return _EvidenceScreenData(orderId: orderId, bundle: bundle);
  }

  List<_EvidenceTileData> _filteredEvidence(_EvidenceScreenData data) {
    final bundle = data.bundle;
    if (bundle == null) {
      return const [];
    }

    final items = <_EvidenceTileData>[
      ...bundle.surveyEvidences.map(
        (item) => _EvidenceTileData(type: 'Survey', fileUrl: item.fileUrl),
      ),
      ...bundle.paymentEvidences.map(
        (item) => _EvidenceTileData(type: 'Payment', fileUrl: item.fileUrl),
      ),
    ];

    if (_selectedType == 'Tất cả') {
      return items;
    }

    return items.where((item) => item.type == _selectedType).toList();
  }

  void _showImageDetails(_EvidenceTileData item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusLarge),
                  topRight: Radius.circular(AppSizes.radiusLarge),
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    item.fileUrl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.fileUrl,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_EvidenceScreenData>(
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
              title: 'Thư viện minh chứng',
              showBackButton: false,
            ),
            body: ErrorState(message: snapshot.error.toString()),
          );
        }

        final data = snapshot.data!;
        final list = _filteredEvidence(data);

        return AppScaffold(
          useSafeArea: true,
          appBar: const CustomAppBar(
            title: 'Thư viện minh chứng',
            showBackButton: false,
          ),
          body: Column(
            children: [
              Container(
                height: 48,
                color: Colors.white,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.m,
                    vertical: 8,
                  ),
                  itemCount: _filters.length,
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final isSelected = _selectedType == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color:
                              isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.background,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusSmall,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedType = filter);
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 1, color: AppColors.divider),
              Expanded(
                child: data.orderId == null
                    ? const Padding(
                        padding: EdgeInsets.all(AppSizes.m),
                        child: EmptyState(
                          title: 'Không có dữ liệu minh chứng',
                          description:
                              'Hãy mở từ chi tiết đơn hàng để xem minh chứng.',
                          icon: Icons.folder_off_outlined,
                        ),
                      )
                    : list.isEmpty
                        ? const Padding(
                            padding: EdgeInsets.all(AppSizes.m),
                            child: EmptyState(
                              title: 'Không có minh chứng',
                              description:
                                  'Không có minh chứng nào cho đơn hàng này.',
                              icon: Icons.photo_library_outlined,
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(AppSizes.m),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: AppSizes.m,
                              mainAxisSpacing: AppSizes.m,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              final item = list[index];
                              return _buildEvidenceGridTile(item);
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvidenceGridTile(_EvidenceTileData item) {
    return GestureDetector(
      onTap: () => _showImageDetails(item),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusLarge),
                    topRight: Radius.circular(AppSizes.radiusLarge),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.photo_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.type,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.fileUrl,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EvidenceScreenData {
  const _EvidenceScreenData({
    required this.orderId,
    required this.bundle,
  });

  final String? orderId;
  final ManagerEvidenceBundle? bundle;
}

class _EvidenceTileData {
  const _EvidenceTileData({
    required this.type,
    required this.fileUrl,
  });

  final String type;
  final String fileUrl;
}
