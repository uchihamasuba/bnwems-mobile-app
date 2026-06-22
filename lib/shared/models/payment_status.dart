enum PaymentStatus {
  unpaid,
  partiallyPaid,
  paid,
  refunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.unpaid:
        return 'Chưa thanh toán';
      case PaymentStatus.partiallyPaid:
        return 'Thanh toán một phần';
      case PaymentStatus.paid:
        return 'Đã thanh toán';
      case PaymentStatus.refunded:
        return 'Đã hoàn tiền';
    }
  }
}
