class ManagerFeatureDefinition {
  const ManagerFeatureDefinition({
    required this.featureKey,
    required this.screenName,
    required this.route,
    required this.purpose,
    required this.apis,
    this.backendGap = false,
    this.notes = const [],
  });

  final String featureKey;
  final String screenName;
  final String route;
  final String purpose;
  final List<String> apis;
  final bool backendGap;
  final List<String> notes;
}

class ManagerFeatureRegistry {
  ManagerFeatureRegistry._();

  static const List<ManagerFeatureDefinition> features = [
    ManagerFeatureDefinition(
      featureKey: 'login',
      screenName: 'Login Screen',
      route: '/',
      purpose: 'Authenticate manager and restore/clear session.',
      apis: [
        'POST /auth/login',
        'GET /auth/profile',
        'POST /auth/logout',
        'PUT /auth/change-password',
      ],
    ),
    ManagerFeatureDefinition(
      featureKey: 'dashboard',
      screenName: 'Mobile Dashboard',
      route: '/manager-dashboard',
      purpose: 'Quick operational summary and urgent approval counters.',
      apis: [
        'GET /dashboard/manager',
        'GET /orders',
        'GET /tasks',
        'GET /notifications',
        'GET /orders/field-progress',
      ],
      notes: [
        'Dashboard khong phu thuoc vao payment approval queue.',
      ],
    ),
    ManagerFeatureDefinition(
      featureKey: 'notifications',
      screenName: 'Notification Screen',
      route: '/manager-notifications',
      purpose: 'Read urgent notifications and jump to action screens.',
      apis: [
        'GET /notifications',
        'PUT /notifications/:id/read',
      ],
    ),
    ManagerFeatureDefinition(
      featureKey: 'today',
      screenName: 'Today Order / Task List Screen',
      route: '/manager-today',
      purpose: 'See today orders, running tasks, and current field status.',
      apis: [
        'GET /orders',
        'GET /tasks',
        'GET /orders/field-progress',
      ],
    ),
    ManagerFeatureDefinition(
      featureKey: 'order_detail',
      screenName: 'Order Detail Screen',
      route: '/manager-order-detail',
      purpose: 'Read compact order, payment, and operation status.',
      apis: [
        'GET /orders/:id',
        'GET /orders/:id/payments',
        'GET /reports/verification',
      ],
      notes: [
        'FE needs to compose a compact mobile detail from multiple endpoints.',
      ],
    ),
    ManagerFeatureDefinition(
      featureKey: 'field_progress',
      screenName: 'Field Progress Screen',
      route: '/manager-field-progress',
      purpose: 'Track live field progress and detect delayed steps.',
      apis: [
        'GET /orders/field-progress',
        'GET /tasks',
        'GET /reports/verification',
      ],
      notes: [
        'Uses the manager-wide field progress feed returned by the backend.',
      ],
    ),
    ManagerFeatureDefinition(
      featureKey: 'survey_review',
      screenName: 'Survey Report Review Screen',
      route: '/manager-survey-review',
      purpose: 'Read survey report, photos, and manager review decision.',
      apis: [
        'GET /tasks/:id/survey-report',
        'PUT /tasks/:id/survey-report/review',
      ],
      notes: [
        'Manager can review survey reports directly from the mobile flow.',
      ],
    ),
    ManagerFeatureDefinition(
      featureKey: 'change_request',
      screenName: 'Change Request Approval Screen',
      route: '/manager-change-request-approval',
      purpose: 'Approve or reject field change requests.',
      apis: [
        'GET /change-requests/:id',
        'GET /orders/:id/change-requests',
        'PUT /change-requests/:id/approve',
      ],
      notes: [
        'Change-request detail and order-level list endpoints are available.',
      ],
    ),
    ManagerFeatureDefinition(
      featureKey: 'payment_confirmation',
      screenName: 'Payment Confirmation Screen',
      route: '/manager-payment-confirmation',
      purpose: 'Inspect payment evidence and confirm payment.',
      apis: [
        'GET /orders/:id/payments',
        'GET /payment-requests/:id',
        'PUT /payment-requests/:id/confirm',
      ],
      notes: [
        'Payment confirmation is performed on payment requests.',
        'GET /manager/approvals hien chua tra paymentRequests, nen payment duoc mo tu order detail hoac notification.',
      ],
    ),
    ManagerFeatureDefinition(
      featureKey: 'evidence_gallery',
      screenName: 'Evidence Gallery Screen',
      route: '/manager-evidence-gallery',
      purpose:
          'Browse submitted evidence across survey, payment, and field ops.',
      apis: [
        'GET /tasks/:id/survey-report',
        'GET /orders/:id/evidences',
        'GET /orders/:id/payments',
        'GET /reports/verification',
      ],
      notes: [
        'Order-level evidence endpoint is available for aggregated review.',
      ],
    ),
  ];
}
