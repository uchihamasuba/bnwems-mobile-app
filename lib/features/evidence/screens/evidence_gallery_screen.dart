import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/status_chip.dart';
import '../../manager/models/manager_route_args.dart';
import '../../../shared/mock/mock_data.dart';
import '../../../shared/models/core_models.dart';
import '../../../shared/models/evidence_type.dart';

class EvidenceGalleryScreen extends StatefulWidget {
  const EvidenceGalleryScreen({super.key});

  @override
  State<EvidenceGalleryScreen> createState() => _EvidenceGalleryScreenState();
}

class _EvidenceGalleryScreenState extends State<EvidenceGalleryScreen> {
  String _selectedType = 'Tat ca';
  String? _orderIdFilter;

  final List<String> _filters = [
    'Tat ca',
    'Survey',
    'Checkout',
    'Installation',
    'Handover',
    'Damage/Loss',
    'Payment',
    'Return'
  ];

  List<EvidenceItem> get _filteredEvidence {
    var items = MockData.evidenceItems;

    if (_orderIdFilter != null && _orderIdFilter!.isNotEmpty) {
      items = items.where((e) => e.orderCode == _orderIdFilter).toList();
    }

    if (_selectedType == 'Tat ca') {
      return items;
    }

    final filterType = EvidenceType.fromString(_selectedType);
    return items.where((e) => e.type == filterType).toList();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ManagerEvidenceRouteArgs) {
      _orderIdFilter = args.orderId;
    } else {
      _orderIdFilter = null;
    }
  }

  void _showImageDetails(EvidenceItem item) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLarge)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSizes.radiusLarge),
                  topRight: Radius.circular(AppSizes.radiusLarge),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.image, size: 64, color: AppColors.primary),
                    const SizedBox(height: 8),
                    Text(
                      item.imageUrl,
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSizes.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      StatusChip(label: item.type.displayName),
                      Text(
                        item.orderCode,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  if (item.note.isNotEmpty) ...[
                    Text(
                      item.note,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    'Dang boi: ${item.uploadedBy}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thoi gian: ${item.uploadedAt.hour}:${item.uploadedAt.minute.toString().padLeft(2, '0')} - ${item.uploadedAt.day}/${item.uploadedAt.month}/${item.uploadedAt.year}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Dong'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredEvidence;

    return AppScaffold(
      useSafeArea: true,
      appBar: const CustomAppBar(
        title: 'Thu vien minh chung',
        showBackButton: false,
      ),
      body: Column(
        children: [
          Container(
            height: 48,
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.m, vertical: 8),
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
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusSmall)),
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
            child: list.isEmpty
                ? const Center(child: Text('Khong tim thay anh minh chung nao.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSizes.m),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
  }

  Widget _buildEvidenceGridTile(EvidenceItem item) {
    return GestureDetector(
      onTap: () => _showImageDetails(item),
      child: InfoCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSizes.radiusLarge),
                    topRight: Radius.circular(AppSizes.radiusLarge),
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.photo_rounded, size: 40, color: AppColors.primary),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.type.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 10),
                      ),
                      Text(
                        item.orderCode,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600),
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
