# Mergro — Flutter Development Standards

These rules apply to every change in this repository. Part A is the team-wide Flutter
standard. Part B holds the Mergro-specific rules, which are stricter where the two overlap.
**When A and B differ, B wins.**

After every implementation, update [skill.md](skill.md) (see Part C).

---

## Part A — Team Flutter standards

### A1. Code structure
Use a feature-based structure. Don't put everything into large screens.

```
lib/
├── core/            constants/, network/, utils/, theme/, errors/, validation/
├── features/
│   └── <feature>/   models/, services/, repositories/, controllers/, screens/, widgets/
├── shared/          widgets/, components/
└── main.dart
```

Keep UI, business logic, API/data access and reusable components separate.

### A2. File size
| Lines    | Recommendation                   |
|----------|----------------------------------|
| 0–200    | ✅ Good                           |
| 200–300  | ✅ Acceptable                     |
| 300–500  | ⚠️ Review for splitting          |
| 500–800  | ⚠️ Refactoring normally expected |
| 800+     | ❌ Should generally be split      |

Split by responsibility, not purely by line count. (Mergro hard limit: see B4.)

### A3. Widget size
- A `build()` method should be under 100 lines, and ideally much smaller.
- Break screens into named sections, and move meaningful sections into their own widgets:
  ```
  LoginScreen
   ├── LoginHeader
   ├── LoginForm
   ├── SsoButtons
   └── LoginFooter
  ```

### A4. Business logic stays out of the UI
Flow: `UI → Controller → Service → Repository → API`.
The UI handles presentation and user interaction only. Never put HTTP calls, validation,
calculations or state updates inside `onPressed`.

### A5. API calls
Never call APIs from widgets (for example, no `FutureBuilder(future: http.get(...))`).
Flow: `Screen → Controller → Repository → API Service`.

### A6. Constants
Centralise any value that is reused: API URLs, timeouts, colours, font sizes, spacing,
route names, error messages and configuration. Use `AppSpacing.md`, not `EdgeInsets.all(16)`.

### A7. Naming
- No `d`, `x`, `res` or `temp`. Use names like `claimDetails`, `isLoading` or `selectedEmployee`.
- Classes: `LoginScreen`, `LoginController`, `AuthRepository`, `AuthService`, `AppUser`.
- Methods are verbs: `fetchClaims()`, `validateEmail()`, `sendResetLink()`. Avoid
  `data()`, `process()` and `doSomething()`.

### A8. No duplicate code
If the same logic appears 2–3 times, extract it into a reusable widget, utility, service,
extension or helper (for example `formatDate()` or `showErrorMessage()`).

### A9. State management
Use one agreed approach across the app. **Mergro uses Riverpod (see B2).** Don't mix patterns,
and avoid unnecessary global state.

### A10. Error handling
Every API/integration point handles: success, loading, empty, validation failure,
unauthorized (401), forbidden (403), not found (404), server error (5xx), network failure,
timeout and unexpected exceptions.
Never write `catch (e) { print(e); }`. Log through the central logger and show a user-friendly message.

### A11. Loading and empty states
Every data-driven screen covers `Loading → Success | Empty | Error (with Retry)`.
Never leave the user looking at a blank screen.

### A12. Null safety
Avoid `!` unless the value provably cannot be null. Prefer `user?.name ?? ''`, or validate
before accessing the value.

### A13. Comments
Don't comment obvious code. Inline comments explain **why**, not what.
(Doc comments on public APIs are required; see B5.)

### A14. Logging
- No `print()` or `debugPrint()` in committed code. Use the central logger
  (`core/utils/app_logger.dart`, built on `dart:developer` `log`).
- Never log passwords, tokens, client secrets, personal information or authorization headers.

### A15. Performance
- Avoid rebuilding the whole screen. Watch only the providers you need (`ref.watch(p.select(...))`)
  and keep `setState` local.
