import 'models/app_user.dart';

/// Dummy auth data used until the backend exists.
abstract final class AuthDemoData {
  /// Password that simulates a credentials failure, to preview the error UI.
  static const String wrongPassword = 'wrong';

  /// Brokerage name of every dummy user.
  static const String brokerageName = 'Skyline Realty';

  /// Dummy display names per role.
  static const Map<UserRole, String> namesByRole = {
    UserRole.brokerageAdmin: 'Priya Sharma',
    UserRole.salesAgent: 'Arjun Mehta',
    UserRole.teamLead: 'Neha Kapoor',
    UserRole.operations: 'Ravi Iyer',
    UserRole.complianceReviewer: 'Sara Thomas',
  };

  /// Roles offered by the debug "Preview as" switch.
  static const List<UserRole> previewRoles = [
    UserRole.brokerageAdmin,
    UserRole.salesAgent,
    UserRole.teamLead,
  ];

  /// Short labels for the preview chips.
  static const Map<UserRole, String> previewLabels = {
    UserRole.brokerageAdmin: 'Admin',
    UserRole.salesAgent: 'Agent',
    UserRole.teamLead: 'Team lead',
  };

  /// Email used for provider sign-ins that don't ask for one.
  static const String providerEmail = 'priya@skylinerealty.in';

  /// Builds the dummy user for [role] and [email].
  static AppUser userFor(UserRole role, String email) {
    return AppUser(
      id: 'demo-${role.name}',
      name: namesByRole[role] ?? role.label,
      email: email,
      role: role,
      brokerageName: brokerageName,
    );
  }
}
