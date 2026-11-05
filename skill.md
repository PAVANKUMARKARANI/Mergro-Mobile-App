# Mergro — Implementation Log (skill.md)

The living record of what has been built. Update it with every implementation, following
[standards.md](standards.md) Part C. Backend integration starts from the **Providers** and
**TODO(backend)** tables below.

## Scope (UI phase)
Mergro is an AI voice agent for real-estate brokerages. This phase builds the UI and Riverpod state
for the first three screens, with no backend:
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
- [x] Home placeholder with "Restart preview" (clears the user and resets onboarding)
- [x] Controller unit tests
- [ ] Final QA: analyze, file length, light/dark, 360 px, text scale 1.3

## Implementation log
<!-- Newest first. Template:
### YYYY-MM-DD — <title>
**Built:** …
**Files:** added … / changed …
**Decisions / deviations:** …
**Verification:** flutter analyze ✅ · tests ✅ · checked light/dark/360px/1.3x
-->

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
| `currentUserProvider` | `NotifierProvider<CurrentUserController, AppUser?>` | App-wide | `AppUser?` (id, name, email, role, brokerageName); `setUser()`, `clear()` |
| `loginControllerProvider` | `NotifierProvider.autoDispose<LoginController, LoginState>` | Login screen + SSO sheet | email, password, rememberMe, isSubmitting, activeSsoProvider, emailError, passwordError, bannerMessage, previewRole; `signIn()` / `signInWithProvider()` → `LoginOutcome` |
| `onboardingFlowControllerProvider` | `NotifierProvider<OnboardingFlowController, OnboardingFlowState>` | Onboarding (kept alive, reset explicitly) | role, steps, currentIndex (== steps.length on Review), completedSteps, skippedSteps, isFinishing; `next()`, `back()`, `skip()`, `finish()` → `OnboardingFinishOutcome` |
| `brokerageProfileControllerProvider` | `NotifierProvider<…, BrokerageProfileDraft>` | Admin step 1 | brokerageName, hasLogo, country, timeZone, officeAddress, opensAt, closesAt |
| `crmControllerProvider` | `NotifierProvider<CrmController, CrmDraft>` | Admin step 2 | zohoStatus, enabledLeadSources; `connectZoho()` |
| `viewingCalendarControllerProvider` / `agentCalendarControllerProvider` | `NotifierProvider<CalendarController, CalendarDraft>` | Admin step 3 / agent step 3 | statuses per provider, viewingMinutes, bufferMinutes, days, startTime, endTime; `connect()` |
| `phoneLineControllerProvider` | `NotifierProvider<…, PhoneLineDraft>` | Admin step 4 | provider, numberSource, selectedNumber, existingNumber, existingNumberError, isSendingCode, isVerifying, isVerified, consentConfirmed; `sendVerificationCode()`, `verifyCode()` |
| `aiAgentControllerProvider` | `NotifierProvider<…, AiAgentDraft>` | Admin step 5 | agentName, voice, languages (disclosesAi always true) |
| `inviteTeamControllerProvider` | `NotifierProvider<…, InviteTeamDraft>` | Admin step 6 | invites [{email, role}], isSending, sentCount; `addInvite()`, `sendInvites()` |
| `agentProfileControllerProvider` | `NotifierProvider<…, AgentProfileDraft>` | Agent / team-lead step 1 | fullName, mobileNumber, hasPhoto, languages |
| `hotLeadAlertsControllerProvider` | `NotifierProvider<…, HotLeadAlertsDraft>` | Agent / team-lead step 2 | pushEnabled, smsFallbackEnabled, soundEnabled, quietStart, quietEnd |
| `voicePreviewControllerProvider` | `NotifierProvider.autoDispose<VoicePreviewController, AgentVoice?>` | AI agent step | Voice currently speaking (null = silent); `togglePreview()` → `bool`, `stop()` |
| `voicePreviewServiceProvider` | `Provider<VoicePreviewService>` | App-wide | Device text-to-speech implementation; overridden with a fake in tests |
| `stepValidProvider(step)` | `Provider.family<bool, OnboardingStepId>` | Onboarding | Whether Continue is enabled for that step |
| `forgotPasswordControllerProvider` | `NotifierProvider.autoDispose<ForgotPasswordController, ForgotPasswordState>` | Forgot-password sheet | email, emailError, isSending, isSent; `sendResetLink()` → `bool` |

