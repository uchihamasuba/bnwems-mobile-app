// Use backend IDs for API calls.
// Keep orderCode only for display or fallback during the mock-to-real transition.
class ManagerOrderRouteArgs {
  const ManagerOrderRouteArgs({
    required this.orderId,
    this.orderCode,
  });

  final String orderId;
  final String? orderCode;
}

class ManagerSurveyRouteArgs {
  const ManagerSurveyRouteArgs({
    required this.taskId,
    this.orderId,
  });

  final String taskId;
  final String? orderId;
}

class ManagerChangeRequestRouteArgs {
  const ManagerChangeRequestRouteArgs({
    required this.changeRequestId,
    this.orderId,
  });

  final String changeRequestId;
  final String? orderId;
}

class ManagerPaymentRouteArgs {
  const ManagerPaymentRouteArgs({
    this.paymentId,
    this.paymentRequestId,
    this.orderId,
  });

  final String? paymentId;
  final String? paymentRequestId;
  final String? orderId;
}

class ManagerEvidenceRouteArgs {
  const ManagerEvidenceRouteArgs({
    required this.orderId,
    this.taskId,
  });

  final String orderId;
  final String? taskId;
}
