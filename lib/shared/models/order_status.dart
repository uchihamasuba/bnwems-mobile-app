enum OrderStatus {
  pendingSurvey,
  surveying,
  pendingQuotation,
  pendingDeposit,
  deposited,
  executing,
  handedOver,
  collecting,
  settled,
  closed,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pendingSurvey:
        return 'Chờ khảo sát';
      case OrderStatus.surveying:
        return 'Đang khảo sát';
      case OrderStatus.pendingQuotation:
        return 'Chờ báo giá';
      case OrderStatus.pendingDeposit:
        return 'Chờ đặt cọc';
      case OrderStatus.deposited:
        return 'Đã cọc & chuẩn bị';
      case OrderStatus.executing:
        return 'Đang thi công';
      case OrderStatus.handedOver:
        return 'Đã bàn giao';
      case OrderStatus.collecting:
        return 'Đang thu hồi';
      case OrderStatus.settled:
        return 'Đã quyết toán';
      case OrderStatus.closed:
        return 'Đã đóng';
      case OrderStatus.cancelled:
        return 'Đã hủy';
    }
  }
}
