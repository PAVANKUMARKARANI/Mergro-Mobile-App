import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_client.dart';
import 'package:mergro_ai_voice_assistant/core/network/api_exception.dart';
import 'package:mergro_ai_voice_assistant/core/storage/token_storage.dart';
import 'package:mergro_ai_voice_assistant/features/auth/models/app_user.dart';
import 'package:mergro_ai_voice_assistant/features/auth/repositories/auth_repository.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/agent_setup_drafts.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_flow_models.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/models/onboarding_progress.dart';
import 'package:mergro_ai_voice_assistant/features/onboarding/repositories/onboarding_repository.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

/// Display names of the test users per role.
const Map<UserRole, String> testNamesByRole = {
  UserRole.brokerageAdmin: 'Priya Sharma',
  UserRole.salesAgent: 'Arjun Mehta',
  UserRole.teamLead: 'Neha Kapoor',
  UserRole.operations: 'Ravi Iyer',
  UserRole.complianceReviewer: 'Sara Thomas',
};

/// A signed-in test user of [role].
AppUser testUser(
  UserRole role, [
  String email = 'test@skyline.in',
  bool isOnboardingComplete = false,
]) => AppUser(
  id: 'user-${role.name}',
  name: testNamesByRole[role] ?? role.label,
  email: email,
  role: role,
  brokerageName: 'Skyline Realty',
  isOnboardingComplete: isOnboardingComplete,
);

/// Simulated server latency of the fakes.
const Duration fakeLatency = Duration(milliseconds: 10);

/// In-memory [TokenStorage].
class InMemoryTokenStorage implements TokenStorage {
  /// Current token.
  String? token;

  /// Whether the last save asked to persist.
  bool? lastPersist;

  @override
  Future<String?> readAccessToken() async => token;

  @override
  Future<void> saveAccessToken(String token, {required bool persist}) async {
    this.token = token;
    lastPersist = persist;
  }

  @override
  Future<void> clear() async => token = null;
}

/// Scriptable [AuthRepository]. The password "wrong" fails like the server.
class FakeAuthRepository implements AuthRepository {
  /// Role of users returned by [signIn].
  UserRole role = UserRole.brokerageAdmin;

  /// Thrown by [signIn] when set.
  ApiException? signInError;

  /// Arguments of the last [signIn].
  ({String email, String password, bool rememberMe})? lastSignIn;

  /// Returned by [restoreSession]; [restoreError] is thrown instead if set.
  AppUser? restoredUser;

  /// Thrown by [restoreSession] when set.
  Object? restoreError;

  /// Returned by [fetchCurrentUser].
  AppUser? currentUser;

  /// Thrown by [requestPasswordReset] when set.
  ApiException? resetError;

  /// Emails passed to [requestPasswordReset].
  final List<String> resetEmails = [];

  /// Number of [signOut] calls.
  int signOutCount = 0;

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    lastSignIn = (email: email, password: password, rememberMe: rememberMe);
    await Future<void>.delayed(fakeLatency);
    if (signInError case final error?) throw error;
    if (password == 'wrong') {
      throw ApiException(ApiErrorKind.validation, message: 'Invalid password.');
    }
    return testUser(role, email);
  }

  @override
  Future<AppUser> fetchCurrentUser() async =>
      currentUser ?? (throw ApiException(ApiErrorKind.unauthorized));

  @override
  Future<AppUser?> restoreSession() async {
    await Future<void>.delayed(fakeLatency);
    if (restoreError case final error?) throw error;
    return restoredUser;
  }

  @override
  Future<void> signOut() async => signOutCount++;

  @override
  Future<void> requestPasswordReset(String email) async {
    resetEmails.add(email);
    await Future<void>.delayed(fakeLatency);
    if (resetError case final error?) throw error;
  }
}

/// Scriptable [OnboardingRepository] that records what was saved.
class FakeOnboardingRepository implements OnboardingRepository {
  /// Returned by [fetchProgress].
  OnboardingProgress progress = const OnboardingProgress();

  /// Thrown by every call when set.
  ApiException? error;

  /// Saved step data, in save order.
  final Map<OnboardingStepId, JsonMap> saved = {};

  /// Skipped steps, in order.
  final List<OnboardingStepId> skipped = [];

  /// Number of [complete] calls.
  int completeCount = 0;

  /// Emails [sendInvites] reports as failed, with reasons.
  Map<String, String> inviteFailures = {};

  /// Invites passed to [sendInvites].
  final List<TeamInvite> sentInvites = [];

  /// Waits like a server, then throws [error] if set.
  Future<void> _respond() async {
    await Future<void>.delayed(fakeLatency);
    if (error case final failure?) throw failure;
  }

  @override
  Future<OnboardingProgress> fetchProgress() async {
    await _respond();
    return progress;
  }

  @override
  Future<void> saveStep(OnboardingStepId step, JsonMap data) async {
    await _respond();
    saved[step] = data;
  }

  @override
  Future<void> skipStep(OnboardingStepId step) async {
    await _respond();
    skipped.add(step);
  }

  @override
  Future<void> complete() async {
    await _respond();
    completeCount++;
  }

  @override
  Future<InviteResult> sendInvites(List<TeamInvite> invites) async {
    await _respond();
    sentInvites.addAll(invites);
    return InviteResult(
      sentEmails: {
        for (final invite in invites)
          if (!inviteFailures.containsKey(invite.email)) invite.email,
      },
      failures: {
        for (final invite in invites)
          invite.email: ?inviteFailures[invite.email],
      },
    );
  }
}

/// Overrides that keep tests off the network and secure storage.
List<Override> fakeOverrides({
  FakeAuthRepository? auth,
  FakeOnboardingRepository? onboarding,
}) => [
  tokenStorageProvider.overrideWithValue(InMemoryTokenStorage()),
  authRepositoryProvider.overrideWithValue(auth ?? FakeAuthRepository()),
  onboardingRepositoryProvider.overrideWithValue(
    onboarding ?? FakeOnboardingRepository(),
  ),
];

/// A test container using [fakeOverrides].
ProviderContainer fakeContainer({
  FakeAuthRepository? auth,
  FakeOnboardingRepository? onboarding,
}) => ProviderContainer.test(
  overrides: fakeOverrides(auth: auth, onboarding: onboarding),
);