## TODO(backend)
| File | Placeholder | Real API call needed |
|------|-------------|----------------------|
| `splash/controllers/splash_controller.dart` | `build()` returns login | Restore the session: read the stored refresh token → `GET /me` → login / onboarding / home |
| `auth/controllers/current_user_controller.dart` | `setUser()` | Persist tokens and load the real user (`GET /me`) |
| `auth/controllers/current_user_controller.dart` | `clear()` | `POST /auth/logout`, then clear stored tokens |
| `auth/controllers/login_controller.dart` | `signIn()` | `POST /auth/login {email, password, rememberMe}` → tokens + user; map 401 to "Email or password is incorrect." |
| `auth/controllers/login_controller.dart` | `signInWithProvider()` | Google/Microsoft: native OAuth, then `POST /auth/oauth/{provider} {idToken}`. Company SSO: `GET /auth/sso/discover?email=`, then the SAML/OIDC web flow |
| `app/app_routes.dart` | `_afterSignIn()` | Skip onboarding when `GET /me` says it is already complete |
| `onboarding/controllers/onboarding_flow_controller.dart` | `next()` | Save step: `PUT /onboarding/steps/{step}` with that step's draft |
| `onboarding/controllers/onboarding_flow_controller.dart` | `finish()` | `POST /onboarding/complete` (for admins this also activates the AI agent and lead webhooks) |
| `onboarding/controllers/crm_controller.dart` | `connectZoho()` / `disconnectZoho()` | `GET /integrations/zoho/authorize-url` → browser → `POST /integrations/zoho/callback {code}`; `DELETE /integrations/zoho` |
| `onboarding/controllers/calendar_controller.dart` | `connect()` / `disconnect()` | Google / Outlook calendar OAuth: `GET …/authorize-url`, then `POST …/callback {code}`; `DELETE /integrations/{provider}-calendar` |
| `onboarding/controllers/phone_line_controller.dart` | `sendVerificationCode()` | `POST /phone-numbers/verify {number, provider}` (sends an OTP) |
| `onboarding/controllers/phone_line_controller.dart` | `verifyCode()` | `POST /phone-numbers/verify/confirm {number, code}` |
| `onboarding/controllers/invite_team_controller.dart` | `sendInvites()` | `POST /team/invites [{email, role}]`; surface per-email failures |
| `onboarding/services/voice_preview_service.dart` | `voicePreviewServiceProvider` (device TTS) | `GET /voices/{id}/sample` (real AI voice audio). Implement `VoicePreviewService` with an audio player and swap the provider |
| `auth/controllers/forgot_password_controller.dart` | `sendResetLink()` | `POST /auth/forgot-password {email}`; always show success, so the response never reveals whether an account exists |

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
- Auth: `lib/features/auth/**` (demo data, models, 3 controllers, 9 widgets, login screen)
- Onboarding: `lib/features/onboarding/**` (demo data, 6 model files, 9 controller files, 15 widget
  files, 2 screens) and the shared `app_dropdown_field`, `toggle_chip_group`,
  `setting_switch_tile`, `time_range_field`, `core/utils/{time_of_day_format,set_toggle}.dart`
- Home: `lib/features/home/screens/home_placeholder_screen.dart`
- Tests: `test/core/validation/form_validators_test.dart`, `test/helpers/test_app.dart`,
  `test/features/splash/splash_screen_test.dart`, `test/features/auth/{login_screen,login_controller}_test.dart`,
  `test/features/onboarding/{onboarding_flow_controller,step_controllers,onboarding_screen}_test.dart`

## Agent handoff

Before switching agents, inspect Git status and the current diff. Update this log with completed
work, partial progress, files modified, checks actually run, and remaining work. On starting, the
next agent reads `AGENTS.md`, `skill.md`, `standards.md` and `CLAUDE.md`, inspects the actual source,
and reconciles any differences. Do not assume the other agent's chat history is available. Only
one agent may edit this working tree at a time.

**Next recommended task:** complete the unchecked Final QA item above: run the prescribed format
check, `flutter analyze` and `flutter test`; verify light and dark modes, 360 px layout and 1.3×
text scale; confirm every Dart file is at most 250 lines. Record only checks actually completed.
