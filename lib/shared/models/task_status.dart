enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get displayName {
    switch (this) {
      case TaskStatus.pending:
        return 'Chờ thực hiện';
      case TaskStatus.inProgress:
        return 'Đang thực hiện';
      case TaskStatus.completed:
        return 'Hoàn thành';
      case TaskStatus.cancelled:
        return 'Đã hủy';
    }
  }
}
