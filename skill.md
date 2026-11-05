# Mergro — Implementation Log (skill.md)

The living record of what has been built. Update it with every implementation, following
[standards.md](standards.md) Part C. Backend integration starts from the **Providers** and
**TODO(backend)** tables below.

## Scope
Mergro is an AI voice agent for real-estate brokerages. The UI phase built the UI and Riverpod
state for the first three screens. Since 2026-11-05, auth and onboarding talk to the real backend
(`~/Projects/Mergro/server`, see the log entry of that date). The screens:
1. Animated Splash
2. Login (email/password, Google/Microsoft/company SSO, forgot password, request access)
3. Role-based Onboarding and Setup:
   - Admin: 6 steps + Review + Launch
   - Sales agent: 3 steps
   - Team lead: 2 steps

The Home Dashboard is a placeholder in this phase.

## Progress checklist
- [x] Project setup: packages (native splash config comes with the Splash step)
- [x] Theme tokens (colours, typography, spacing, radius) and light/dark `AppTheme`
- [x] Form validators
- [x] Shared widgets: AppButton, AppTextField, MergroLogo, StepProgressHeader, SelectableCard,
      IntegrationCard, StatusChip, InfoBanner, EmailChipInput, SectionHeader, BottomActionBar
- [x] Screen 1: Animated Splash and SplashController (with the native splash)
- [x] Screen 2: Login, ForgotPassword sheet, SSO sheet, Request-access sheet, currentUserProvider
- [x] Screen 3: Onboarding, Admin flow (steps 1–6, Review, success)
- [x] Screen 3: Onboarding, Sales agent flow
- [x] Screen 3: Onboarding, Team lead flow
- [x] Home placeholder with "Sign out" (ends the session and resets onboarding)
- [x] Controller unit tests
- [x] Backend: networking core (`ApiClient`, `ApiException`, secure `TokenStorage`)
- [x] Backend: login, session restore at splash, logout, forgot password (`/api/auth/*`)
- [x] Backend: onboarding save / skip / resume / complete, team invites (`/api/onboarding/*`, `/api/team/*`)
- [ ] Backend: SSO, Zoho, calendars, phone OTP, voice samples (no backend endpoints yet)
- [ ] Final QA: light/dark, 360 px, text scale 1.3 on a device against the live API

## Implementation log
<!-- Newest first. Template:
### YYYY-MM-DD — <title>
**Built:** …
**Files:** added … / changed …
**Decisions / deviations:** …
**Verification:** flutter analyze ✅ · tests ✅ · checked light/dark/360px/1.3x
-->

### 2026-11-05 — Backend integration: auth and onboarding
**Built (app):**
- Networking core: `ApiClient` (dio; adds `Bearer` token, base URL from `--dart-define=API_BASE_URL`,
  default `http://localhost:2282/api`, or `10.0.2.2` on the Android emulator), `ApiResponseMapper`
  (HTTP status, the template's `HTTP 200 + {errorCode: "9001", errorMessage}`, `sessionExpired`,
  express-validator 400s, transport errors → `ApiException` with an `ApiErrorKind` and a user-safe
  message), `SecureTokenStorage` (keychain/keystore; memory only when "Remember me" is off).
- Auth: `AuthApiService` + `AuthRepository`; `AppUser.fromJson` (+ `isOnboardingComplete`).
  Login calls `POST /auth/login` then `GET /auth/me`; wrong email/password show one generic
  message; invited (inactive) accounts get their own message. Splash restores the session
  (no token / expired → Login; onboarding done → Home; else Onboarding; offline → Login, token
  kept). Forgot password calls the API but always shows success unless offline. Home's
  "Restart preview" became "Sign out" (`POST /auth/logout`, token cleared).
- Onboarding: `OnboardingApiService` + `OnboardingRepository`; draft ⇄ JSON in
  `models/draft_json.dart` (enum names, "HH:mm" times). The flow loads saved progress first
  (spinner, error + Retry), restores every saved draft and resumes at the first open step.
  Continue saves the step (`PUT /onboarding/steps/{step}`), Skip records it, Finish/Launch calls
  `POST /onboarding/complete`; failures show a snack bar and stay on the step; an expired session
  returns to Login. Invites call `POST /team/invites`: sent ones leave the list, failed ones stay
  with the server's reason in an error banner.
- Removed the debug "Preview as" role picker and `auth_demo_data.dart` (roles now come from the
  server); test users moved to `test/helpers/fakes.dart`.
