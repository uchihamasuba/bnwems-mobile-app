enum UserRole {
  manager,
  leader,
  technical;

  String get displayName {
    switch (this) {
      case UserRole.manager:
        return 'Manager';
      case UserRole.leader:
        return 'Leader Staff';
      case UserRole.technical:
        return 'Technical Staff';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
        return UserRole.manager;
      case 'leader':
      case 'leader staff':
      case 'leader_staff':
        return UserRole.leader;
      case 'technical':
      case 'technical staff':
      case 'technical_staff':
        return UserRole.technical;
      default:
        return UserRole.technical;
    }
  }
}
