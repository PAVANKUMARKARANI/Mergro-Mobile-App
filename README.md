# Mergro — AI Voice Agent (mobile app)

Flutter app for real-estate brokerages using Mergro: an AI voice agent calls every new lead within
60 seconds, qualifies them, books viewings and hands hot leads to agents. This app is where
admins set Mergro up and where agents and team leads work their leads.

Backend: Express + MongoDB in `~/Projects/Mergro/server` (endpoints in its README).

## Status (5 Nov 2026)

| Area | Screens | State |
|------|---------|-------|
| Entry | Splash (1), Login + forgot password (2), Onboarding for admin / agent / team lead (3) | Connected to the API |
| App shell | Role-based bottom tabs (side rail on tablets), More, sign-out | Done |
| Main screens | Home dashboard (4), Leads + search (5, 11), Live calls (6), Hot lead inbox (7), Viewings (8), Nurture (9), Profile (10) | UI with demo data |
| Detail screens | Live call monitor (12) … Consent (20) | Next (plan proposed) |
| Theme | Light / Dark / System choice, skeleton loading | Done |

Screen numbers follow the screen flow (`~/Projects/mobile designs/mergro-screen-flow/`). The
phase-by-phase plan is the "Mergro Build Flow" artifact. `skill.md` is the detailed log: what was
built, every provider, and every `TODO(backend)` still to connect.

## Run it

1. Start the backend (`~/Projects/Mergro/server`): `npm install`, fill `server/.env` from
   `.env.example`, `npm run seed` once, then `node server-start.js` (port 2282).
2. Run the app:
   - Android emulator or iOS simulator: `flutter run` (the emulator reaches the host at `10.0.2.2`
     automatically).
   - Physical phone: `flutter run --dart-define=API_BASE_URL=http://<your-computer-ip>:2282/api`.
3. Sign in with a demo account: `admin@yopmail.com`, `agent@yopmail.com` or `lead@yopmail.com`,
   password `Emp1234$`. Each role sees its own onboarding and tabs. (yopmail inboxes are public —
   demo use only.)

## Project layout

```
lib/
├── app/          MergroApp, AppRoutes (all navigation lives here)
├── core/         network (ApiClient), storage, theme tokens, utils, validation
├── features/     auth, onboarding, shell, home, leads, calls, hot_leads,
│                 viewings, nurture, profile, splash
│                 → models/ services/ repositories/ controllers/ screens/ widgets/
└── shared/       ui.dart barrel and shared widgets
test/             controller, model and widget tests; helpers/fakes.dart keeps tests offline
```

Riverpod 3 (`Notifier` / `AsyncNotifier`, no code generation), dio + flutter_secure_storage for the
API session, Lucide icons, Sora / Figtree / JetBrains Mono.

## Working on it

Read `AGENTS.md`, `CLAUDE.md`, `standards.md` and `skill.md` first. Before finishing any change:

```
dart format .
flutter analyze      # must report no issues
flutter test
```

Keep every Dart file at most 250 lines, document every class and method, check light and dark mode
at 360 px with 1.3× text, and add the change to `skill.md`.
