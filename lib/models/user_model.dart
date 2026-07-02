class UserModel {
  final String id;
  final String username;
  final String fullName;
  final String role;
  final String status;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roleValue = json['role'];
    final rawRole = roleValue is Map<String, dynamic>
        ? (roleValue['code'] ??
                roleValue['roleCode'] ??
                roleValue['roleName'] ??
                roleValue['name'] ??
                '')
            .toString()
        : (roleValue ?? '').toString();

    return UserModel(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      role: _normalizeRole(rawRole),
      status: (json['status'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'role': role,
        'status': status,
      };

  bool get isAdmin => role == 'ADMIN';
  bool get isManager => role == 'MANAGER';
  bool get isLeader => role == 'LEADER_STAFF';
  bool get isTechnical => role == 'TECHNICAL_STAFF';
  bool get canUseMobileApp => isManager || isLeader || isTechnical;
  String get displayRole {
    switch (role) {
      case 'ADMIN':
        return 'Quản trị viên';
      case 'MANAGER':
        return 'Quản lý';
      case 'LEADER_STAFF':
        return 'Trưởng nhóm';
      case 'TECHNICAL_STAFF':
        return 'Nhân viên kỹ thuật';
      default:
        return role;
    }
  }

  String get displayStatus {
    switch (status.trim().toUpperCase()) {
      case 'ACTIVE':
        return 'Đang hoạt động';
      case 'INACTIVE':
        return 'Ngưng hoạt động';
      case 'LOCKED':
        return 'Bị khóa';
      default:
        return status;
    }
  }

  static String _normalizeRole(String role) {
    final normalized =
        role.trim().toUpperCase().replaceAll(RegExp(r'[\s-]+'), '_');

    switch (normalized) {
      case 'ADMIN':
        return 'ADMIN';
      case 'MANAGER':
        return 'MANAGER';
      case 'LEADER':
      case 'LEADER_STAFF':
        return 'LEADER_STAFF';
      case 'TECHNICAL':
      case 'TECHNICAL_STAFF':
        return 'TECHNICAL_STAFF';
      default:
        return normalized;
    }
  }
}