- No API calls or expensive calculations inside `build()`.
- Use lazy lists (`ListView.builder`) for long lists.
- Resize and cache images.
- Dispose controllers and cancel streams, subscriptions and timers.

### A16. Lifecycle
Dispose everything created in `initState`: `TextEditingController`, `FocusNode`,
`AnimationController`, `StreamSubscription`, `Timer` and listeners.

```dart
@override
void dispose() {
  _emailController.dispose();
  _animationController.dispose();
  super.dispose();
}
```

### A17. Testing
- Unit tests for business logic (controllers, validators).
- Widget tests for important UI behaviour.
- Integration tests for critical end-to-end flows such as login and onboarding.

### A18. Static analysis
Before every PR, `flutter analyze` must pass with zero issues and `dart format .` must have been run.
Don't mix unrelated formatting changes into a functional PR.

### A19. No warnings
Don't approve a PR that has errors, new warnings, unused imports, unused variables or dead code.

### A20. Git branches
Work on `feature/…`, `fix/…` and `hotfix/…` branches, for example `feature/MERGRO-12-login-screen`.
Never commit directly to `main`.

### A21. Commit messages
Use Conventional Commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`.
Examples: `feat: add login screen`, `test: add onboarding controller tests`.
Never use messages like `changes`, `update`, `final`, `final1`, `testing` or `new changes`.

### A22. PR size
| Changed lines | Recommendation      |
|---------------|---------------------|
| < 300         | ✅ Ideal             |
| 300–500       | ✅ Acceptable        |
| 500–1000      | ⚠️ Review carefully |
| > 1000        | ❌ Prefer splitting  |

Suggested PR split for Mergro: theme and shared widgets → splash → login → onboarding (admin)
→ onboarding (agent and team lead) → tests.

---

## Part B — Mergro project rules (these override Part A)

### B1. Tech
- Flutter (Dart ≥ 3.7), Material 3.
- Allowed packages: `flutter_riverpod` (3.x), `google_fonts`, `lucide_icons_flutter`,
  `flutter_native_splash`, plus `flutter_tts` (approved 2026-11-04 for voice previews), and
  `dio` + `flutter_secure_storage` (approved 2026-11-05 for the backend integration).
  **Nothing else** without approval.
- Animations use `AnimationController`, `Tween` and `CustomPainter` only (no Lottie).
- Navigation is imperative with `Navigator`, and all of it lives in `lib/app/app_routes.dart`.
  Don't add a router package.

### B2. Riverpod rules
- Use `Notifier`/`AsyncNotifier` with `NotifierProvider`/`AsyncNotifierProvider`.
  **No** code generation, `StateProvider` or `ChangeNotifier`.
- Use `.autoDispose` for screen-scoped state.
- State classes are immutable, provide `copyWith` and live in the feature's `models/` folder.
  Loading, validation errors and banner errors are explicit fields
  (`isSubmitting`, `emailError`, `bannerMessage`).
- Screens are `ConsumerWidget`/`ConsumerStatefulWidget`. They `ref.watch` state and call
  controller methods. `TextEditingController`, `FocusNode` and `AnimationController` stay in the
  widget's `State`.
- Controllers **never** navigate or show dialogs or snackbars. Async methods return
  `Future<T>` with a sealed outcome (`LoginOutcome = LoginSucceeded | LoginFailed`), and the
  screen reacts to it.
- Guard against double submits with `isSubmitting`. Check `ref.mounted` after **every** `await`
  before writing state.
- Widgets in `shared/` never read providers. They take values and callbacks.
- Screens take navigation callbacks (`LoginScreen(onSignedIn:, onForgotPassword:)`), and
  `AppRoutes` wires them up.

### B3. Backend boundary
- **Integrated (2026-11-05):** email/password login, session restore, logout, forgot password,
  onboarding steps (save, skip, resume, complete) and team invites call the Mergro API
  (`~/Projects/Mergro/server`). Everything else is still simulated.
- Flow: `Controller → Repository → ApiService → ApiClient` (`core/network/`). Only repositories
  are used by controllers; tests override `authRepositoryProvider` /
  `onboardingRepositoryProvider` with fakes and never hit the network or secure storage.
- Every failure is an `ApiException` with an `ApiErrorKind` (A10) and a user-safe `message`;
  controllers map it into their sealed outcomes. An expired session is `unauthorized` and the
  screen sends the user back to Login.
- Tokens live only in `TokenStorage` (secure storage; memory only when "Remember me" is off).
  Never log them.
- Features without a backend yet (SSO, Zoho, calendars, phone OTP, voice samples, and the shell
  screens 4–11: leads, calls, handoffs, viewings, nurture, dashboard numbers) keep
  `Future.delayed` simulations with `*_demo_data.dart` data or an "unavailable" message, each marked
  `// TODO(backend): <the API call that goes here>`. Never present them as real.
