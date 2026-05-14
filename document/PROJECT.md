# Nivvesh — project overview

This document describes the **nivvesh** Flutter application in this repository: what it does, how people use it, how it is structured, and how to build and configure it.

**Open source initiative:** Nivvesh is developed as an **open source initiative**—transparent development, public collaboration, and community contributions are part of the project’s goals. Exact terms of use and redistribution are defined by the license file in the repository root when present.

## Purpose

**Nivvesh** is a cross-platform personal finance companion. It helps users see **cashflow and balance** on the home screen, review **transaction history** (including automatic parsing of bank SMS on Android), get an optional **AI assistant** (Google Gemini), manage **financial journeys** (goals backed by the backend), and stay on top of **alerts** and **notifications**. Users sign in with **phone number and OTP** against the production API host **`api.nivvesh.com`**. In-app WebViews for **help** and **FD-related content** use first-party URLs defined in [`lib/core/constants/public_web_urls.dart`](../lib/core/constants/public_web_urls.dart) (update that file when your live marketing or help pages are ready).

### Spend data stays on the device (product summary)

**Transactions** derived from **bank SMS** (Android) and **statement PDFs** (iOS) are stored in **Isar on the handset** for History, charts, search, and home summaries—the app **does not** expose these records through its REST clients as an uploaded expense ledger. The **AI** path builds a **snapshot from that local store** for each reply (`finance_context_builder`, `ai_chat_controller`); if **Gemini** is enabled at build time, the composed prompt is sent to the **model provider** for inference, while the **authoritative spend database for the spend UI remains local**.

## Who uses it and how the app is used

Typical flow:

1. **Install** the app on a supported device (Android, iOS, and other Flutter targets are present in the repo).
2. **Sign in** with an Indian-format phone number; the app sends an OTP and verifies it with the backend (`lib/presentation/auth/pages/login_page.dart`, auth APIs under `lib/data/api/`).
3. On **Android**, the user may grant **SMS** and **notification** permissions so the app can **listen for bank SMS**, parse amounts and debit/credit intent, and persist transactions locally. This path is wired in `lib/main.dart` using the `telephony` package and `SmsParser` / `background_sms_handler.dart`.
4. **Home** shows balance and cashflow-oriented widgets (`lib/presentation/home/`). A floating **FDs** control opens the `/bank` WebView, whose URL comes from [`public_web_urls.dart`](../lib/core/constants/public_web_urls.dart) (`nivveshFdsWebUrl`).
5. **History** (shell tab labeled “History”) is the spend / transactions experience (`lib/presentation/transactions/`).
6. **AI** tab opens the chat UI; the engine is **Gemini** when `GEMINI_API_KEY` is supplied at compile time (`lib/main.dart`, `lib/application/ai/`).
7. **Journey** lists and edits journeys synced via `lib/data/api/journey.api.dart` and related repositories.
8. **Alerts** surfaces alert UI (`lib/presentation/alerts/`). **Firebase Cloud Messaging** is initialized for push; local notifications are also used on Android (for example, savings-related or AI deep links — see `lib/main.dart` and `lib/application/transactions/savings_evaluator.dart`).

**Platform note:** SMS listening, parts of local notification setup, and related background behavior are **Android-specific** in `main.dart`. On iOS and other platforms, users still get the main navigation shell and server-backed features, but not the same automatic SMS ingestion pipeline.

## Architecture at a glance

| Layer | Role |
|--------|------|
| `lib/presentation/` | Widgets, pages, routing targets (UI). |
| `lib/application/` | Riverpod controllers/providers, app state. |
| `lib/domain/` | Models and domain-oriented types. |
| `lib/data/` | API clients, repositories, local caches, Isar usage. |

**Navigation:** `go_router` with a `StatefulShellRoute` for the main bottom tabs (Home, History, AI, Journey, Alerts). Auth gate redirects unauthenticated users to login (`lib/core/router/app_router.dart`).

**State:** `flutter_riverpod` with code generation for some providers (`riverpod_annotation`, `*.g.dart` files).

**Networking:** HTTP clients build HTTPS URLs from `lib/data/api/server_api.dart` (`apiBaseUrl = api.nivvesh.com`) and `lib/data/api/api_client.dart`.

**Local database:** [Isar](https://isar.dev) — opened in `main.dart` with `FinanceModelSchema` for finance records.

## Key integrations

| Integration | Where / notes |
|-------------|----------------|
| Backend API | `https://api.nivvesh.com` — `server_api.dart`, `auth_api.dart`, `user_api.dart`, `journey.api.dart`, etc. |
| In-app WebViews (FDs, login help) | URLs from [`lib/core/constants/public_web_urls.dart`](../lib/core/constants/public_web_urls.dart) — `/bank` route and login `SupportWebView`. |
| Firebase | `firebase_core`, `firebase_messaging` — init and background handler in `main.dart`. |
| Gemini (optional) | `--dart-define=GEMINI_API_KEY=...` and optional `GEMINI_MODEL` (default `gemini-2.5-flash`). |
| Android SMS | `telephony` + `SmsParser` + `background_sms_handler.dart`. |
| Background tasks | `workmanager` — periodic task `monthly_savings_eval` calling `evaluateMonthlySavings()`. |

## Build and run

**Prerequisites:** Flutter SDK compatible with `sdk: ^3.10.0` in `pubspec.yaml`.

```bash
flutter pub get
```

**Code generation:** After changing Riverpod- or Isar-annotated code, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Run the app:**

```bash
flutter run
```

**Gemini-enabled run example:**

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key_here --dart-define=GEMINI_MODEL=gemini-2.5-flash
```

If `GEMINI_API_KEY` is empty, the app still runs; the AI engine override is not applied (`lib/main.dart`).

## Configuration and operations notes

- **Firebase:** `Firebase.initializeApp()` runs at startup; failures are caught and logged, so push may not work until platform config (`google-services` / `GoogleService-Info.plist`) is correct for your flavor.
- **Secrets:** Do not commit API keys. Prefer CI or local `--dart-define` for Gemini.
- **Savings notifications:** `evaluateMonthlySavings()` uses **SharedPreferences** keys maintained by the SMS background path; it is invoked from WorkManager and once on app open as a fallback (`lib/application/transactions/savings_evaluator.dart`).

## Related documentation

- [REACT_MARKETING_SITE_BLUEPRINT.md](./REACT_MARKETING_SITE_BLUEPRINT.md) — static marketing site spec aligned with this app’s theme and messaging.
- Repository [README.md](../README.md) — short entry point and quick start.

## Source map (quick reference)

- Entry: `lib/main.dart`
- Router: `lib/core/router/app_router.dart`
- Theme: `lib/core/theme/app_theme.dart`, `lib/core/theme/app_colors.dart`
- Auth: `lib/presentation/auth/pages/login_page.dart`, `lib/data/repositories/auth_repository.dart`
- SMS / finance: `lib/application/transactions/sms_parser.dart`, `background_sms_handler.dart`, `finance_controller.dart`
