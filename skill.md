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

4. App shell with role-based tabs and the main screens: Home dashboard (4), Leads + search (5, 11),
   Live calls (6), Hot lead inbox (7), Viewings (8), Nurture (9), Profile (10) — **UI with demo
   data**; their API calls are listed in the TODO(backend) table. Since 2026-11-05 the Leads list,
   lead profile (13) and the dashboard's lead counts use the real leads API.

Specs: screen flow `~/Projects/mobile designs/mergro-screen-flow/mergro-screen-flow.html` (screen
numbers 1–50); build plan and status: the "Mergro Build Flow" artifact
(https://claude.ai/artifact/VawbTdKRgcpdCLzhs2eyBV, local copy `~/Projects/Mergro/mergro-build-flow.html`).

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
- [x] Onboarding success screen opens the dashboard by itself (animation + 2 s, no button)
- [x] App shell: role-based bottom tabs (side rail ≥ 600 px), "More" for the rest
- [x] Screen 4 Home dashboard · 5 Leads + 11 Search & filters · 6 Live calls · 7 Hot lead inbox ·
      8 Viewings · 9 Nurture · 10 Profile (UI with demo data, `TODO(backend)` marked)
- [x] Dashboard density pass, compact hot-lead rows, tab bar polish
- [x] Light / Dark / System appearance choice (Profile), skeleton loading on every list
- [x] Part A: Lead profile 13 with qualification 16, score 17, activity 19, consent 20, calls,
      call-back / message / do-not-contact (UI with demo data); lead rows open it
- [x] Part B: live call monitor 12, call detail 14, transcript 15, book viewing 18 (UI with demo data)
- [ ] Handoff module 21–26, journeys 27–32, analytics 33–38, admin 39–44, compliance 45–50
- [x] Controller unit tests
- [x] Backend: networking core (`ApiClient`, `ApiException`, secure `TokenStorage`)
- [x] Backend: login, session restore at splash, logout, forgot password (`/api/auth/*`)
- [x] Backend: onboarding save / skip / resume / complete, team invites (`/api/onboarding/*`, `/api/team/*`)
- [x] Backend: leads API (`/api/leads/*`) — Leads list, lead profile + actions, dashboard counts
- [ ] Backend: hot leads, viewings, calls, nurture, analytics (no backend endpoints yet; demo data)
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

### 2026-11-05 — App: Leads, lead profile and dashboard counts on the leads API
**Built (app branch `feature/leads-api-integration`, from `feature/app-shell-dashboard`):**
- `LeadsApiService` → `LeadsRepository` (`leadsRepositoryProvider`) over `/api/leads`, `/summary`,
  `/:id`, `/:id/timeline`, consent, suppress, call-back and messages. `Lead.fromJson` and
  `leadProfileFromJson` parse the server JSON (unknown enum values / events are skipped; missing
  id, name, source, status or date → `ApiErrorKind.unexpected`).
- `LeadsController` loads from the API (first 100, filtering stays on the device; TODO for
  server-side paging/filters). Territory filter options now come from the loaded leads
  (`leadAreasProvider`) instead of the demo list.
- `dashboardSummaryProvider` reads `GET /api/leads/summary` (reloads with the leads list).
  `DashboardSummary.speedToLeadSeconds` is nullable: the speed card shows "—", "No calls yet" and
  "Measured once the AI starts calling new leads" until AI calls exist.
- `LeadProfileController` loads the profile + timeline from the API; every action calls the
  server, then re-fetches the profile (status, consents and timeline come from the server) and
  updates the Leads row. A refused action keeps the profile and shows the server's message.
  Call-back and Message say the request is **recorded** (no dialler / messaging yet). Profile
  `calls` stay empty (no calls API). Booking a viewing still only updates the device copy.
- `BookViewingController` takes the lead from the open profile, not the demo data.
- **Demo-id bridge** (`leads/demo_lead_bridge.dart`, `TODO(backend)`): hot leads, viewings and calls
  are still demo data with ids like `lead-02`; `AppRoutes.openLeadProfile` resolves them to the
  loaded server lead with the same name (the seed uses the same 13 names).
- 403 / 404 responses keep the server's `errorMessage` (e.g. "This lead no longer exists.").
- `noAutomaticRetry` (`core/utils/no_automatic_retry.dart`) replaces two private copies and is now
  also used by the leads list and the summary, so load errors show at once with Retry.
**Tests:** `FakeLeadsRepository` (demo data, server-like actions, `failWith` / `failNextAction`) is in
`fakeOverrides`; `InMemoryTokenStorage` / `InMemoryThemePreferenceStore` moved to
`test/helpers/in_memory_stores.dart` (re-exported by `fakes.dart`). New tests: areas from leads,
demo-id bridge, failed list load, refused profile action, 404 server message.
**Verification:** `dart format .` ✅ · `flutter analyze` 0 issues ✅ · `flutter test` 175/175 ✅. Live
check (temporary test, deleted) against the local server as `admin@yopmail.com`: 13 leads, summary
(7 new / 3 qualified / 57 % / speed null), bridge `lead-02` → Ananya Iyer, profile (5/5 answers,
4 reasons, 4 events, consents), call-back recorded and its event returned on re-fetch, unknown id
→ `notFound`. The 404 server-message fix came after that run and is covered by a unit test only.
Note: the live check added one "AI call-back requested" event to Ananya Iyer in the demo DB.
**Not checked:** running the app on a device / emulator against the API, light/dark / 360 px /
1.3× on the new speed-card states.

### 2026-11-05 — Backend: leads API
**Built in `~/Projects/Mergro/server`, branch `feature/leads-api`:** `Lead` and `LeadEvent` models
(enum names match the app); `POST /api/leads/ingest` webhook (per-brokerage `x-mergro-key`, stored
hashed; explicit call consent required; phone → E.164; repeat enquiries within 30 days merge;
opted-out leads stay suppressed; 120/min per key); eligibility check (suppressed, call consent,
brokerage calling hours in its time zone, next window); `GET /api/leads` (search, filters, paging;
agents see own + unassigned), `/summary`, `/:id`, `/:id/timeline`, consent withdrawal, suppress,
call-back and messages (recorded only until telephony / messaging exist); admin
`/api/brokerage/ingest-key`. `apistats` now also redacts phone, email, name, text and `q`. The seed
adds the 13 demo leads to the demo admin's brokerage ("Do Systems" after onboarding) and prints its
ingestion key once.
**Verification:** 37/37 scripted API checks against the `mergro` DB (webhook auth, validation,
dedupe, consent, filters, agent scope, brokerage isolation, actions, redaction) and 14/14
eligibility / phone rule checks; demo data reset and re-seeded afterwards. The app was connected to
these endpoints in the entry above.

### 2026-11-05 — Part B: live call monitor (12), call detail (14), transcript (15), book viewing (18)
**Built (UI with demo data):**
- Live call monitor (12), from a Live calls tile or a Home "Live now" row: source, area, Live / Ended
  chip, running timer (frozen at the final length once ended), AI reply latency, stage tracker
  (dialing → disclosure → qualifying → booking → wrap-up), "Captured so far" answers filling in,
  live transcript, "Open lead profile". Lines appear as call time passes: `liveCallMonitorProvider`
  replays the demo script (`call_script_demo_data.dart`) against `clockProvider`, so it is live in
  the app and deterministic in tests (no extra timers). Take-over / warm transfer is a note +
  `TODO(backend)` until telephony exists.
- Call detail (14), from the profile's call history (rows now tappable): outcome, date, length,
  score chip, AI summary, next step, qualification, "Read transcript (n lines)" (disabled when
  nobody answered). Transcript (15): chat bubbles (AI left / lead right) with mm:ss stamps;
  phone numbers and emails masked (`core/utils/pii_mask.dart`). No audio playback (needs an
  approved package and recordings).
- Book viewing (18), a fourth profile action: listing cards (3 in the lead's area), day chips
  (today + 6), hourly slots 10 AM–6 PM (taken and past ones struck through), tap to hold for
  5 minutes with a ticking `HoldBanner` (red when expired), Confirm (enabled only with a hold).
  Booking updates the profile (status "Viewing booked", timeline event) and the Viewings list,
  pops back and confirms in a snack bar. An expired hold is refused with a clear message.
- Demo data: lead-13 Deepak Joshi added for the in-progress call; `LiveCall.leadId`; call ids
  are `call-<leadId>-<n>` (`leadIdOfCall`). Call detail and lead profile providers disable
  Riverpod's automatic retry.
**Files:** added `features/calls/{call_script_demo_data.dart, models/call_transcript.dart,
controllers/call_providers.dart, screens/{live_call_monitor,call_detail,transcript}_screen.dart,
widgets/transcript_view.dart}`, `features/viewings/{booking_demo_data.dart, models/booking.dart,
controllers/book_viewing_controller.dart, screens/book_viewing_screen.dart, widgets/slot_picker.dart}`,
`core/utils/pii_mask.dart`; changed live call model / demo / tiles / screen, `dashboard_rows.dart`,
`home_screen.dart`, profile screen / actions bar / call history card / controller
(`recordViewingBooked`), `viewings_controller.dart` (`addViewing`), `leads_demo_data.dart`,
`app_routes.dart`, `app_routes_shell.dart`; tests under `test/features/{calls,viewings}/`.
**Verification:** `dart format .` ✅ · `flutter analyze` 0 issues ✅ · `flutter test` 170/170 ✅
(24 new: PII masking, script invariants, monitor stage / answers from the clock, call detail per
outcome, booking hold / confirm / profile + Viewings updates, hold banner countdown and expiry,
all four screens at 360 px / 1.3× light + dark, Live calls → monitor → profile → book → confirmed).
Rendered the monitor, call detail, transcript (dark) and booking with a hold and reviewed them;
fixed "a Row house" → "a row house" in the script. **Not verified:** on a device.

### 2026-11-05 — Part A: Lead profile (13) with screens 16, 17, 19, 20
**Built (UI with demo data):**
- `features/lead_detail`: tapping a lead (Leads list), a hot lead (Home row, inbox card) or a
  viewing (Home row, Viewings tile) pushes `LeadProfileScreen` (live call rows wait for Part B).
- Header: name, phone, email, score / status / source chips, property and budget, owner, capture
  time; red "Do not contact" banner when suppressed.
- Actions: Call back (AI call-back, needs call consent), Message (sheet: only consented channels,
  3 templates, 500 chars), Do not contact (confirm dialog; withdraws every channel, sets status
  "Do not contact", updates the Leads list via `LeadsController.replaceLead`). Results show in
  snack bars; actions lock while one runs and after suppression.
- Qualification (16): budget, area, timeline, property type, pre-approval with confidence bars;
  "Not answered yet" before the first call. Lead score (17): half gauge (`CustomPainter`) with band,
  base 50 plus reason codes and points that add up to the score. Activity (19): rail timeline,
  newest first. Consent (20): per-channel switch with evidence and date; agents can only record a
  withdrawal (confirm dialog) — granting stays with the lead. Calls: history with outcome chips.
- Demo profiles derive from the lead (`lead_profile_demo_data.dart`, `lead_activity_demo_data.dart`)
  so they match the Leads list. `Handoff` and `Viewing` gained `leadId`; `Lead.copyWith`;
  `AppTextField.maxLines`.
- `leadProfileControllerProvider` (family by lead id) disables Riverpod's automatic retry, so a
  missing lead shows "This lead no longer exists." with Retry at once instead of ~30 s of retries.
**Files:** added `lib/features/lead_detail/**` (2 models, 2 demo data, controller, screen, 8
widgets); changed lead / handoff / viewing models and demo data, `leads_controller.dart`,
`lead_tile.dart`, `hot_lead_row.dart`, `handoff_card.dart`, `viewing_tile.dart`,
`dashboard_rows.dart`, Home / Leads / Hot leads / Viewings screens (`onOpenLead`),
`app_routes.dart`, `app_routes_shell.dart`, `app_text_field.dart`; tests under
`test/features/lead_detail/`.
**Decisions:** sections live on one scrolling profile rather than separate screens (16, 17, 19,
20 are cards); call history rows are not tappable until call detail (14) exists in Part B;
recording playback stays out (needs an approved audio package).
**Verification:** `dart format .` ✅ · `flutter analyze` 0 issues ✅ · `flutter test` 146/146 ✅
(19 new: demo-data invariants incl. score reasons = score, controller actions and guards,
profile at 360 px / 1.3× light + dark for hot / unscored / suppressed leads, do-not-contact flow,
Leads tab → profile → message sheet → sent). Rendered the profile (light, dark, gauge, composer)
and reviewed it; fixed "Captured 3 nov" → "Captured on 3 Nov". **Not verified:** on a device.

### 2026-11-05 — Skeleton loading states
**Built:** the dashboard showed a lone spinner plus bare progress bars while loading. Now: shared
`SkeletonPulse` / `SkeletonBox` / `SkeletonRow` / `SkeletonList` (`shared/widgets/skeleton.dart`, no
package; gentle 0.9 s pulse, still with reduced motion, announced as "Loading"). Home shows
`DashboardSummarySkeleton` (speed card + 4 tiles) and `SectionRowsSkeleton` in each section, shaped
like the loaded layout so nothing jumps. `AsyncValueView` now defaults to `SkeletonList`, so Leads,
Live calls, Hot leads, Viewings and Nurture load the same way (optional `loading:` override). Leads
chips show "Hot / Warm / Cold" without counts until loaded (no fake "(0)").
**Verification:** `dart format .` ✅ · `flutter analyze` 0 issues ✅ · `flutter test` 127/127 ✅
(loading tests now assert skeletons and no spinner). Rendered the loading Home (light + dark) and
Leads at 440 × 956 and reviewed them. **Not verified:** on a device.

### 2026-11-05 — Light / Dark / System appearance choice
**Built:** Profile → Appearance lets the user pick System (default), Light or Dark; the whole app
switches at once (status-bar icons follow). `ThemeModeController` (`core/theme/theme_mode_controller.dart`)
starts on System, restores the saved choice, and saves changes through `ThemePreferenceStore`
(`core/storage/theme_preference_store.dart`, flutter_secure_storage — no new package). It is a device
preference, so sign-out keeps it. Storage failures are logged and never block the choice.
`MergroApp` is now a `ConsumerWidget` reading the mode. Tests use `InMemoryThemePreferenceStore`
(`fakeOverrides(themeStore:)`).
**Verification:** `dart format .` ✅ · `flutter analyze` 0 issues ✅ · `flutter test` 126/126 ✅
(6 new: default, restore, save, broken store, root app mode, Profile switch). Rendered Leads, Live
calls, Hot leads, Viewings, Nurture, Profile and More in dark mode and Profile in light, and reviewed
them: no contrast or layout problems found. **Not verified:** on a device.

### 2026-11-05 — Compact hot-lead rows and tab bar polish
**Built:** Home's "Hot leads waiting" now uses `HotLeadRow` (`hot_leads/widgets/hot_lead_row.dart`)
grouped in one card: score badge, name, ticking countdown text (red when urgent; grey in light /
amber in dark otherwise), area and budget, and a small 36 px "Accept" (48 px tap target) — about
half the height of the old card. `HandoffCard` lost its unused compact mode (the inbox keeps the full
card). Shared `slaCountdown()` + `SlaCountdownText`. Tab bar: 68 px height, selected label violet and
semibold, unselected grey, pill indicator, hairline top border and soft upward shadow (`_BarFrame`)
so it separates from scrolling content. New tokens `AppSizes.compactButtonHeight`,
`AppSizes.navigationBarHeight`, `AppColors.barShadowOpacity`.
**Verification:** `dart format .` ✅ · `flutter analyze` 0 issues ✅ · `flutter test` 120/120 ✅;
rendered Home at 440 × 956 in light and dark and reviewed it. **Not verified:** on a device.

### 2026-11-05 — Dashboard density and order (visibility pass)
**Built:** after a device screenshot showed only the speed card, the tiles and one call above the
fold: speed-to-lead card made compact (title + status, value with "target 60 s", bar, one caption);
KPI tiles use a new dense `MetricTile` layout (`isDense`: tinted icon left, value + label right);
sections reordered by urgency — Hot leads waiting, Live now, Today's viewings — with counts in the
titles; live calls and viewings show as compact rows grouped in one card (`PreviewSection.isGrouped`,
`home/widgets/dashboard_rows.dart`: `LiveCallRow`, `ViewingRow`); compact hot-lead cards put a short
"Accept" on the countdown line (wraps below on small phones / 1.3× text).
**Files:** added `home/widgets/dashboard_rows.dart`; changed `metric_tile.dart`,
`speed_to_lead_card.dart`, `kpi_grid.dart`, `preview_section.dart`, `home_screen.dart`,
`handoff_card.dart`.
**Verification:** `dart format .` ✅ · `flutter analyze` 0 issues ✅ · `flutter test` 120/120 ✅
(the overflow test caught the countdown + Accept line at 360 px / 1.3× before the `Wrap` fix).
Rendered Home at 440 × 956 (light, dark, scrolled) with real fonts and reviewed it.
**Not verified:** on a device.

### 2026-11-05 — App shell, Home dashboard and main screens 4–11 (UI, demo data)
**Built:**
- Onboarding success screen: no "Go to dashboard" button any more. When the check animation ends
  (1.6 s, or at once with reduced motion) it waits `AppDurations.successHold` (2 s) and calls
  `onContinue` once (refresh user → dashboard). Shows "Opening your dashboard…".
- App shell (`features/shell`): `AppTab` (screens 4–10 + More). Bar tabs per role:
  sales agent Home · Hot leads · Leads · Viewings · More; admin / team lead / operations /
  compliance Home · Leads · Live calls · Hot leads · More. "More" lists the rest and pushes them
  with a back button. Tabs build on first visit, then stay alive (IndexedStack). Hot leads tab
  badge = handoffs waiting. Side `NavigationRail` at ≥ 600 px. System back returns to Home first.
- Screen 4 Home: greeting + brokerage, profile avatar, navy speed-to-lead card (P95 vs 60 s),
  KPI tiles (new leads, qualified, hot waiting, viewings today; each opens its tab), previews of
  live calls, hot leads (with Accept) and today's viewings with "See all". Pull to refresh.
- Screen 5 + 11 Leads: search (name / area / phone digits), Hot / Warm / Cold chips with counts,
  filter sheet (source, status, territory, capture date) with a badge count, "Clear filters".
- Screen 6 Live calls: on-a-call / queue / average AI reply tiles, calls in progress with stage,
  ticking timer, latest transcript line and latency (amber above 800 ms), dial queue.
- Screen 7 Hot lead inbox: waiting first, ticking SLA countdown (red in the last minute or
  overdue), AI summary, score reasons, next action, Accept (simulated).
- Screen 8 Viewings: Today / Tomorrow / Next 7 days, grouped by day with status chips.
- Screen 9 Nurture: active / replied / due-today tiles, status filter, journey progress, next touch.
- Screen 10 Profile: account card, role and brokerage, hot-lead alert switches, sign out with a
  confirmation dialog (replaces the Home placeholder's button).
- Shared: `SurfaceCard`, `InitialsAvatar`, `MetricTile`, `EmptyState`, `AsyncValueView`
  (loading → data | empty | error + Retry), `TimeFormat`, `clockProvider` (1 s tick for timers),
  navigation bar / rail theme.

**Files:** added `lib/features/{shell,home,leads,calls,hot_leads,viewings,nurture,profile}/**`,
`lib/app/app_routes_shell.dart` (part of `app_routes.dart`), `lib/core/utils/{time_format,clock}.dart`,
`lib/shared/widgets/{surface_card,initials_avatar,metric_tile,empty_state,async_value_view}.dart`;
tests under `test/features/{shell,leads,hot_leads}/`, `test/core/utils/time_format_test.dart`.
Changed: `app_routes.dart`, `app_theme.dart`, `app_durations.dart`, `ui.dart`,
`onboarding_success_screen.dart`, `test/helpers/fakes.dart` (clock pinned in tests). Deleted
`home/screens/home_placeholder_screen.dart`.

**Decisions / deviations:**
- UI only, as asked: every list loads demo data after `AppDurations.simulatedNetwork` and is
  marked `TODO(backend)` with the planned endpoint (CRM / Zoho later).
- Bottom bars fit 5 items, so each role gets its 4 most-used destinations plus More.
- Dashboard counts are derived from the leads list so Home and Leads always agree; only the
  speed-to-lead figure is a separate demo value.
- Lead and call rows are not tappable yet: the detail screens (12–20) come next.
- Fixed during a rendered check: in dark mode a warning-tone `MetricTile` icon was invisible
  (dark foreground on a dark card); it now uses the amber highlight there.

**Verification:** `dart format .` ✅ · `flutter analyze` 0 issues ✅ · `flutter test` 120/120 ✅
(38 new, incl. every new screen at 360 px / 1.3× in light and dark with no overflow, admin and
agent shells, tablet rail, search/filters, accept, sign-out dialog, success auto-continue with and
without reduced motion). Rendered Home (light + dark), Leads, Live calls, Hot leads, Viewings,
Nurture and Profile to PNG with real fonts and reviewed them (temporary test, deleted).
**Not verified:** on a real device or simulator.

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
| `appShellControllerProvider` | `NotifierProvider.autoDispose<AppShellController, AppTab>` | App shell | Selected bar tab; `select(tab)` → false when the tab lives under More |
| `clockProvider` | `StreamProvider.autoDispose<DateTime>` | App-wide | Ticks every second for call timers and SLA countdowns; pinned in tests |
| `dashboardSummaryProvider` | `FutureProvider.autoDispose<DashboardSummary>` (no auto-retry) | Home | `GET /api/leads/summary`: new / qualified today, contact rate; speed-to-lead null until AI calls exist |
| `leadsControllerProvider` | `AsyncNotifierProvider.autoDispose<LeadsController, List<Lead>>` (no auto-retry) | Shell | `GET /api/leads` (first 100), newest first; `refresh()`, `replaceLead()` |
| `leadAreasProvider` | `Provider.autoDispose<List<String>>` | Filter sheet | Areas of the loaded leads, A–Z |
| `leadsApiServiceProvider` / `leadsRepositoryProvider` | `Provider<LeadsApiService>` / `Provider<LeadsRepository>` | App-wide | `/api/leads/*`; repository overridden with `FakeLeadsRepository` in tests |
| `leadFiltersProvider` / `filteredLeadsProvider` | `NotifierProvider.autoDispose<…, LeadFilters>` / `Provider.autoDispose<AsyncValue<List<Lead>>>` | Leads + filter sheet | query, temperatures, sources, statuses, areas, dateRange; filtered list |
| `liveCallsControllerProvider` | `AsyncNotifierProvider.autoDispose<…, LiveCallsSnapshot>` | Shell | active calls + dial queue; `refresh()` |
| `hotLeadsControllerProvider` | `AsyncNotifierProvider.autoDispose<…, List<Handoff>>` | Shell | handoffs (waiting first); `accept(id)` → `bool`, `refresh()` |
| `viewingsControllerProvider` / `viewingRangeProvider` | `AsyncNotifierProvider.autoDispose<…, List<Viewing>>` / `NotifierProvider.autoDispose<…, ViewingRange>` | Shell / Viewings | viewings (earliest first); selected range |
| `nurtureControllerProvider` / `nurtureStatusFilterProvider` | `AsyncNotifierProvider.autoDispose<…, List<NurtureEnrollment>>` / `NotifierProvider.autoDispose<…, NurtureStatus?>` | Nurture | enrollments; status filter |
| `themeModeControllerProvider` / `themePreferenceStoreProvider` | `NotifierProvider<ThemeModeController, ThemeMode>` / `Provider<ThemePreferenceStore>` | App-wide | Light / Dark / System; `select(mode)` saves it |
| `leadProfileControllerProvider(leadId)` | `AsyncNotifierProvider.autoDispose.family<LeadProfileController, LeadProfile, String>` (no auto-retry) | Lead profile + message sheet | From `GET /api/leads/{id}` + `/timeline`: lead, email, qualification, scoreReasons, timeline, consents, calls (empty: no calls API), busyAction; `requestCallBack()`, `sendMessage()`, `withdrawConsent()`, `markDoNotContact()` → `LeadActionOutcome` (server call, then re-fetch); `recordViewingBooked()` (local); `refresh()` |
| `liveCallMonitorProvider(callId)` | `Provider.autoDispose.family<AsyncValue<LiveCallMonitor>, String>` | Live call monitor | call, lines so far, qualification, stage, isEnded (re-evaluates every clock tick) |
| `callDetailProvider(callId)` | `FutureProvider.autoDispose.family<CallDetail, String>` (no auto-retry) | Call detail + transcript | outcome, summary, nextStep, qualification, score, transcript |
| `bookViewingControllerProvider(leadId)` | `NotifierProvider.autoDispose.family<BookViewingController, BookViewingState, String>` | Book viewing | properties, days, day, slots, propertyId, heldSlot, holdUntil, isHolding, isBooking, errorMessage; `selectProperty()`, `selectDay()`, `holdSlot()` → `bool`, `confirm()` → `LeadActionOutcome` |
| `profileAlertsControllerProvider` | `NotifierProvider.autoDispose<…, HotLeadAlertsDraft>` | Profile | push, SMS fallback, sound (local until the profile API) |
| `stepValidProvider(step)` | `Provider.family<bool, OnboardingStepId>` | Onboarding | Whether Continue is enabled for that step |
| `forgotPasswordControllerProvider` | `NotifierProvider.autoDispose<ForgotPasswordController, ForgotPasswordState>` | Forgot-password sheet | email, emailError, isSending, isSent; `sendResetLink()` → `bool` (real API) |

## TODO(backend)
Integrated on 2026-11-05 (no longer placeholders): session restore, login, logout, `GET /auth/me`,
forgot password, onboarding save/skip/resume/complete, team invites; leads list, lead profile +
timeline, consent withdrawal, do-not-contact, dashboard new / qualified / contact-rate counts.
Still simulated or partial:

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
| `leads/repositories/leads_repository.dart` | `fetchLeads()` loads the first 100, filters on device | Page beyond 100 and send `q`, `temperature`, `source`, `status`, `area`, `days` (the endpoint supports them) |
| `leads/controllers/leads_controller.dart` | No live updates | socket.io lead events |
| `leads/demo_lead_bridge.dart` | Demo ids (`lead-02`) from hot leads / viewings / calls resolved to server leads by name | Remove once those APIs return real lead ids |
| `calls/controllers/live_calls_controller.dart` | `build()` demo snapshot | `GET /api/calls/live` + socket.io `call:*` events |
| `hot_leads/controllers/hot_leads_controller.dart` | `build()` demo handoffs | `GET /api/handoffs?status=waiting,accepted`; new ones via FCM + socket.io |
| `hot_leads/controllers/hot_leads_controller.dart` | `accept()` simulated | `POST /api/handoffs/{id}/accept`; 409 when another agent took it |
| `viewings/controllers/viewings_controller.dart` | `build()` demo viewings | `GET /api/viewings?from=&to=` (own for agents, all for admins / leads) |
| `nurture/controllers/nurture_controller.dart` | `build()` demo enrollments | `GET /api/nurture/enrollments` (cadence engine W11–W12) |
| `lead_detail/controllers/lead_profile_controller.dart` | `requestCallBack()` — the server only records it | Server: enqueue the AI call (Voice AI dialler); app: change the message to "Mergro will call … within 60 seconds" |
| `lead_detail/controllers/lead_profile_controller.dart` | `sendMessage()` — the server only records it | Server: send through the SMS / WhatsApp / email connectors |
| `lead_detail/controllers/lead_profile_controller.dart` | `recordViewingBooked()` updates the device copy only | Re-fetch the profile once `POST /api/viewings` exists |
| `lead_detail/models/lead_profile_json.dart` | `calls: []` | `GET /api/calls?leadId=` |
| `calls/controllers/call_providers.dart` | `liveCallMonitorProvider` replays a demo script | socket.io `call:{id}:transcript` + `call:{id}:fields` |
| `calls/controllers/call_providers.dart` | `callDetailProvider` demo | `GET /api/calls/{id}` + `GET /api/calls/{id}/transcript` |
| `calls/screens/live_call_monitor_screen.dart` | take over / warm transfer note | `POST /api/calls/{id}/transfer` (telephony integration) |
| `calls/screens/transcript_screen.dart` | no audio | `GET /api/calls/{id}/recording` + an approved audio package |
| `viewings/controllers/book_viewing_controller.dart` | demo listings + slots | `GET /api/listings?leadId=`, `GET /api/viewings/slots?propertyId=&date=` |
| `viewings/controllers/book_viewing_controller.dart` | `holdSlot()` / `selectDay()` | `POST /api/viewings/hold` (409 = taken), `DELETE /api/viewings/hold/{id}` |
| `viewings/controllers/book_viewing_controller.dart` | `confirm()` | `POST /api/viewings {holdId, leadId, propertyId}` (SMS + CRM) |
| Server `leadSummary` | `speedToLeadSeconds: null` (card shows "No calls yet") | P95 capture → AI call time once AI calls are logged (analytics W11–W12) |
| `profile/controllers/profile_alerts_controller.dart` | defaults, local edits | `GET` / `PUT /api/profile/alerts` (data already stored by onboarding) |

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
- Lead profile: `lib/features/lead_detail/**` (incl. `models/lead_profile_json.dart`)
- Leads API: `lib/features/leads/{services/leads_api_service,repositories/leads_repository,demo_lead_bridge}.dart`,
  `lib/core/utils/no_automatic_retry.dart`, `test/helpers/{fake_leads_repository,in_memory_stores}.dart`
- Calls and booking: `lib/features/calls/{call_script_demo_data.dart,models/call_transcript.dart,controllers/call_providers.dart,screens/*,widgets/transcript_view.dart}`, `lib/features/viewings/{booking_demo_data.dart,models/booking.dart,controllers/book_viewing_controller.dart,screens/book_viewing_screen.dart,widgets/slot_picker.dart}`, `lib/core/utils/pii_mask.dart`
- Shell and main screens: `lib/features/{shell,home,leads,calls,hot_leads,viewings,nurture,profile}/**`,
  `lib/app/app_routes_shell.dart`, `lib/core/utils/{time_format,clock}.dart`,
  `lib/shared/widgets/{surface_card,initials_avatar,metric_tile,empty_state,async_value_view}.dart`
  (the Home placeholder was removed)
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

**State at handoff (2026-11-05):** backend integration committed on
`feature/backend-auth-onboarding` (app) and `feature/mergro-auth-onboarding-api` (backend). The
shell / dashboard work is on `feature/app-shell-dashboard` (app): commit `99eeb7d` has the shell
and screens 4–11; the later passes (dashboard density, compact hot leads, tab bar, theme choice,
skeleton loading, doc updates, Parts A and B — screens 12–20) are **not committed yet**. Nothing is pushed.

**Update (2026-11-05, later):** all earlier branches are committed and pushed. The leads API
(backend `feature/leads-api`, pushed) is connected in the app on `feature/leads-api-integration`
(committed, not pushed).

**Next recommended task:** propose the next phase and wait for confirmation. Candidates: the
handoff module (21–26: hot-lead alert, handoff detail, accept & call back, viewing calendar,
booking confirmed, viewing outcome), or start connecting screens to the backend once the lead /
call API exists. Parts A and B (screens 12–20) are done but not committed. Also still open: run the app on an Android emulator and an iOS simulator against the
local API and walk through admin, agent and team-lead onboarding (including Retry with the server
stopped and sign-out); check light/dark, 360 px and 1.3× on the new loading/error/invite states;
then build a page (web or in-app) for `/changeRecoverPassword/:enEmail?token=` so reset and invite
emails can be completed, and enable SendGrid in the `settings` document.
