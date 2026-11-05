/// Workspace roles. The role decides which onboarding flow a user sees.
enum UserRole {
  /// Sets up the brokerage, integrations and AI agent.
  brokerageAdmin('Brokerage admin'),

  /// Receives hot leads and calls them back.
  salesAgent('Sales agent'),

  /// Manages a team of sales agents.
  teamLead('Team lead'),

  /// Runs day-to-day operations.
  operations('Operations'),

  /// Reviews calls and consent for compliance.
  complianceReviewer('Compliance reviewer');

  /// Creates a role with its display label.
  const UserRole(this.label);

  /// Human-readable role name.
  final String label;

  /// Role for the backend's role string (the enum name), or null if unknown.
  static UserRole? fromName(String? name) {
    for (final role in values) {
      if (role.name == name) return role;
    }
    return null;
  }
}

/// The signed-in user.
class AppUser {
  /// Creates a user.
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.brokerageName,
    this.isOnboardingComplete = false,
  });

  /// Parses `details` from `GET /api/auth/me`. Throws [FormatException]
  /// when the id, email or role is missing or unknown.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    final id = json['_id'];
    final email = json['email'];
    final role = UserRole.fromName(json['role'] as String?);
    if (id is! String || email is! String || role == null) {
      throw const FormatException('Invalid user in API response');
    }
    final name = json['name'];
    final brokerageName = json['brokerageName'];
    return AppUser(
      id: id,
      // Invited users have no name until their profile step.
      name: name is String ? name.trim() : '',
      email: email,
      role: role,
      brokerageName: brokerageName is String ? brokerageName : '',
      isOnboardingComplete: json['onboardingCompleted'] == true,
    );
  }

  /// Stable user id.
  final String id;

  /// Full name.
  final String name;

  /// Work email.
  final String email;

  /// Workspace role.
  final UserRole role;

  /// Brokerage (workspace) name; empty until the admin names it.
  final String brokerageName;

  /// True once the user finished onboarding; they then go straight to Home.
  final bool isOnboardingComplete;

  /// First name, used in greetings; the email when no name is set yet.
  String get firstName => name.isEmpty ? email : name.split(' ').first;
}
