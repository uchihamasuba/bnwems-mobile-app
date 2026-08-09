import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_strings.dart';
import 'services/auth_service.dart';

// Auth
import 'features/auth/screens/login_screen.dart';

// Manager Screens
import 'features/manager/widgets/manager_app_shell.dart';
import 'features/manager/today/manager_today_screen.dart';

// Leader Screens
import 'features/leader/widgets/leader_app_shell.dart';
import 'features/leader/tasks/leader_task_list_screen.dart';
import 'features/leader/tasks/leader_task_detail_screen.dart';
import 'features/leader/survey/leader_survey_report_screen.dart';
import 'features/leader/progress_update/leader_progress_update_screen.dart';
import 'features/leader/change_requests/leader_create_change_request_screen.dart';
import 'features/leader/handover/leader_handover_report_screen.dart';
import 'features/leader/damage_loss/leader_damage_loss_report_screen.dart';
import 'features/leader/payment_evidence/leader_payment_evidence_upload_screen.dart';
import 'features/leader/warehouse_return/leader_warehouse_return_report_screen.dart';

// Technical Screens
import 'features/technical/widgets/technical_app_shell.dart';
import 'features/technical/tasks/technical_task_list_screen.dart';
import 'features/technical/tasks/technical_task_detail_screen.dart';
import 'features/technical/pick_list/technical_pick_list_screen.dart';
import 'features/technical/transportation/technical_transportation_screen.dart';
import 'features/technical/installation/technical_installation_checklist_screen.dart';
import 'features/technical/collection/technical_collection_checklist_screen.dart';
import 'features/technical/warehouse_return/technical_warehouse_return_screen.dart';
import 'features/technical/tasks/technical_evidence_upload_screen.dart';

// Common Screens
import 'features/notifications/screens/notifications_screen.dart';
import 'features/evidence/screens/evidence_gallery_screen.dart';
import 'features/orders/screens/order_detail_screen.dart';
import 'features/field_progress/screens/field_progress_screen.dart';
import 'features/survey_review/screens/survey_review_screen.dart';
import 'features/change_requests/screens/change_request_approval_screen.dart';
import 'features/payments/screens/payment_confirmation_screen.dart';

class BnwemsApp extends StatelessWidget {
  const BnwemsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.startup,
      routes: {
        // Auth
        AppRoutes.startup: (context) => const _AppStartGate(),
        AppRoutes.login: (context) => const LoginScreen(),

        // Manager
        AppRoutes.managerDashboard: (context) => const ManagerAppShell(),
        AppRoutes.managerToday: (context) => const ManagerTodayScreen(),
        AppRoutes.managerNotifications: (context) =>
            const NotificationsScreen(),
        AppRoutes.managerOrderDetail: (context) => const OrderDetailScreen(),
        AppRoutes.managerFieldProgress: (context) =>
            const FieldProgressScreen(),
        AppRoutes.managerSurveyReview: (context) => const SurveyReviewScreen(),
        AppRoutes.managerChangeRequestApproval: (context) =>
            const ChangeRequestApprovalScreen(),
        AppRoutes.managerPaymentConfirmation: (context) =>
            const PaymentConfirmationScreen(),
        AppRoutes.managerEvidenceGallery: (context) =>
            const EvidenceGalleryScreen(),

        // Leader Staff
        AppRoutes.leaderDashboard: (context) => const LeaderAppShell(),
        AppRoutes.leaderTasks: (context) => const LeaderTaskListScreen(),
        AppRoutes.leaderTaskDetail: (context) => const LeaderTaskDetailScreen(),
        AppRoutes.leaderSurveyReport: (context) =>
            const LeaderSurveyReportScreen(),
        AppRoutes.leaderProgressUpdate: (context) =>
            const LeaderProgressUpdateScreen(),
        AppRoutes.leaderCreateChangeRequest: (context) =>
            const LeaderCreateChangeRequestScreen(),
        AppRoutes.leaderHandoverReport: (context) =>
            const LeaderHandoverReportScreen(),
        AppRoutes.leaderDamageLossReport: (context) =>
            const LeaderDamageLossReportScreen(),
        AppRoutes.leaderPaymentEvidenceUpload: (context) =>
            const LeaderPaymentEvidenceUploadScreen(),
        AppRoutes.leaderWarehouseReturnReport: (context) =>
            const LeaderWarehouseReturnReportScreen(),

        // Technical Staff
        AppRoutes.technicalDashboard: (context) => const TechnicalAppShell(),
        AppRoutes.technicalTasks: (context) => const TechnicalTaskListScreen(),
        AppRoutes.technicalTaskDetail: (context) =>
            const TechnicalTaskDetailScreen(),
        AppRoutes.technicalPickList: (context) =>
            const TechnicalPickListScreen(),
        AppRoutes.technicalTransportation: (context) =>
            const TechnicalTransportationScreen(),
        AppRoutes.technicalInstallationChecklist: (context) =>
            const TechnicalInstallationChecklistScreen(),
        AppRoutes.technicalCollectionChecklist: (context) =>
            const TechnicalCollectionChecklistScreen(),
        AppRoutes.technicalWarehouseReturn: (context) =>
            const TechnicalWarehouseReturnScreen(),
        AppRoutes.technicalEvidenceUpload: (context) =>
            const TechnicalEvidenceUploadScreen(),

        // Common
        AppRoutes.notifications: (context) => const NotificationsScreen(),
        AppRoutes.evidenceGallery: (context) => const EvidenceGalleryScreen(),
        AppRoutes.orderDetail: (context) => const OrderDetailScreen(),
        AppRoutes.fieldProgress: (context) => const FieldProgressScreen(),
      },
    );
  }
}

class _AppStartGate extends StatefulWidget {
  const _AppStartGate();

  @override
  State<_AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<_AppStartGate> {
  static const Color _background = Color(0xFFFBF8F3);
  static const Color _accent = Color(0xFF894D58);
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _redirectToInitialRoute();
  }

  Future<void> _redirectToInitialRoute() async {
    if (!mounted || _navigated) return;

    final user = await AuthService.getStoredUser();

    if (!mounted || _navigated) return;

    _navigated = true;
    
    if (user != null) {
      if (user.isManager) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.managerDashboard);
      } else if (user.isLeader) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.leaderDashboard);
      } else if (user.isTechnical) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.technicalDashboard);
      } else {
        await AuthService.logout();
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _background,
      body: Center(
        child: CircularProgressIndicator(
          color: _accent,
        ),
      ),
    );
  }
}
