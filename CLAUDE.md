# Mergro AI Voice Assistant (Flutter)

- Follow [standards.md](standards.md) for every change. Part B (Mergro rules) overrides Part A.
- Before significant work, read [AGENTS.md](AGENTS.md), [skill.md](skill.md) and [standards.md](standards.md), then inspect the actual source and relevant tests. Treat `skill.md` as implementation history and reconcile it with the code.
- After every implementation, update [skill.md](skill.md): the log entry, the providers table,
  the TODO(backend) table and the checklist (standards.md Part C).
- Preserve unrelated user changes. Respect existing `TODO(backend)` markers and don't describe demo behavior as a real integration. Keep Dart files within Mergro's 250-line limit.
- Record only checks actually run, distinguish verified from unverified behavior, and document unfinished work plus the exact next task if stopping midway. For agent handoffs, inspect Git status and diff, update `skill.md`, and ensure only one agent edits the working tree at a time; don't rely on chat history.
- Before finishing, run `dart format .`, `flutter analyze` (zero issues) and `flutter test`.
- Auth and onboarding use the real API (`~/Projects/Mergro/server`, see standards.md B3). Features
  without a backend yet stay simulated with `Future.delayed` and are marked `// TODO(backend): …`.
- Run against the local backend with `--dart-define=API_BASE_URL=…` (default: `localhost:2282`,
  or `10.0.2.2:2282` on the Android emulator).
