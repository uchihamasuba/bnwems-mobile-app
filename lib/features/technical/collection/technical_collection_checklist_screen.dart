import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';

class TechnicalCollectionChecklistScreen extends StatefulWidget {
  const TechnicalCollectionChecklistScreen({super.key});

  @override
  State<TechnicalCollectionChecklistScreen> createState() => _TechnicalCollectionChecklistScreenState();
}

class _TechnicalCollectionChecklistScreenState extends State<TechnicalCollectionChecklistScreen> {
  final List<Map<String, dynamic>> _collectedItems = [
    {'name': 'Ghế Chiavari Trắng', 'total': 100, 'collected': 98, 'damaged': 2, 'lost': 0},
    {'name': 'Đèn LED Par 50W', 'total': 20, 'collected': 20, 'damaged': 0, 'lost': 0},
    {'name': 'Mái che bạt cưới', 'total': 1, 'collected': 1, 'damaged': 0, 'lost': 0},
  ];

  void _submitCollection() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã báo cáo thu hồi thiết bị về cho Leader xác nhận!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Tháo dỡ thu hồi',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.m),
              itemCount: _collectedItems.length,
              separatorBuilder: (_, __) => AppSizes.spacingM,
              itemBuilder: (context, index) {
                final item = _collectedItems[index];
                return InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Đã thu hồi: ${item['collected']}/${item['total']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Row(
                            children: [
                              if (item['damaged'] > 0)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(4)),
                                  child: Text('Hỏng: ${item['damaged']}', style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              if (item['lost'] > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(4)),
                                  child: Text('Mất: ${item['lost']}', style: const TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          _buildActionPanel(),
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
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'Xác nhận thu hồi xong',
              icon: Icons.assignment_return_rounded,
              onPressed: _submitCollection,
            ),
          ),
        ],
      ),
    );
  }
}
