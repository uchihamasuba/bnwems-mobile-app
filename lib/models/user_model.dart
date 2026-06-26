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
    final roleName = roleValue is Map<String, dynamic>
        ? (roleValue['roleName'] ?? '').toString()
        : (roleValue ?? '').toString();

    return UserModel(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      username: (json['username'] ?? '').toString(),
      fullName: (json['fullName'] ?? '').toString(),
      role: roleName,
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
}
