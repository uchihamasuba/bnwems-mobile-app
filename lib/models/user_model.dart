/// User model matching the API Contract JSON schema.
class UserModel {
  final int id;
  final String username;
  final String fullName;
  final String email;
  final String? phone;
  final String status;
  final RoleModel role;

  const UserModel({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    this.phone,
    required this.status,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      status: json['status'] as String,
      role: RoleModel.fromJson(json['role'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'status': status,
        'role': role.toJson(),
      };
}

class RoleModel {
  final int id;
  final String roleName;
  final List<String> permissions;

  const RoleModel({
    required this.id,
    required this.roleName,
    required this.permissions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as int,
      roleName: json['roleName'] as String,
      permissions: json['permissions'] != null
          ? List<String>.from(json['permissions'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'roleName': roleName,
        'permissions': permissions,
      };
}
