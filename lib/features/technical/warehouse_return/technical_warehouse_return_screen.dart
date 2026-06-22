import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';

class TechnicalWarehouseReturnScreen extends StatefulWidget {
  const TechnicalWarehouseReturnScreen({super.key});

  @override
  State<TechnicalWarehouseReturnScreen> createState() => _TechnicalWarehouseReturnScreenState();
}

class _TechnicalWarehouseReturnScreenState extends State<TechnicalWarehouseReturnScreen> {
  final List<Map<String, dynamic>> _returnList = [
    {'name': 'Ghế Chiavari Trắng', 'expected': 100, 'returned': 98, 'damaged': 2, 'lost': 0},
    {'name': 'Đèn LED Par 50W', 'expected': 20, 'returned': 20, 'damaged': 0, 'lost': 0},
  ];

  void _submitWarehouseReturn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Báo cáo bàn giao thiết bị hoàn kho thành công!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Hoàn trả kho thiết bị',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.m),
              itemCount: _returnList.length,
              separatorBuilder: (_, __) => AppSizes.spacingM,
              itemBuilder: (context, index) {
                final item = _returnList[index];
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
                          Text('Bàn giao về kho: ${item['returned']}/${item['expected']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          Row(
                            children: [
                              if (item['damaged'] > 0)
                                Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(4)),
                                  child: Text('Cần bảo trì: ${item['damaged']}', style: const TextStyle(color: AppColors.error, fontSize: 10, fontWeight: FontWeight.bold)),
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
              text: 'Xác nhận hoàn kho',
              icon: Icons.warehouse_outlined,
              onPressed: _submitWarehouseReturn,
            ),
          ),
        ],
      ),
    );
  }
}
