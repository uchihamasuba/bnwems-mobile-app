import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';

class TechnicalPickListScreen extends StatefulWidget {
  const TechnicalPickListScreen({super.key});

  @override
  State<TechnicalPickListScreen> createState() => _TechnicalPickListScreenState();
}

class _TechnicalPickListScreenState extends State<TechnicalPickListScreen> {
  final List<Map<String, dynamic>> _items = [
    {'name': 'Ghế Chiavari Trắng', 'required': 100, 'picked': 95, 'unit': 'chiếc'},
    {'name': 'Nệm ngồi màu đỏ', 'required': 100, 'picked': 100, 'unit': 'chiếc'},
    {'name': 'Đèn LED Par 50W', 'required': 20, 'picked': 18, 'unit': 'cái'},
    {'name': 'Khung truss sắt 2m', 'required': 40, 'picked': 40, 'unit': 'thanh'},
    {'name': 'Bạt che đỉnh rạp 6x12m', 'required': 1, 'picked': 1, 'unit': 'tấm'},
  ];

  void _incrementPicked(int index) {
    if (_items[index]['picked'] < _items[index]['required']) {
      setState(() {
        _items[index]['picked'] += 1;
      });
    }
  }

  void _decrementPicked(int index) {
    if (_items[index]['picked'] > 0) {
      setState(() {
        _items[index]['picked'] -= 1;
      });
    }
  }

  void _submitPickList() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Xác nhận soạn đủ thiết bị và xuất kho thành công!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Soạn đồ xuất kho',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.m),
              itemCount: _items.length,
              separatorBuilder: (_, __) => AppSizes.spacingM,
              itemBuilder: (context, index) {
                final item = _items[index];
                final isDone = item['picked'] == item['required'];

                return InfoCard(
                  borderColor: isDone ? AppColors.success.withOpacity(0.4) : AppColors.divider,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Yêu cầu: ${item['required']} ${item['unit']}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      
                      // Quantity adjuster
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.textSecondary),
                            onPressed: () => _decrementPicked(index),
                          ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 36, minHeight: 28),
                            alignment: Alignment.center,
                            child: Text(
                              '${item['picked']}',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDone ? AppColors.success : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: () => _incrementPicked(index),
                          ),
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
              text: 'Xác nhận xuất kho',
              icon: Icons.inventory_2_outlined,
              onPressed: _submitPickList,
            ),
          ),
        ],
      ),
    );
  }
}
