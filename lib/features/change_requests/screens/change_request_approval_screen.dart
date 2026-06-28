import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/custom_app_bar.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/status_chip.dart';
import '../../manager/models/manager_route_args.dart';
import '../../manager/services/manager_mobile_service.dart';
import '../../manager/widgets/manager_backend_gap_card.dart';

class ChangeRequestApprovalScreen extends StatefulWidget {
  const ChangeRequestApprovalScreen({super.key});

  @override
  State<ChangeRequestApprovalScreen> createState() =>
      _ChangeRequestApprovalScreenState();
}

class _ChangeRequestApprovalScreenState extends State<ChangeRequestApprovalScreen> {
  String? _changeRequestId;
  String? _orderId;
  bool _submitting = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is ManagerChangeRequestRouteArgs) {
      _changeRequestId = args.changeRequestId;
      _orderId = args.orderId;
    } else if (args is String) {
      _changeRequestId = args;
      _orderId = args;
    }
  }

  Future<void> _submit(String status) async {
    if (_changeRequestId == null || _changeRequestId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Chua co changeRequestId. Backend can co API detail/list de man hinh nay tai du lieu that.',
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await ManagerMobileService.approveChangeRequest(
        changeRequestId: _changeRequestId!,
        status: status,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Da goi API approve change request: $status')),
      );
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

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useSafeArea: true,
      appBar: const CustomAppBar(
        title: 'Duyet change request',
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
                  InfoCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Change request: ${_changeRequestId ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Order: ${_orderId ?? 'Chua xac dinh'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const StatusChip(label: 'Action only'),
                      ],
                    ),
                  ),
                  AppSizes.spacingL,
                  const ManagerBackendGapCard(
                    title: 'Backend chua co API chi tiet change request',
                    message:
                        'Hien chi co PUT /change-requests/:id/approve. Chua co GET /change-requests/:id hoac GET /orders/:id/change-requests nen mobile khong tai duoc item, reason, quantity, cost impact va evidence that.',
                  ),
                  AppSizes.spacingL,
                  const InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trang thai hien tai cua man hinh',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Man hinh da bo MockData. Neu co changeRequestId, ban co the goi API approve/reject that. Phan noi dung chi tiet van can backend bo sung GET detail/list.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
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
                    text: _submitting ? 'Dang gui...' : 'Reject',
                    icon: Icons.cancel_outlined,
                    onPressed: _submitting ? null : () => _submit('REJECTED'),
                  ),
                ),
                const SizedBox(width: AppSizes.s),
                Expanded(
                  child: PrimaryButton(
                    text: _submitting ? 'Dang gui...' : 'Approve',
                    icon: Icons.check_circle_outline,
                    onPressed: _submitting ? null : () => _submit('APPROVED'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
