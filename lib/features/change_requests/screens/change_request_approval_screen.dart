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

class ChangeRequestApprovalScreen extends StatefulWidget {
  const ChangeRequestApprovalScreen({super.key});

  @override
  State<ChangeRequestApprovalScreen> createState() =>
      _ChangeRequestApprovalScreenState();
}

class _ChangeRequestApprovalScreenState
    extends State<ChangeRequestApprovalScreen> {
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
    }
  }

  Future<void> _submit(String status) async {
    if (_changeRequestId == null || _changeRequestId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có changeRequestId để gọi API.'),
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
        SnackBar(
            content: Text(
                'Đã gửi $status cho yêu cầu thay đổi ${_changeRequestId!}.')),
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
    final canSubmit = _changeRequestId != null && _changeRequestId!.isNotEmpty;

    return AppScaffold(
      useSafeArea: true,
      appBar: const CustomAppBar(
        title: 'Yêu cầu thay đổi',
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
                                'Yêu cầu thay đổi: ${_changeRequestId ?? '--'}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Đơn hàng: ${_orderId ?? '--'}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(label: canSubmit ? 'Sẵn sàng' : '--'),
                      ],
                    ),
                  ),
                  AppSizes.spacingL,
                  InfoCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Dữ liệu hiện có',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _DetailRow(
                            label: 'changeRequestId',
                            value: _changeRequestId ?? '--'),
                        const SizedBox(height: 8),
                        _DetailRow(label: 'orderId', value: _orderId ?? '--'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (canSubmit)
            Container(
              padding: const EdgeInsets.all(AppSizes.m),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: _submitting ? 'Đang gửi...' : 'Từ chối',
                      icon: Icons.cancel_outlined,
                      onPressed: _submitting ? null : () => _submit('REJECTED'),
                    ),
                  ),
                  const SizedBox(width: AppSizes.s),
                  Expanded(
                    child: PrimaryButton(
                      text: _submitting ? 'Đang gửi...' : 'Phê duyệt',
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

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
