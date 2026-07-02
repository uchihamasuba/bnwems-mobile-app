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
        .map((item) =>
            ManagerNotificationItem.fromJson(item as Map<String, dynamic>))
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
        .map((item) =>
            ManagerOrderSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ManagerOrderDetail> getOrderDetail(String orderId) async {
    final response = await ApiService.get('/orders/$orderId');
    return ManagerOrderDetail.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  static Future<List<ManagerOrderSummary>> getFieldProgressFeed() async {
    // Manager-wide field progress feed from backend.
    final response = await ApiService.get('/orders/field-progress');
    final data = response['data'] as List<dynamic>? ?? const [];
    final feed = data
        .map((item) =>
            ManagerOrderSummary.fromJson(item as Map<String, dynamic>))
        .toList();

    if (feed.isEmpty) {
      return feed;
    }

    final orders = await getOrders(limit: 100);
    final ordersById = {
      for (final order in orders) order.orderId: order,
    };

    return feed.map((item) {
      final order = ordersById[item.orderId];
      if (order == null) {
        return item;
      }
      return ManagerOrderSummary(
        orderId: item.orderId,
        orderNumber: order.orderNumber,
        status: item.status.isNotEmpty ? item.status : order.status,
        customerId: order.customerId,
        eventStartDate: order.eventStartDate,
        venueAddress: order.venueAddress,
        currentTask: item.currentTask,
        lastUpdate: item.lastUpdate,
      );
    }).toList();
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
        .map(
            (item) => ManagerTaskSummary.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static Future<ManagerTaskSummary?> getSurveyTaskByOrder(
      String orderId) async {
    final tasks = await getTasks(orderId: orderId, page: 1, limit: 50);

    for (final task in tasks) {
      final normalized = task.taskType.toLowerCase();
      if (normalized.contains('survey') || normalized.contains('khao sat')) {
        return task;
      }
    }

    return null;
  }

  static Future<ManagerSurveyReport> getSurveyReport(String taskId) async {
    final response = await ApiService.get('/tasks/$taskId/survey-report');
    return ManagerSurveyReport.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  static Future<void> reviewSurveyReport({
    required String taskId,
    required String status,
  }) async {
    await ApiService.put('/tasks/$taskId/survey-report/review', {
      'status': status,
    });
  }

  static Future<List<ManagerPaymentRecord>> getPaymentsByOrder(
    String orderId,
  ) async {
    final response = await ApiService.get('/orders/$orderId/payments');
    final data = response['data'] as List<dynamic>? ?? const [];
    final payments = data
        .map((item) =>
            ManagerPaymentRecord.fromJson(item as Map<String, dynamic>))
        .toList();

    return Future.wait(
      payments.map((payment) async {
        final requestId = payment.paymentRequestId;
        if (requestId == null || requestId.isEmpty) {
          return payment;
        }

        try {
          final detail = await getPaymentRequestDetail(requestId);
          return ManagerPaymentRecord(
            paymentId: payment.paymentId,
            paymentRequestId: payment.paymentRequestId,
            amount: payment.amount,
            paymentType: detail.paymentType.isNotEmpty
                ? detail.paymentType
                : payment.paymentType,
            paymentMethod: detail.paymentMethod.isNotEmpty
                ? detail.paymentMethod
                : payment.paymentMethod,
            status: payment.status,
            paymentDate: payment.paymentDate,
            evidences: payment.evidences,
          );
        } catch (_) {
          return payment;
        }
      }),
    );
  }

  static Future<ManagerPaymentRecord> getPaymentRequestDetail(
    String paymentRequestId,
  ) async {
    final response = await ApiService.get('/payment-requests/$paymentRequestId');
    return ManagerPaymentRecord.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  static Future<ManagerPaymentRecord?> getLatestPaymentByOrder(
      String orderId) async {
    final payments = await getPaymentsByOrder(orderId);
    if (payments.isEmpty) {
      return null;
    }
    return payments.first;
  }

  static Future<void> confirmPayment({
    required String paymentRequestId,
    required String status,
    String? evidenceUrl,
  }) async {
    await ApiService.put('/payment-requests/$paymentRequestId/confirm', {
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

  static Future<ManagerChangeRequestDetail> getChangeRequestDetail(
    String changeRequestId,
  ) async {
    final response = await ApiService.get('/change-requests/$changeRequestId');
    return ManagerChangeRequestDetail.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  static Future<void> confirmSettlement(String settlementId) async {
    await ApiService.put('/settlements/$settlementId/confirm', {
      'status': 'confirmed',
    });
  }

  static Future<ManagerVerificationSummary> getVerificationSummary(
    String orderId,
  ) async {
    final response =
        await ApiService.get('/reports/verification?orderId=$orderId');
    return ManagerVerificationSummary.fromJson(
      response['data'] as Map<String, dynamic>,
    );
  }

  static Future<ManagerEvidenceBundle> getEvidenceBundle({
    required String orderId,
    String? surveyTaskId,
  }) async {
    ManagerSurveyReport? surveyReport;
    if (surveyTaskId != null && surveyTaskId.isNotEmpty) {
      try {
        surveyReport = await getSurveyReport(surveyTaskId);
      } catch (_) {
        surveyReport = null;
      }
    }
    final response = await ApiService.get('/orders/$orderId/evidences');
    final rawEvidences = response['data'] as List<dynamic>? ?? const [];
    final surveyEvidences = <ManagerEvidenceAsset>[];
    final paymentEvidences = <ManagerEvidenceAsset>[];

    for (final item in rawEvidences.whereType<Map<String, dynamic>>()) {
      final asset = ManagerEvidenceAsset.fromJson(item);
      final refType = (item['refType'] ?? '').toString().toLowerCase();
      if (refType.contains('survey')) {
        surveyEvidences.add(asset);
      } else if (refType.contains('payment')) {
        paymentEvidences.add(asset);
      }
    }

    return ManagerEvidenceBundle(
      orderId: orderId,
      surveyEvidences: surveyEvidences.isNotEmpty
          ? surveyEvidences
          : surveyReport?.evidences ?? const [],
      paymentEvidences: paymentEvidences,
      operationNotes: surveyReport != null && surveyReport.notes.isNotEmpty
          ? [surveyReport.notes]
          : const [],
    );
  }

  static Future<List<ManagerApprovalItem>> getManagerApprovals() async {
    final response = await ApiService.get('/manager/approvals');
    final data = response['data'] as Map<String, dynamic>? ?? const {};
    final approvals = <ManagerApprovalItem>[];

    final changeRequests =
        data['changeRequests'] as List<dynamic>? ?? const <dynamic>[];
    for (final item in changeRequests.whereType<Map<String, dynamic>>()) {
      final changeRequestId =
          (item['changeRequestId'] ?? item['id'] ?? '').toString();
      if (changeRequestId.isEmpty) {
        continue;
      }
      approvals.add(
        ManagerApprovalItem(
          approvalType: 'change_request',
          referenceId: changeRequestId,
          orderId: _toNullableString(item['orderId']),
          title: 'Change request $changeRequestId',
          subtitle:
              (item['reason'] ?? item['noteFromLeader'] ?? '').toString(),
          status: _toNullableString(item['status']),
          createdAt: _toDateTime(item['createdAt']),
        ),
      );
    }

    final surveyReports =
        data['surveyReports'] as List<dynamic>? ?? const <dynamic>[];
    for (final item in surveyReports.whereType<Map<String, dynamic>>()) {
      final surveyReportId =
          (item['surveyReportId'] ?? item['id'] ?? '').toString();
      if (surveyReportId.isEmpty) {
        continue;
      }
      approvals.add(
        ManagerApprovalItem(
          approvalType: 'survey_report',
          referenceId: surveyReportId,
          orderId: _toNullableString(item['orderId']),
          taskId: _toNullableString(item['workTaskId']),
          title: 'Survey report $surveyReportId',
          subtitle:
              (item['siteCondition'] ?? item['reviewNote'] ?? '').toString(),
          status: _toNullableString(item['status']),
          createdAt: _toDateTime(item['createdAt']),
        ),
      );
    }

    final paymentRequests =
        data['paymentRequests'] as List<dynamic>? ?? const <dynamic>[];
    for (final item in paymentRequests.whereType<Map<String, dynamic>>()) {
      final paymentRequestId =
          (item['paymentRequestId'] ?? item['id'] ?? '').toString();
      if (paymentRequestId.isEmpty) {
        continue;
      }
      approvals.add(
        ManagerApprovalItem(
          approvalType: 'payment_request',
          referenceId: paymentRequestId,
          orderId: _toNullableString(item['orderId']),
          title: 'Payment request $paymentRequestId',
          subtitle: (item['paymentType'] ?? 'payment').toString(),
          status: _toNullableString(item['status']),
          createdAt: _toDateTime(item['createdAt']),
          amountLabel: item['amount']?.toString(),
        ),
      );
    }

    approvals.sort((a, b) {
      final aTime = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    return approvals;
  }

  static String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final stringValue = value.toString();
    return stringValue.isEmpty ? null : stringValue;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
