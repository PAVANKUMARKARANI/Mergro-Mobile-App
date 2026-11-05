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
  });

  /// Stable user id.
  final String id;

  /// Full name.
  final String name;

  /// Work email.
  final String email;

  /// Workspace role.
  final UserRole role;

  /// Brokerage (workspace) name.
  final String brokerageName;

  /// First name, used in greetings.
  String get firstName => name.split(' ').first;
}
