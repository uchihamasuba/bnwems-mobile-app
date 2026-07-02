import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';

class TechnicalInstallationChecklistScreen extends StatefulWidget {
  const TechnicalInstallationChecklistScreen({super.key});

  @override
  State<TechnicalInstallationChecklistScreen> createState() =>
      _TechnicalInstallationChecklistScreenState();
}

class _TechnicalInstallationChecklistScreenState
    extends State<TechnicalInstallationChecklistScreen> {
  final List<Map<String, dynamic>> _checklist = [
    {'label': 'Dựng khung truss sắt nâng rạp chính', 'done': true},
    {'label': 'Căng bạt cưới che mưa đỉnh rạp', 'done': true},
    {'label': 'Lắp phông nền sân khấu (Backdrop)', 'done': false},
    {'label': 'Cắm hoa cổng chào ngoài trời', 'done': false},
    {'label': 'Sắp xếp bàn ghế Chiavari có nệm (15 bàn)', 'done': false},
    {'label': 'Đi nguồn điện chạy đèn Par led thắp sáng', 'done': false},
  ];

  void _toggleCheck(int index) {
    setState(() {
      _checklist[index]['done'] = !_checklist[index]['done'];
    });
  }

  void _submitInstallation() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Cập nhật tiến trình thi công hoàn thiện hiện trường!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: CustomAppBar(
        title: 'Thi công lắp ráp',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.m),
              itemCount: _checklist.length,
              separatorBuilder: (_, __) => AppSizes.spacingM,
              itemBuilder: (context, index) {
                final item = _checklist[index];
                return InfoCard(
                  child: CheckboxListTile(
                    value: item['done'],
                    onChanged: (val) => _toggleCheck(index),
                    title: Text(
                      item['label'],
                      style: TextStyle(
                        fontSize: 13,
                        color: item['done']
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                        decoration:
                            item['done'] ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    activeColor: AppColors.primary,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
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
              text: 'Nộp báo cáo lắp đặt',
              icon: Icons.build_outlined,
              onPressed: _submitInstallation,
            ),
          ),
        ],
      ),
    );
  }
}
