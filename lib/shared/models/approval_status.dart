enum ApprovalStatus {
  pending,
  approved,
  rejected,
  needMoreInfo;

  String get displayName {
    switch (this) {
      case ApprovalStatus.pending:
        return 'Chờ duyệt';
      case ApprovalStatus.approved:
        return 'Đã duyệt';
      case ApprovalStatus.rejected:
        return 'Từ chối';
      case ApprovalStatus.needMoreInfo:
        return 'Cần bổ sung tin';
    }
  }

  static ApprovalStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'approved':
        return ApprovalStatus.approved;
      case 'rejected':
        return ApprovalStatus.rejected;
      case 'needmoreinfo':
      case 'need_more_info':
      case 'needs info':
      case 'needs_info':
        return ApprovalStatus.needMoreInfo;
      case 'pending':
      default:
        return ApprovalStatus.pending;
    }
  }
}