- Platform: Android `INTERNET` (main) and cleartext HTTP (debug manifest only); iOS
  `NSAllowsLocalNetworking`; macOS `network.client` entitlement.

**Built (backend, `~/Projects/Mergro/server`, existing Express template):**
- Secrets moved to `server/.env` (git-ignored, `.env.example` documents them): Mongo URL (now the
  `mergro` database), a new random JWT secret, AES key, Twilio/Nexmo credentials, SMS numbers.
  Mongo URL no longer printed in logs. History rewritten before the first push so no commit
  contains them (pushed to `origin/main`, commit `1977eea`).
- New: `GET /api/auth/me`, `GET /api/onboarding`, `PUT /api/onboarding/steps/:stepId`
  (`{data}` or `{skipped:true}`, Joi-validated per step, role-checked), `POST
  /api/onboarding/complete`, `POST /api/team/invites` (admins only; per-email results).
  Models `Brokerage`, `OnboardingProgress`; employee gets status, brokerageId, onboardingCompleted,
  languages, alertPreferences, availability. `npm run seed` creates settings, 5 roles, 2 email
  templates and 3 demo users (`admin@`, `agent@`, `lead@yopmail.com`, password `Emp1234$`).
- Security fixes in the template: `changeRecoverPassword` accepted base64(email) alone (anyone
  could reset any password) → now needs a single-use, expiring token from the emailed link
  (also used by invites, which activate the account); `forgotPassword` crashed on an undefined
  `settings`; login logged plaintext passwords; `apistats` stored request bodies with passwords
  and tokens → redacted; `sessionExpired: true` added to session errors.

**Files (app):** added `core/network/{api_client,api_config,api_exception,api_response_mapper}.dart`,
`core/storage/token_storage.dart`, `features/auth/{services/auth_api_service,repositories/auth_repository}.dart`,
`features/onboarding/{services/onboarding_api_service,repositories/onboarding_repository}.dart`,
`features/onboarding/models/{draft_json,onboarding_progress,onboarding_outcomes}.dart`,
`features/onboarding/controllers/onboarding_step_data.dart`, `features/onboarding/widgets/onboarding_load_view.dart`,
tests listed under Files created. Changed: login/current-user/forgot-password/splash/flow/invite
controllers, `restore()` on every step controller, `app_user.dart`, `login_models.dart`,
`login_screen.dart`, `onboarding_screen.dart`, `invite_team_step.dart`, `agent_setup_drafts.dart`,
`home_placeholder_screen.dart`, `app_routes.dart`, `time_of_day_format.dart`, `pubspec.yaml`,
platform manifests. Deleted `auth/auth_demo_data.dart`, `auth/widgets/preview_role_selector.dart`.

**Decisions / deviations:**
- Packages `dio` 5.11 and `flutter_secure_storage` 11.2 approved by the user (standards B1 updated).
- SSO buttons now say "coming soon" instead of signing in a fake user: a fake session would fail
  on the first real API call.
- The backend keeps the template's error convention (HTTP 200 + `errorCode`), handled in the app.
- Zoho/calendar connection state isn't stored server-side (still simulated); on resume a saved
  CRM step is restored as connected and a saved existing phone number as verified.
- Email delivery is off (`settings.enableMails: false`) until SendGrid keys and a web page for
  `/changeRecoverPassword/:enEmail?token=` (`WEB_APP_URL`) exist; links are recorded in
  `emailstatuses` meanwhile.

**Verification:** `dart format .` ✅ · `flutter analyze` 0 issues ✅ · `flutter test` 81/81 ✅
(30 new) · `flutter build apk --debug` ✅. Backend: 39/39 scripted end-to-end API checks against
the `mergro` DB ✅, valid/reused invite token ✅, apistats redaction ✅, seed re-run is a no-op ✅.
The app's real repositories and draft JSON ran against the live API (admin + agent flows,
temporary test, deleted afterwards) ✅; demo data reset afterwards. **Not verified:** running the
app on a device/simulator against the API, iOS/macOS builds (secure storage on macOS may need a
keychain entitlement), real email delivery, light/dark/1.3× visual check of the new
loading/error/invite-banner states beyond the widget tests.

