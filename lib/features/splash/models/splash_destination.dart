/// Where the app goes once the splash finishes.
enum SplashDestination {
  /// No session: show Login.
  login,

  /// Signed in but onboarding not finished.
  onboarding,

  /// Signed in and onboarded.
  home,
}
