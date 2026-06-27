import '../../../services/api_service.dart';
import '../models/manager_mobile_models.dart';

class ManagerMobileService {
  ManagerMobileService._();

  static Future<ManagerDashboardSummary> getDashboardSummary() async {
    final response = await ApiService.get('/dashboard/manager');
    return ManagerDashboardSummary.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  static Future<List<ManagerNotificationItem>> getNotifications({
    bool? isRead,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String>[
      'page=$page',
      'limit=$limit',
      if (isRead != null) 'isRead=$isRead',
    ].join('&');

    final response = await ApiService.get('/notifications?$query');
    final data = response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => ManagerNotificationItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> markNotificationRead(String notificationId) async {
    await ApiService.put('/notifications/$notificationId/read', const {});
  }

  static Future<List<ManagerOrderSummary>> getOrders({
    int page = 1,
    int limit = 20,
    String? status,
    String? search,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParts = <String>[
      'page=$page',
      'limit=$limit',
      if (status != null && status.isNotEmpty) 'status=$status',
      if (search != null && search.isNotEmpty) 'search=$search',
      if (startDate != null) 'startDate=${_formatDate(startDate)}',
      if (endDate != null) 'endDate=${_formatDate(endDate)}',
    ];

    final response = await ApiService.get('/orders?${queryParts.join('&')}');
    final data = response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => ManagerOrderSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ManagerOrderDetail> getOrderDetail(String orderId) async {
    final response = await ApiService.get('/orders/$orderId');
    return ManagerOrderDetail.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  static Future<List<ManagerOrderSummary>> getFieldProgressFeed() async {
    final response = await ApiService.get('/orders/field-progress');
    final data = response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => ManagerOrderSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<List<ManagerTaskSummary>> getTasks({
    String? orderId,
    String? taskType,
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParts = <String>[
      'page=$page',
      'limit=$limit',
      if (orderId != null && orderId.isNotEmpty) 'orderId=$orderId',
      if (taskType != null && taskType.isNotEmpty) 'taskType=$taskType',
      if (status != null && status.isNotEmpty) 'status=$status',
    ];

    final response = await ApiService.get('/tasks?${queryParts.join('&')}');
    final data = response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => ManagerTaskSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ManagerSurveyReport> getSurveyReport(String taskId) async {
    final response = await ApiService.get('/tasks/$taskId/survey-report');
    return ManagerSurveyReport.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  static Future<List<ManagerPaymentRecord>> getPaymentsByOrder(
    String orderId,
  ) async {
    final response = await ApiService.get('/orders/$orderId/payments');
    final data = response['data'] as List<dynamic>? ?? const [];
    return data
        .map((item) => ManagerPaymentRecord.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<void> confirmPayment({
    required String paymentId,
    required String status,
    String? evidenceUrl,
  }) async {
    await ApiService.put('/payments/$paymentId/confirm', {
      'status': status,
      if (evidenceUrl != null && evidenceUrl.isNotEmpty)
        'evidenceUrl': evidenceUrl,
    });
  }

  static Future<void> approveChangeRequest({
    required String changeRequestId,
    required String status,
  }) async {
    await ApiService.put('/change-requests/$changeRequestId/approve', {
      'status': status,
    });
  }

  static Future<void> confirmSettlement(String settlementId) async {
    await ApiService.put('/settlements/$settlementId/confirm', {
      'status': 'confirmed',
    });
  }

  static Future<ManagerVerificationSummary> getVerificationSummary(
    String orderId,
  ) async {
    final response = await ApiService.get('/reports/verification?orderId=$orderId');
    return ManagerVerificationSummary.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  static Future<ManagerEvidenceBundle> getEvidenceBundle({
    required String orderId,
    String? surveyTaskId,
  }) async {
    final payments = await getPaymentsByOrder(orderId);
    final surveyReport = surveyTaskId == null || surveyTaskId.isEmpty
        ? null
        : await getSurveyReport(surveyTaskId);

    return ManagerEvidenceBundle(
      orderId: orderId,
      surveyEvidences: surveyReport?.evidences ?? const [],
      paymentEvidences: payments.expand((payment) => payment.evidences).toList(),
      operationNotes: [
        if (surveyReport != null && surveyReport.notes.isNotEmpty) surveyReport.notes,
        'Current backend does not expose aggregated handover/damage/return evidence for manager mobile yet.',
      ],
    );
  }

  static String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