- All dummy text, lists and sample values live in `*_demo_data.dart` files.

### B3a. Loading, empty and error states (A11)
- Lists and data screens use `AsyncValueView`: skeleton placeholders while loading (never a lone
  spinner), `EmptyState` when empty, error banner with Retry on failure.
- Skeletons (`SkeletonPulse`, `SkeletonBox`, `SkeletonRow`, `SkeletonList`) mirror the loaded
  layout so nothing jumps, and stay still with reduced motion.
- Live timers read `clockProvider` (1 s tick); tests pin it through `fakeOverrides()`.

### B4. File and code rules
- **Hard limit: every Dart file is ≤ 250 lines**, split by responsibility.
- No hard-coded colours, sizes or text styles outside `core/theme/`. Use `AppColors`,
  `AppSpacing`, `AppRadius` and `AppTypography`.
- Import UI through the single `lib/shared/ui.dart` barrel.

### B5. Documentation
- Every class, constructor and method has a `///` doc comment, including private helpers
  where their purpose isn't obvious.
- Doc comments say what the member is for and any contract (for example, "returns null when
  valid"). They don't restate the code.

### B6. Design and accessibility
- Use the design tokens from the spec (navy + teal, Sora/Figtree/JetBrains Mono, 4–40 spacing,
  8/12/16/24 radius, 52 px inputs and buttons, 48 px minimum touch target).
- Support light and dark themes — the user picks Light / Dark / System in Profile
  (`themeModeControllerProvider`, default System) — text scale up to 1.3 without overflow, and
  reduced motion (`MediaQuery.disableAnimations`). Colours that work on one surface may vanish on
  another in dark mode (e.g. the warning tone's foreground); check both modes.
- Test at 360–430 px width. At ≥ 600 px, centre Splash and Login in a 440 px column and the app
  shell swaps its bottom bar for a side rail. At ≥ 900 px, Onboarding shows a step rail.
- Bottom bars hold at most 5 tabs (`AppTab.barTabsFor(role)`); other destinations go under More.
- Icon-only buttons have `Semantics`/`tooltip` labels, and text contrast is ≥ 4.5:1.

### B7. Definition of done (per change)
- [ ] `dart format .` has been run, and `flutter analyze` reports zero issues.
- [ ] Every Dart file is ≤ 250 lines, and every class and method is documented.
- [ ] Controller unit tests have been added or updated and `flutter test` passes.
- [ ] Checked in light and dark mode, at 360 px and text scale 1.3.
- [ ] [skill.md](skill.md) has been updated.

---

## Part C — Maintaining skill.md
After **every** implementation (each screen, widget set, fix or refactor), update
[skill.md](skill.md) in the same change:
1. Add a dated entry to the **Implementation log**: what was built, the files added or changed,
   and any decisions or deviations.
2. Keep the **Providers** table current: each provider, its type and its state fields.
3. Keep the **TODO(backend)** table current: each placeholder, its file and the real API call it needs.
4. Tick the item off in the **Progress checklist**.
