class AppRoutes {
  AppRoutes._();

  // Auth
  static const String login = '/';

  // Manager
  static const String managerDashboard = '/manager-dashboard';
  static const String managerToday = '/manager-today';
  static const String managerNotifications = '/manager-notifications';
  static const String managerOrderDetail = '/manager-order-detail';
  static const String managerFieldProgress = '/manager-field-progress';
  static const String managerSurveyReview = '/manager-survey-review';
  static const String managerChangeRequestApproval = '/manager-change-request-approval';
  static const String managerPaymentConfirmation = '/manager-payment-confirmation';
  static const String managerEvidenceGallery = '/manager-evidence-gallery';

  // Leader Staff
  static const String leaderDashboard = '/leader-dashboard';
  static const String leaderTasks = '/leader-tasks';
  static const String leaderTaskDetail = '/leader-task-detail';
  static const String leaderSurveyReport = '/leader-survey-report';
  static const String leaderProgressUpdate = '/leader-progress-update';
  static const String leaderCreateChangeRequest = '/leader-create-change-request';
  static const String leaderHandoverReport = '/leader-handover-report';
  static const String leaderDamageLossReport = '/leader-damage-loss-report';
  static const String leaderPaymentEvidenceUpload = '/leader-payment-evidence-upload';
  static const String leaderWarehouseReturnReport = '/leader-warehouse-return-report';

  // Technical Staff
  static const String technicalDashboard = '/technical-dashboard';
  static const String technicalTasks = '/technical-tasks';
  static const String technicalTaskDetail = '/technical-task-detail';
  static const String technicalPickList = '/technical-pick-list';
  static const String technicalTransportation = '/technical-transportation';
  static const String technicalInstallationChecklist = '/technical-installation-checklist';
  static const String technicalCollectionChecklist = '/technical-collection-checklist';
  static const String technicalWarehouseReturn = '/technical-warehouse-return';
  static const String technicalEvidenceUpload = '/technical-evidence-upload';

  // Common
  static const String notifications = '/notifications';
  static const String evidenceGallery = '/evidence-gallery';
  static const String orderDetail = '/order-detail';
  static const String fieldProgress = '/field-progress';
}