### 2026-11-05 — .gitignore for app and backend repos
**Built:** Root `.gitignore` for this Flutter app (build/, .dart_tool/, IDE files, `.env*`,
signing keys, `key.properties`, Firebase config files, symbol maps). Separate `.gitignore` at the
root of the backend repo (`~/Projects/Mergro`): node_modules, `.env`/`*.env`, logs/, coverage,
mochawesome output, runtime uploads except the tracked `sample_*_bulk_upload_file.csv` files.
**Files:** added `.gitignore` (and `../Mergro/.gitignore`, outside this repo).
**Decisions / deviations:** Platform-level `.gitignore` files (android/ios/macos/linux/windows)
left as Flutter generated them. Backend `server/.env` and `server/sendgrid.env` are still tracked
in git; the ignore rules don't untrack them (needs `git rm --cached` plus rotating the keys).
**Verification:** `git status --ignored` in both repos: build/ and generated files ignored, all
source still listed. No Dart code changed, so analyze/test not re-run.

### 2026-11-04 — Audible voice previews (device text-to-speech)
**Built:**
- The voice play buttons on the AI agent step now speak the live greeting ("Hi, this is
  Maya…") using the phone's text-to-speech.
- Each voice has its own pitch and speed. The accent follows the step-1 country (en-IN or en-US).
- The waveform animates for as long as speech plays. Tapping the playing voice stops it, and
  tapping another voice switches to it.
- Speech stops when you leave the step. If speech is unavailable, a snackbar says so.
**Files:** added
- `lib/features/onboarding/services/voice_preview_service.dart` (`VoicePreviewService` interface
  plus `DeviceTtsVoicePreviewService`)
- `lib/features/onboarding/controllers/voice_preview_controller.dart`
- `lib/core/utils/app_logger.dart`
- `test/features/onboarding/voice_preview_controller_test.dart`

Changed:
- `voice_preview_button.dart`: now driven by state; the 3 s timer is gone.
- `ai_agent_step.dart`.
- `onboarding_options.dart`: `AgentVoice.pitch/speechRate`, `Country.speechLocale`.
- `app_durations.dart`: `voiceWaveCycle` replaces `voicePreview`.
- `pubspec.yaml` (`flutter_tts` 4.2.5) and `standards.md` B1.
**Decisions / deviations:**
- **New package:** the user approved `flutter_tts` (choosing "device text-to-speech now"), so
  the spec's package list and "no real audio" rule are relaxed for this feature.
- **iOS:** uses the `playback` audio category, so previews are audible with the Silent switch on.
- **Swift Package Manager:** `flutter_tts` doesn't support it yet, so iOS now uses **CocoaPods**
  for this plugin. `flutter run` / `flutter build` generate `ios/Podfile` and run `pod install`
  automatically. Flutter warns this "will become an error in a future version".
- **Adding a native plugin needs a full restart** (stop, then `flutter run`). Hot reload shows
  "Voice preview isn't available on this device" until then.
- **Architecture:** UI → `VoicePreviewController` → `VoicePreviewService` (standards A4). Errors
  are caught in the service and logged through `AppLogger` (A10, A14).
- **Riverpod 3 rule:** `ref` and `state` can't be used inside `onDispose`, so the service is
  captured in `build()`.
- **Later:** device voices only approximate the AI voices. Swap the service for real samples
  (see `TODO(backend)`).
**Verification:** flutter analyze ✅ · flutter test ✅ (38 passing) · `flutter build ios
--simulator` ✅ (with CocoaPods). Audio wasn't verified by ear here.

### 2026-11-04 — Fix: status-bar icons invisible after Login
**Built:** an app-wide default status-bar style in `MergroApp.builder`: dark icons on the light
theme, light icons on the dark theme.
**Files:** changed `lib/app/mergro_app.dart`.
**Decisions / deviations:**
- **Cause:** Splash and Login set light (white) icons for their navy headers. Nothing reset them,
  so Onboarding and Home showed white icons on a light background.
- **Fix:** a root `AnnotatedRegion` now sets the default. Screens that set their own region
  still override it.
- **Voice preview:** it is silent by design (the spec says no real audio). It still only
  animates the waveform; see `TODO(backend)` in `voice_preview_button.dart`.
**Verification:** flutter analyze ✅ · flutter test ✅ (35 passing).

### 2026-11-04 — Screen 3 Onboarding (admin, sales agent, team lead)
**Built:**
- **Flow:** `OnboardingFlowController` builds the role's ordered step list and provides
  `next()` / `back()` / `skip()` / `finish()`.
  - Admin: 6 steps, then Review → "Launch Mergro".
  - Sales agent: 3 steps.
  - Team lead: 2 steps.
- **Steps:** one draft model and one controller per step. A `stepValidProvider(step)` family
  enables Continue. Connect and verify actions simulate 1 s and carry `TODO(backend)` markers.
- **Admin steps:**
  1. Brokerage profile: name, placeholder logo tile, country → time zone, address, business hours.
  2. CRM & lead sources: Zoho connect (Not connected → Connecting… → Connected), Salesforce and
     HubSpot "Coming soon", lead-source toggles that depend on the country, webhook URL in
     JetBrains Mono with Copy (snackbar "Copied").
  3. Calendar (optional): Google and Outlook cards, viewing length 30/45/60, buffer 0/15/30,
     weekday chips, viewing hours.
  4. Phone line: Twilio or Exotel; a new number (3 samples) or an existing number with Verify →
     6-digit code sheet (any code accepted); calling window 09–21 (India) / 08–21 (US) with a
     TRAI DND or TCPA banner; required consent checkbox.
  5. AI voice agent: name (default Maya), 3 voices with a 3 s waveform preview, language chips,
     a greeting preview that updates live, and a locked "Tell leads they're speaking with an AI".
  6. Invite team (optional): email input, invite list with a role picker and remove button.
     Invites are sent on Continue.
- **Agent steps:** profile (avatar initials / placeholder photo, name pre-filled from the user,
  mobile, languages), hot-lead alerts (explainer, push / SMS / sound toggles, quiet hours) and
  calendar & availability (optional).
- **Review and success:** the Review checklist shows ✓ done or ○ "Finish later". The success
  screen draws a teal check with splash-style rings, then "Go to dashboard" → Home.
- **Layout:** the progress header has a back arrow; steps slide and fade in 250 ms (instant with
  reduced motion); the system back gesture steps backwards; a left step rail appears at ≥ 900 px.
**Files:** added
- `lib/features/onboarding/onboarding_demo_data.dart`
- `models/{onboarding_options,onboarding_flow_models,setup_drafts,phone_line_draft,agent_setup_drafts,agent_profile_drafts}.dart`
- `controllers/{onboarding_flow,brokerage_profile,crm,calendar,phone_line,ai_agent,invite_team}_controller.dart`,
  `controllers/agent_profile_controllers.dart`, `controllers/onboarding_providers.dart`
- `widgets/{step_content,step_rail,review_view,voice_preview_button,success_check_painter}.dart`
- `widgets/steps/{brokerage_profile,crm_lead_sources,calendar,phone_line,otp_sheet,ai_agent,invite_team,agent_profile,hot_lead_alerts}_step.dart`
  (`otp_sheet.dart` has no `_step` suffix)
- `screens/{onboarding_screen,onboarding_success_screen}.dart`
- Shared: `lib/shared/widgets/{app_dropdown_field,toggle_chip_group,setting_switch_tile,time_range_field}.dart`,
  `lib/core/utils/{time_of_day_format,set_toggle}.dart`
- Tests: `test/features/onboarding/{onboarding_flow_controller,step_controllers,onboarding_screen}_test.dart`

Changed:
- `lib/app/app_routes.dart`: sign-in → onboarding → success → home; reset on restart.
- `lib/shared/ui.dart`, `step_progress_header.dart` (`label` override), `app_spacing.dart`,
  `app_durations.dart`, `test/helpers/test_app.dart` (`container` and `size` options).
**Decisions / deviations:**
- **Draft lifetime:** step providers are **not** auto-disposed, so drafts survive the step widget
  leaving the screen. `resetOnboarding(container)` invalidates the list in
  `onboardingProviders`. It runs on "Go to dashboard" (after the onboarding screen has gone, so
  nothing flickers) and on "Restart preview".
- **Other roles:** Operations and Compliance reviewer get the team-lead steps. The spec didn't
  cover them.
- **Valid-step rules:**
  - Profile: name, country, time zone, and opening before closing.
  - CRM: Zoho connected.
  - Phone: provider, number (picked or verified) and consent.
  - AI: a name and at least one language.
  - Invites: at least one (otherwise use Skip).
  - Agent profile: a name and a valid mobile.
  - Alerts: push or SMS on.
  - Calendars: at least one day, and start before end.
- **Calendars:** the admin and agent calendars share `CalendarController` but have separate
  providers, so each keeps its own draft.
- **Skip on the last agent step** finishes onboarding.
- **Preview-only details:** the logo, photo and voice audio are placeholders (no file picker or
  audio, per the spec). "Finish later" is a label; going back to a skipped step from Review
  isn't wired.
- **Bug fixes found by the tap-through tests:**
  - The phone line step read `ref` after unmount, because its text controller was created
    lazily on first use in `dispose()`. It is now created in `initState`.
  - The rail and greeting header overflowed at 1.3× text. The rail now scrolls and the header
    text is `Flexible`.
**Verification:** flutter analyze ✅ (0 issues) · flutter test ✅ (35 passing, including the full
admin, agent and team-lead tap-throughs at 360 px and 1.3× text in light and dark, the wide
rail, and the success screen) · largest file 195 lines.

### 2026-11-04 — Screen 1 Splash + Screen 2 Login
**Built:**
- **Native splash:** `#0A1532` with the logo tile centred, plus light status-bar icons on iOS.
- **Animated Flutter splash:** a single 2.4 s controller drives the timeline from the spec — logo
  scale and fade, two call rings, "speaking" voice bars, wordmark, tagline and progress line.
  - It leaves the splash only when both the animation and `SplashController` have finished.
  - With reduced motion on, it shows the final frame for 1.5 s.
- **Login:** navy header and overlapping card, email/password with Next/Done keyboard actions,
  Remember me, the error banner (password `wrong`), Google/Microsoft/company-SSO buttons (spinner
  on the active one only), and the debug-only "Preview as" role chips.
- **Sheets:** Forgot password (form → success state), Company SSO and Request access.
- **Home placeholder:** shows the brokerage, "Hi <name> · <role>" and a "Restart preview" button.
- **Navigation:** all of it lives in `AppRoutes` (300 ms fades; sheets opened from callbacks).
**Files:** added
- `lib/features/splash/{models/splash_destination,controllers/splash_controller,widgets/splash_timeline,widgets/splash_view,screens/splash_screen}.dart`
- `lib/shared/widgets/call_rings_painter.dart`
- `lib/features/auth/{auth_demo_data,models/app_user,models/login_models}.dart`
- `lib/features/auth/controllers/{current_user,login,forgot_password}_controller.dart`
- `lib/features/auth/widgets/{login_header,login_form,sso_buttons,provider_mark,preview_role_selector,login_footer,forgot_password_sheet,company_sso_sheet,request_access_sheet}.dart`
- `lib/features/auth/screens/login_screen.dart`
- `lib/features/home/screens/home_placeholder_screen.dart`
- `flutter_native_splash.yaml`, `assets/splash/*.png`, `tool/render_splash_logo_test.dart`
- `test/helpers/test_app.dart`, `test/features/splash/splash_screen_test.dart`,
  `test/features/auth/{login_screen,login_controller}_test.dart`

Changed: `lib/app/app_routes.dart`, `analysis_options.yaml` (`todo: ignore`), `ios/Runner/Info.plist`
(`UIStatusBarStyleLightContent`), and the generated native splash files for Android and iOS.

Removed the temporary `lib/features/design_preview/` and its test.
**Decisions / deviations:**
- **Sign-in destination:** sign-in currently goes to the Home placeholder. It will point to
  Onboarding once that flow is built.
- **Splash logo PNGs:** rendered from `MergroLogoPainter` by
  `flutter test tool/render_splash_logo_test.dart`, then `dart run flutter_native_splash:create`.
  Rerun both whenever the logo changes.
- **Provider marks:** the Google and Microsoft marks are placeholders drawn in code. Swap in the
  official SVGs before release.
- **Company SSO:** the work email is validated in `LoginController.signInWithProvider`; the sheet
  shows the `LoginFailed` message.
- **Clearing nullable fields:** state `copyWith` takes `ValueGetter<T?>` for nullable fields, so
  they can be explicitly cleared (`emailError: () => null`).
- **Fixes found on the simulator:**
  - The splash glow showed a square edge. It now fades to transparent teal inside a circle.
  - The Microsoft mark was invisible, because `GridView` added safe-area padding. It is now plain rows.
  - The divider label overflowed at 1.3× text. It is now `Flexible`.
**Verification:** flutter analyze ✅ (0 issues) · flutter test ✅ (18 passing) · checked on the iPhone
17 Pro Max simulator (splash mid-animation and Login) · no overflow at 360 px and 1.3× text in light
and dark (automated) · largest file 188 lines.

### 2026-11-04 — Theme, validators and shared widgets
**Built:**
- The Mergro design system: light/dark Material 3 themes from one `AppPalette` theme extension,
  plus spacing, size and radius tokens and the Sora/Figtree/JetBrains Mono type scale.
- Form validators for email, required fields, phone and OTP.
- All 11 shared widgets.
- `ProviderScope → MergroApp → AppRoutes`.
- A temporary design-preview screen (with a light/dark toggle) as the app's start screen.
**Files:** added
- `lib/core/theme/` (`app_colors`, `app_palette`, `app_typography`, `app_spacing`, `app_radius`, `app_theme`)
- `lib/core/constants/app_durations.dart`
- `lib/core/validation/form_validators.dart`
- `lib/shared/ui.dart` and `lib/shared/widgets/*` (11 widgets)
- `lib/app/mergro_app.dart`, `lib/app/app_routes.dart`
- `lib/features/design_preview/*` (temporary)
- `test/core/validation/form_validators_test.dart`, `test/shared/shared_widgets_layout_test.dart`

Changed: `lib/main.dart`, `pubspec.yaml`. Removed the scaffold `test/widget_test.dart`.
**Decisions / deviations:**
- Packages: `flutter_riverpod` 3.4.3, `google_fonts` 9.0.0, `lucide_icons_flutter` 4.0.2, and
  `flutter_native_splash` 2.4.8 (a dev dependency, because it is only used to generate the native
  splash). Removed `cupertino_icons`.
- **Contrast:** light teal `#0E9482` is only 3.77:1 on white, so it is used for fills, focus and
  icons only. Teal text and links use `accentText` `#0B7A6B` (5.24:1). Text on teal fills uses
  `#0A1532` (4.78:1).
- `AppSizes` (in `app_spacing.dart`) holds the fixed sizes and breakpoints, so no sizes are
  hard-coded outside `core/theme`. Durations are in `core/constants/app_durations.dart`.
- Field labels sit above the input rather than floating inside it, which stays readable at 1.3× text.
- Material text-theme mapping: display 28 → `displaySmall`, 24 → `headlineSmall`,
  title 22 → `titleLarge`, heading 18 → `titleMedium`, body 15 → `bodyLarge`/`bodyMedium`,
  label 13 → `labelMedium`/`bodySmall`, caption 12 → `labelSmall`.
- `AppTypography.useGoogleFonts` is turned off in widget tests, which have no network to fetch fonts.
- The design preview is temporary. It is removed when Splash becomes the start screen.
- Reference: `/Users/pavankumarkarani/Projects/mobile designs/mergro-screen-flow/mergro-screen-flow.png`
  is a flow diagram (no mockups). Screens 1–3: Splash (brokerage branding), Login/SSO (role-based
  access), Onboarding (admin: CRM, calendar, phone line; agent: alerts and calendar).
**Verification:** flutter analyze ✅ (0 issues) · flutter test ✅ (7 passing) · no overflow at
360 px, 1.3× text, in light and dark (automated) · largest file 190 lines.

### 2026-11-04 — Project standards and implementation log
**Built:** Added the coding standards and this implementation log.
**Files:** added `standards.md`, `skill.md`, `CLAUDE.md`.
**Decisions / deviations:**
- The team standard allows files of up to 300 lines. Mergro applies a stricter hard limit of 250 lines.
- The team standard's `services/` and `repositories/` layers are deferred to backend integration.
  The UI phase uses `Future.delayed` and `// TODO(backend)` markers instead.

## Providers
| Provider | Type | Scope | State fields |
|----------|------|-------|--------------|
| `splashControllerProvider` | `AsyncNotifierProvider.autoDispose<SplashController, SplashDestination>` | Splash screen | `AsyncValue<SplashDestination>` (login / onboarding / home) |
| `currentUserProvider` | `NotifierProvider<CurrentUserController, AppUser?>` | App-wide | `AppUser?` (id, name, email, role, brokerageName, isOnboardingComplete); `setUser()`, `refresh()` (`GET /auth/me`), `signOut()` (`POST /auth/logout` + clear token) |
| `loginControllerProvider` | `NotifierProvider.autoDispose<LoginController, LoginState>` | Login screen + SSO sheet | email, password, rememberMe, isSubmitting, activeSsoProvider, emailError, passwordError, bannerMessage; `signIn()` (real API) / `signInWithProvider()` ("coming soon") → `LoginOutcome` |
| `onboardingFlowControllerProvider` | `NotifierProvider<OnboardingFlowController, OnboardingFlowState>` | Onboarding (kept alive, reset explicitly) | role, steps, currentIndex (== steps.length on Review), completedSteps, skippedSteps, isFinishing, isSaving, isLoading (true until loaded), loadError; `loadProgress()`, `next()`, `skip()` → `StepActionOutcome`; `back()`; `finish()` → `OnboardingFinishOutcome` |
| `brokerageProfileControllerProvider` | `NotifierProvider<…, BrokerageProfileDraft>` | Admin step 1 | brokerageName, hasLogo, country, timeZone, officeAddress, opensAt, closesAt |
| `crmControllerProvider` | `NotifierProvider<CrmController, CrmDraft>` | Admin step 2 | zohoStatus, enabledLeadSources; `connectZoho()` |
| `viewingCalendarControllerProvider` / `agentCalendarControllerProvider` | `NotifierProvider<CalendarController, CalendarDraft>` | Admin step 3 / agent step 3 | statuses per provider, viewingMinutes, bufferMinutes, days, startTime, endTime; `connect()` |
| `phoneLineControllerProvider` | `NotifierProvider<…, PhoneLineDraft>` | Admin step 4 | provider, numberSource, selectedNumber, existingNumber, existingNumberError, isSendingCode, isVerifying, isVerified, consentConfirmed; `sendVerificationCode()`, `verifyCode()` |
| `aiAgentControllerProvider` | `NotifierProvider<…, AiAgentDraft>` | Admin step 5 | agentName, voice, languages (disclosesAi always true) |
| `inviteTeamControllerProvider` | `NotifierProvider<…, InviteTeamDraft>` | Admin step 6 | invites [{email, role}] (unsent), isSending, sentCount, errorMessage; `addInvite()`, `sendInvites()` → `StepActionOutcome` |
| `agentProfileControllerProvider` | `NotifierProvider<…, AgentProfileDraft>` | Agent / team-lead step 1 | fullName, mobileNumber, hasPhoto, languages |
| `hotLeadAlertsControllerProvider` | `NotifierProvider<…, HotLeadAlertsDraft>` | Agent / team-lead step 2 | pushEnabled, smsFallbackEnabled, soundEnabled, quietStart, quietEnd |
| `voicePreviewControllerProvider` | `NotifierProvider.autoDispose<VoicePreviewController, AgentVoice?>` | AI agent step | Voice currently speaking (null = silent); `togglePreview()` → `bool`, `stop()` |
| `voicePreviewServiceProvider` | `Provider<VoicePreviewService>` | App-wide | Device text-to-speech implementation; overridden with a fake in tests |
| `tokenStorageProvider` | `Provider<TokenStorage>` | App-wide | `SecureTokenStorage`; in-memory fake in tests |
| `apiClientProvider` | `Provider<ApiClient>` | App-wide | dio client with bearer token and error mapping |
| `authApiServiceProvider` / `authRepositoryProvider` | `Provider<AuthApiService>` / `Provider<AuthRepository>` | App-wide | `/api/auth/*`; repository overridden with `FakeAuthRepository` in tests |
| `onboardingApiServiceProvider` / `onboardingRepositoryProvider` | `Provider<OnboardingApiService>` / `Provider<OnboardingRepository>` | App-wide | `/api/onboarding/*`, `/api/team/invites`; repository overridden with `FakeOnboardingRepository` in tests |
| `stepValidProvider(step)` | `Provider.family<bool, OnboardingStepId>` | Onboarding | Whether Continue is enabled for that step |
| `forgotPasswordControllerProvider` | `NotifierProvider.autoDispose<ForgotPasswordController, ForgotPasswordState>` | Forgot-password sheet | email, emailError, isSending, isSent; `sendResetLink()` → `bool` (real API) |

## TODO(backend)
Integrated on 2026-11-05 (no longer placeholders): session restore, login, logout, `GET /auth/me`,
forgot password, onboarding save/skip/resume/complete, team invites. Still simulated:

| File | Placeholder | Real API call needed |
|------|-------------|----------------------|
| `auth/controllers/login_controller.dart` | `signInWithProvider()` returns "coming soon" | Google/Microsoft: native OAuth, then `POST /auth/oauth/{provider} {idToken}`. Company SSO: `GET /auth/sso/discover?email=`, then the SAML/OIDC web flow. The template has `POST /api/auth/socialLogin` (Google id-token) to build on |
| `onboarding/controllers/crm_controller.dart` | `connectZoho()` / `disconnectZoho()` | `GET /integrations/zoho/authorize-url` → browser → `POST /integrations/zoho/callback {code}`; `DELETE /integrations/zoho`. Then store the status server-side (today a saved CRM step is restored as connected) |
| `onboarding/controllers/calendar_controller.dart` | `connect()` / `disconnect()` | Google / Outlook calendar OAuth: `GET …/authorize-url`, then `POST …/callback {code}`; `DELETE /integrations/{provider}-calendar` |
| `onboarding/controllers/phone_line_controller.dart` | `sendVerificationCode()` | `POST /phone-numbers/verify {number, provider}` (sends an OTP) |
| `onboarding/controllers/phone_line_controller.dart` | `verifyCode()` | `POST /phone-numbers/verify/confirm {number, code}` |
| `onboarding/services/voice_preview_service.dart` | `voicePreviewServiceProvider` (device TTS) | `GET /voices/{id}/sample` (real AI voice audio). Implement `VoicePreviewService` with an audio player and swap the provider |
| `auth/widgets/request_access_sheet.dart` | Info sheet only | An access-request endpoint (none in the backend yet) |
| Brokerage logo / agent photo (`hasLogo`, `hasPhoto`) | Not uploaded | Upload endpoint (the template has `/api/uploads`) |

## Files created
- Docs: `standards.md`, `skill.md`, `CLAUDE.md`
- Core: `lib/core/theme/{app_colors,app_palette,app_typography,app_spacing,app_radius,app_theme}.dart`,
  `lib/core/constants/app_durations.dart`, `lib/core/validation/form_validators.dart`
- Shared: `lib/shared/ui.dart`, `lib/shared/widgets/{app_button,app_text_field,mergro_logo,
  step_progress_header,selectable_card,integration_card,status_chip,info_banner,email_chip_input,
  section_header,bottom_action_bar}.dart`
- App: `lib/main.dart`, `lib/app/{mergro_app,app_routes}.dart`
- Splash: `lib/features/splash/**`, `lib/shared/widgets/call_rings_painter.dart`,
  `flutter_native_splash.yaml`, `assets/splash/*.png`, `tool/render_splash_logo_test.dart`
- Auth: `lib/features/auth/**` (models, 3 controllers, 8 widgets, login screen, `services/auth_api_service.dart`,
  `repositories/auth_repository.dart`)
- Network: `lib/core/network/{api_client,api_config,api_exception,api_response_mapper}.dart`,
  `lib/core/storage/token_storage.dart`
- Onboarding: `lib/features/onboarding/**` (demo data, 9 model files incl. `draft_json`,
  `onboarding_progress`, `onboarding_outcomes`; 10 controller files incl. `onboarding_step_data`;
  16 widget files incl. `onboarding_load_view`; `services/onboarding_api_service.dart`,
  `repositories/onboarding_repository.dart`; 2 screens) and the shared `app_dropdown_field`, `toggle_chip_group`,
  `setting_switch_tile`, `time_range_field`, `core/utils/{time_of_day_format,set_toggle}.dart`
- Home: `lib/features/home/screens/home_placeholder_screen.dart`
- Tests: `test/core/validation/form_validators_test.dart`, `test/helpers/test_app.dart`,
  `test/features/splash/splash_screen_test.dart`, `test/features/auth/{login_screen,login_controller}_test.dart`,
  `test/features/onboarding/{onboarding_flow_controller,step_controllers,onboarding_screen,
  onboarding_screen_server,draft_json}_test.dart`, `test/features/auth/{auth_repository,
  splash_and_user}_test.dart`, `test/core/network/api_client_test.dart`,
  `test/helpers/{fakes,onboarding_screen_utils}.dart`

## Agent handoff

Before switching agents, inspect Git status and the current diff. Update this log with completed
work, partial progress, files modified, checks actually run, and remaining work. On starting, the
next agent reads `AGENTS.md`, `skill.md`, `standards.md` and `CLAUDE.md`, inspects the actual source,
and reconciles any differences. Do not assume the other agent's chat history is available. Only
one agent may edit this working tree at a time.

**Running against the backend:** in `~/Projects/Mergro/server`: `npm install`, fill `server/.env`
(see `.env.example`), `npm run seed` once, then `node server-start.js` (port 2282). Run the app with
`flutter run` (emulator uses `10.0.2.2` automatically) or
`--dart-define=API_BASE_URL=http://<host>:2282/api` on a physical device. Demo users:
`admin@yopmail.com`, `agent@yopmail.com`, `lead@yopmail.com`, password `Emp1234$` (yopmail
inboxes are public, so reset/invite emails to them can be read by anyone: demo use only).

**State at handoff (2026-11-05):** the app and backend changes for this integration are **not
committed** in either repo (the backend's secrets cleanup is committed and pushed).

**Next recommended task:** run the app on an Android emulator and an iOS simulator against the
local API and walk through admin, agent and team-lead onboarding (including Retry with the server
stopped and sign-out); check light/dark, 360 px and 1.3× on the new loading/error/invite states;
then build a page (web or in-app) for `/changeRecoverPassword/:enEmail?token=` so reset and invite
emails can be completed, and enable SendGrid in the `settings` document.
