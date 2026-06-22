import 'user_role.dart';
import 'order_status.dart';
import 'payment_status.dart';
import 'evidence_type.dart';

// 1. AppUser
class AppUser {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
  });
}

// 2. MobileNotification
class MobileNotification {
  final String id;
  final String title;
  final String orderCode;
  final String message;
  final String type; // Order, Payment, Survey, Field Operation, Change Request, Damage/Loss
  final String priority; // High, Medium, Low
  final DateTime createdAt;
  bool isRead;
  final String targetRoute;

  MobileNotification({
    required this.id,
    required this.title,
    required this.orderCode,
    required this.message,
    required this.type,
    required this.priority,
    required this.createdAt,
    this.isRead = false,
    required this.targetRoute,
  });
}

// 3. MobileOrder
class MobileOrder {
  final String id;
  final String orderCode;
  final String customerName;
  final String customerPhone;
  final DateTime eventDateTime;
  final String location;
  final String leaderStaffName;
  final OrderStatus orderStatus;
  final PaymentStatus paymentStatus;
  final String surveyStatus; // Pending, Approved, Need More Info
  final String fieldProgressStatus; // Check-out -> Transportation -> Installation -> Handover -> Collection -> Return -> Completed
  final bool hasEmergency;
  final String? urgencyMessage;
  final double totalAmount;
  final double paidAmount;

  const MobileOrder({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.customerPhone,
    required this.eventDateTime,
    required this.location,
    required this.leaderStaffName,
    required this.orderStatus,
    required this.paymentStatus,
    required this.surveyStatus,
    required this.fieldProgressStatus,
    this.hasEmergency = false,
    this.urgencyMessage,
    required this.totalAmount,
    required this.paidAmount,
  });

  double get balanceDue => totalAmount - paidAmount;

  MobileOrder copyWith({
    OrderStatus? orderStatus,
    PaymentStatus? paymentStatus,
    String? surveyStatus,
    String? fieldProgressStatus,
    double? paidAmount,
    double? totalAmount,
  }) {
    return MobileOrder(
      id: id,
      orderCode: orderCode,
      customerName: customerName,
      customerPhone: customerPhone,
      eventDateTime: eventDateTime,
      location: location,
      leaderStaffName: leaderStaffName,
      orderStatus: orderStatus ?? this.orderStatus,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      surveyStatus: surveyStatus ?? this.surveyStatus,
      fieldProgressStatus: fieldProgressStatus ?? this.fieldProgressStatus,
      hasEmergency: hasEmergency,
      urgencyMessage: urgencyMessage,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
    );
  }
}

// 4. MobileTask
class MobileTask {
  final String id;
  final String taskName;
  final String orderCode;
  final UserRole assignedRole;
  final String assignedTo;
  final String location;
  final DateTime scheduledTime;
  String status; // pending, inProgress, completed, delayed
  final String priority; // High, Medium, Low
  final List<ChecklistItem> checklistItems;

  MobileTask({
    required this.id,
    required this.taskName,
    required this.orderCode,
    required this.assignedRole,
    required this.assignedTo,
    required this.location,
    required this.scheduledTime,
    required this.status,
    required this.priority,
    required this.checklistItems,
  });
}

class ChecklistItem {
  final String label;
  bool isCompleted;

  ChecklistItem({
    required this.label,
    this.isCompleted = false,
  });
}

// 5. FieldProgressStep
class FieldProgressStep {
  final String id;
  final String stepName;
  String status; // pending, inProgress, completed, delayed
  final String updatedBy;
  final String updatedAt;
  final String? note;
  final int evidenceCount;

  FieldProgressStep({
    required this.id,
    required this.stepName,
    required this.status,
    required this.updatedBy,
    required this.updatedAt,
    this.note,
    this.evidenceCount = 0,
  });
}

// 6. SurveyReport
class SurveyReport {
  final String id;
  final String orderCode;
  final String customerName;
  final String location;
  final String leaderStaffName;
  final DateTime surveyDate;
  final double areaSize;
  final double entranceWidth;
  final String installationPosition;
  final String transportationCondition;
  final String constructionRisk;
  final String notes;
  final List<String> photoUrls;
  String approvalStatus; // Pending, Approved, Need More Info

  SurveyReport({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.location,
    required this.leaderStaffName,
    required this.surveyDate,
    required this.areaSize,
    required this.entranceWidth,
    required this.installationPosition,
    required this.transportationCondition,
    required this.constructionRisk,
    required this.notes,
    required this.photoUrls,
    this.approvalStatus = 'Pending',
  });
}

// 7. ChangeRequest
class ChangeRequest {
  final String id;
  final String orderCode;
  final String customerName;
  final String requestType; // Add, Remove, Replace, Change Plan
  final String itemName;
  final int quantity;
  final String reason;
  final double costImpact;
  final String inventoryAvailability;
  final String noteFromLeader;
  final List<String> evidenceUrls;
  String approvalStatus; // Pending, Approved, Rejected, Need More Info

  ChangeRequest({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.requestType,
    required this.itemName,
    required this.quantity,
    required this.reason,
    required this.costImpact,
    required this.inventoryAvailability,
    required this.noteFromLeader,
    required this.evidenceUrls,
    this.approvalStatus = 'Pending',
  });
}

// 8. PaymentConfirmation
class PaymentConfirmation {
  final String id;
  final String orderCode;
  final String customerName;
  final String paymentType; // Deposit, Final Payment
  final double requiredAmount;
  final double paidAmount;
  final String paymentMethod;
  final String evidenceUrl;
  final String submittedBy;
  final DateTime submittedAt;
  String status; // Pending, Approved, Rejected, Need More Evidence

  PaymentConfirmation({
    required this.id,
    required this.orderCode,
    required this.customerName,
    required this.paymentType,
    required this.requiredAmount,
    required this.paidAmount,
    required this.paymentMethod,
    required this.evidenceUrl,
    required this.submittedBy,
    required this.submittedAt,
    this.status = 'Pending',
  });
}

// 9. EvidenceItem
class EvidenceItem {
  final String id;
  final String orderCode;
  final EvidenceType type;
  final String imageUrl;
  final String title;
  final String uploadedBy;
  final DateTime uploadedAt;
  final String note;

  const EvidenceItem({
    required this.id,
    required this.orderCode,
    required this.type,
    required this.imageUrl,
    required this.title,
    required this.uploadedBy,
    required this.uploadedAt,
    required this.note,
  });
}
