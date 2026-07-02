import 'dart:convert';

class ManagerDashboardSummary {
  const ManagerDashboardSummary({
    required this.ordersInProgress,
    required this.pendingChangeRequests,
    required this.tasksToday,
    required this.alerts,
  });

  final int ordersInProgress;
  final int pendingChangeRequests;
  final int tasksToday;
  final List<ManagerAlert> alerts;

  factory ManagerDashboardSummary.fromJson(Map<String, dynamic> json) {
    final alertsJson = json['alerts'] as List<dynamic>? ?? const [];
    return ManagerDashboardSummary(
      ordersInProgress: _toInt(json['ordersInProgress']),
      pendingChangeRequests: _toInt(json['pendingChangeRequests']),
      tasksToday: _toInt(json['tasksToday']),
      alerts: alertsJson
          .map((item) => ManagerAlert.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ManagerAlert {
  const ManagerAlert({
    required this.type,
    this.workTaskId,
    this.orderId,
  });

  final String type;
  final String? workTaskId;
  final String? orderId;

  factory ManagerAlert.fromJson(Map<String, dynamic> json) {
    return ManagerAlert(
      type: (json['type'] ?? '').toString(),
      workTaskId: _toNullableString(json['workTaskId']),
      orderId: _toNullableString(json['orderId']),
    );
  }
}

class ManagerNotificationItem {
  const ManagerNotificationItem({
    required this.notificationId,
    required this.title,
    required this.content,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.refType,
    this.refId,
  });

  final String notificationId;
  final String title;
  final String content;
  final String type;
  final bool isRead;
  final DateTime? createdAt;
  final String? refType;
  final String? refId;

  factory ManagerNotificationItem.fromJson(Map<String, dynamic> json) {
    return ManagerNotificationItem(
      notificationId: _toNullableString(
            json['notificationId'] ?? json['id'],
          ) ??
          '',
      title: (json['title'] ?? '').toString(),
      content: (json['content'] ?? json['message'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      isRead: json['isRead'] == true,
      createdAt: _toDateTime(json['createdAt']),
      refType: _toNullableString(json['refType'] ?? json['targetRefType']),
      refId: _toNullableString(json['refId'] ?? json['targetRefId']),
    );
  }
}

class ManagerOrderSummary {
  const ManagerOrderSummary({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    this.customerId,
    this.eventStartDate,
    this.venueAddress,
    this.currentTask,
    this.lastUpdate,
  });

  final String orderId;
  final String orderNumber;
  final String status;
  final String? customerId;
  final DateTime? eventStartDate;
  final String? venueAddress;
  final String? currentTask;
  final DateTime? lastUpdate;

  factory ManagerOrderSummary.fromJson(Map<String, dynamic> json) {
    final orderId = _toNullableString(json['orderId'] ?? json['id']) ?? '';
    return ManagerOrderSummary(
      orderId: orderId,
      orderNumber:
          (json['orderNumber'] ?? json['orderCode'] ?? orderId).toString(),
      status: (json['status'] ?? '').toString(),
      customerId: _toNullableString(json['customerId']),
      eventStartDate: _toDateTime(json['eventStartDate'] ?? json['eventDate']),
      venueAddress:
          _toNullableString(json['venueAddress'] ?? json['eventLocation']),
      currentTask: _toNullableString(json['currentTask']),
      lastUpdate: _toDateTime(json['lastUpdate']),
    );
  }
}

class ManagerCustomerSummary {
  const ManagerCustomerSummary({
    required this.fullName,
    required this.phone,
  });

  final String fullName;
  final String phone;

  factory ManagerCustomerSummary.fromJson(Map<String, dynamic> json) {
    return ManagerCustomerSummary(
      fullName: (json['fullName'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
    );
  }
}

class ManagerOrderDetail {
  const ManagerOrderDetail({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    this.customerId,
    this.eventStartDate,
    this.venueAddress,
    this.customer,
    this.createdAt,
    this.updatedAt,
  });

  final String orderId;
  final String orderNumber;
  final String status;
  final String? customerId;
  final DateTime? eventStartDate;
  final String? venueAddress;
  final ManagerCustomerSummary? customer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ManagerOrderDetail.fromJson(Map<String, dynamic> json) {
    final customerJson = json['customer'];
    final orderId = _toNullableString(json['orderId'] ?? json['id']) ?? '';
    return ManagerOrderDetail(
      orderId: orderId,
      orderNumber:
          (json['orderNumber'] ?? json['orderCode'] ?? orderId).toString(),
      status: (json['status'] ?? '').toString(),
      customerId: _toNullableString(json['customerId']),
      eventStartDate: _toDateTime(json['eventStartDate'] ?? json['eventDate']),
      venueAddress:
          _toNullableString(json['venueAddress'] ?? json['eventLocation']),
      customer: customerJson is Map<String, dynamic>
          ? ManagerCustomerSummary.fromJson(customerJson)
          : null,
      createdAt: _toDateTime(json['createdAt']),
      updatedAt: _toDateTime(json['updatedAt']),
    );
  }
}

class ManagerTaskSummary {
  const ManagerTaskSummary({
    required this.workTaskId,
    required this.orderId,
    required this.taskType,
    required this.status,
    this.scheduledStart,
    this.scheduledEnd,
    this.location,
  });

  final String workTaskId;
  final String orderId;
  final String taskType;
  final String status;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final String? location;

  factory ManagerTaskSummary.fromJson(Map<String, dynamic> json) {
    final decodedDescription = _decodeDescription(json['description']);
    return ManagerTaskSummary(
      workTaskId: _toNullableString(json['workTaskId'] ?? json['id']) ?? '',
      orderId: _toNullableString(json['orderId']) ?? '',
      taskType:
          (json['taskType'] ?? json['taskCategory'] ?? json['title'] ?? '')
              .toString(),
      status: (json['status'] ?? '').toString(),
      scheduledStart: _toDateTime(
        json['scheduledStart'] ?? decodedDescription['scheduledStart'],
      ),
      scheduledEnd: _toDateTime(
        json['scheduledEnd'] ?? decodedDescription['scheduledEnd'],
      ),
      location:
          _toNullableString(json['location'] ?? decodedDescription['location']),
    );
  }
}

class ManagerSurveyReport {
  const ManagerSurveyReport({
    required this.workTaskId,
    required this.notes,
    required this.evidences,
    this.submittedAt,
  });

  final String workTaskId;
  final String notes;
  final List<ManagerEvidenceAsset> evidences;
  final DateTime? submittedAt;

  factory ManagerSurveyReport.fromJson(Map<String, dynamic> json) {
    final evidenceJson = json['evidences'] as List<dynamic>? ?? const [];
    return ManagerSurveyReport(
      workTaskId: _toNullableString(
              json['workTaskId'] ?? json['taskId'] ?? json['id']) ??
          '',
      notes: (json['notes'] ?? '').toString(),
      evidences: evidenceJson
          .map((item) =>
              ManagerEvidenceAsset.fromJson(item as Map<String, dynamic>))
          .toList(),
      submittedAt: _toDateTime(json['submittedAt']),
    );
  }
}

class ManagerPaymentRecord {
  const ManagerPaymentRecord({
    required this.paymentId,
    this.paymentRequestId,
    required this.amount,
    required this.paymentType,
    required this.paymentMethod,
    required this.status,
    this.paymentDate,
    required this.evidences,
  });

  final String paymentId;
  final String? paymentRequestId;
  final double amount;
  final String paymentType;
  final String paymentMethod;
  final String status;
  final DateTime? paymentDate;
  final List<ManagerEvidenceAsset> evidences;

  factory ManagerPaymentRecord.fromJson(Map<String, dynamic> json) {
    final evidenceJson = json['evidences'] as List<dynamic>? ?? const [];
    return ManagerPaymentRecord(
      paymentId: _toNullableString(
            json['paymentId'] ?? json['paymentRequestId'] ?? json['id'],
          ) ??
          '',
      paymentRequestId: _toNullableString(json['paymentRequestId']),
      amount: _toDouble(json['amount']),
      paymentType: (json['paymentType'] ?? 'Payment').toString(),
      paymentMethod:
          (json['paymentMethod'] ?? json['methodHint'] ?? json['method'] ?? '')
              .toString(),
      status: (json['status'] ?? '').toString(),
      paymentDate: _toDateTime(json['paymentDate'] ?? json['paidAt']),
      evidences: evidenceJson
          .map((item) =>
              ManagerEvidenceAsset.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ManagerChangeRequestDetail {
  const ManagerChangeRequestDetail({
    required this.changeRequestId,
    required this.orderId,
    required this.type,
    required this.status,
    required this.items,
    this.reason,
    this.noteFromLeader,
    this.estimatedCost,
  });

  final String changeRequestId;
  final String orderId;
  final String type;
  final String status;
  final String? reason;
  final String? noteFromLeader;
  final double? estimatedCost;
  final List<ManagerChangeRequestItem> items;

  factory ManagerChangeRequestDetail.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    return ManagerChangeRequestDetail(
      changeRequestId:
          _toNullableString(json['changeRequestId'] ?? json['id']) ?? '',
      orderId: _toNullableString(json['orderId']) ?? '',
      type: (json['type'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      reason: _toNullableString(json['reason']),
      noteFromLeader: _toNullableString(json['noteFromLeader']),
      estimatedCost: json['estimatedCost'] == null
          ? null
          : _toDouble(json['estimatedCost']),
      items: itemsJson
          .map((item) =>
              ManagerChangeRequestItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ManagerChangeRequestItem {
  const ManagerChangeRequestItem({
    required this.id,
    required this.equipmentItemId,
    required this.quantity,
    required this.action,
    this.note,
    this.equipmentItemName,
    this.equipmentItemCode,
  });

  final String id;
  final String equipmentItemId;
  final int quantity;
  final String action;
  final String? note;
  final String? equipmentItemName;
  final String? equipmentItemCode;

  factory ManagerChangeRequestItem.fromJson(Map<String, dynamic> json) {
    return ManagerChangeRequestItem(
      id: _toNullableString(json['id']) ?? '',
      equipmentItemId: _toNullableString(json['equipmentItemId']) ?? '',
      quantity: _toInt(json['quantity']),
      action: (json['action'] ?? '').toString(),
      note: _toNullableString(json['note']),
      equipmentItemName: _toNullableString(json['equipmentItemName']),
      equipmentItemCode: _toNullableString(json['equipmentItemCode']),
    );
  }
}

class ManagerVerificationSummary {
  const ManagerVerificationSummary({
    required this.orderId,
    required this.tasksCompleted,
    required this.totalTasks,
    required this.handoverStatus,
    required this.damageLossRecorded,
    required this.changeRequestsProcessed,
    required this.verificationStatus,
  });

  final String orderId;
  final int tasksCompleted;
  final int totalTasks;
  final String handoverStatus;
  final bool damageLossRecorded;
  final bool changeRequestsProcessed;
  final String verificationStatus;

  factory ManagerVerificationSummary.fromJson(Map<String, dynamic> json) {
    return ManagerVerificationSummary(
      orderId: _toNullableString(json['orderId']) ?? '',
      tasksCompleted: _toInt(json['tasksCompleted']),
      totalTasks: _toInt(json['totalTasks']),
      handoverStatus: (json['handoverStatus'] ?? '').toString(),
      damageLossRecorded: json['damageLossRecorded'] == true,
      changeRequestsProcessed: json['changeRequestsProcessed'] == true,
      verificationStatus: (json['verificationStatus'] ?? '').toString(),
    );
  }
}

class ManagerEvidenceAsset {
  const ManagerEvidenceAsset({
    required this.fileUrl,
    this.source,
  });

  final String fileUrl;
  final String? source;

  factory ManagerEvidenceAsset.fromJson(Map<String, dynamic> json) {
    return ManagerEvidenceAsset(
      fileUrl: (json['fileUrl'] ?? json['url'] ?? '').toString(),
      source: _toNullableString(json['source']),
    );
  }
}

class ManagerEvidenceBundle {
  const ManagerEvidenceBundle({
    required this.orderId,
    required this.surveyEvidences,
    required this.paymentEvidences,
    required this.operationNotes,
  });

  final String orderId;
  final List<ManagerEvidenceAsset> surveyEvidences;
  final List<ManagerEvidenceAsset> paymentEvidences;
  final List<String> operationNotes;
}

class ManagerApprovalItem {
  const ManagerApprovalItem({
    required this.approvalType,
    required this.referenceId,
    this.orderId,
    this.taskId,
    this.title,
    this.subtitle,
    this.status,
    this.createdAt,
    this.amountLabel,
  });

  final String approvalType;
  final String referenceId;
  final String? orderId;
  final String? taskId;
  final String? title;
  final String? subtitle;
  final String? status;
  final DateTime? createdAt;
  final String? amountLabel;
}

String? _toNullableString(dynamic value) {
  if (value == null) {
    return null;
  }
  final stringValue = value.toString();
  return stringValue.isEmpty ? null : stringValue;
}

int _toInt(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

double _toDouble(dynamic value) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _toDateTime(dynamic value) {
  if (value == null) {
    return null;
  }
  return DateTime.tryParse(value.toString());
}

Map<String, dynamic> _decodeDescription(dynamic value) {
  if (value is! String || value.isEmpty) {
    return const {};
  }

  try {
    final decoded = jsonDecode(value);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
  } catch (_) {}

  return const {};
}
