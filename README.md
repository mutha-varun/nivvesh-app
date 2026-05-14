# Nivvesh (Flutter)

## How Nivvesh helps you manage money

Nivvesh focuses on **understanding spending from data that already lives on your device**, instead of asking you to ship a running ledger off your phone to be stored as a cloud expense archive.

- **On-device collection.** On **Android**, with your permission, the app can read **bank SMS**, interpret debits and credits, and turn them into structured transactions. On **iOS**, you can import **bank statement PDFs** (including password-protected files when you supply the password). Parsing and persistence for these flows use **local storage** (Isar) on the handset.
- **Expenses stay with you.** The **transaction history** built from SMS and PDF import is **kept on your device** for history, charts, search, filters, and home summaries—**not synced to our infrastructure as your expense database.**
- **AI in the flow of the app.** The **AI** tab is there so you can ask questions **there and then**: the assistant uses a **snapshot assembled from that same on-device activity** so replies line up with what you actually spent. Depending on how the app is built, the reply engine may be a local placeholder or an optional **cloud** model you configure at build time; either way, the **canonical spend record for this experience remains local**, not hosted by us as a cross-device expense tracker.

For **sign-in, journeys, notifications**, and other product surfaces that naturally use the network, see the technical overview in **[document/PROJECT.md](document/PROJECT.md)**.

This repository is part of an **open source initiative**: development is intended to be transparent and welcoming to contributions. See the license file in the repository root for legal terms once it is added.

## Documentation

- **[Product overview and usage](document/PROJECT.md)** — full feature list, architecture, integrations, build/run, and platform notes.
- **[React marketing site blueprint](document/REACT_MARKETING_SITE_BLUEPRINT.md)** — static marketing site spec aligned with theme and messaging (no app logic; **no API or backend URLs** in public copy).

## Stack

- Flutter (`sdk: ^3.10.0` in `pubspec.yaml`)
- Riverpod + riverpod_annotation / code generation
- go_router
- Isar (local finance models)
- http, shared_preferences, flutter_secure_storage
- Firebase (Core + Messaging)
- Android: telephony (SMS), WorkManager, flutter_local_notifications
- Optional AI: compile-time `--dart-define` for a pluggable chat engine (see `lib/application/ai/`)

## Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) matching the SDK constraint in `pubspec.yaml`.

## Quick start

```bash
git clone <repository-url>
cd nivvesh-app
flutter pub get
```

After changing annotated Riverpod or Isar code, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Run on a device or emulator:

```bash
flutter run
```

Optional Gemini-backed AI (when wired in `main.dart`):

```bash
flutter run --dart-define=GEMINI_API_KEY=your_key --dart-define=GEMINI_MODEL=gemini-2.5-flash
```

If `GEMINI_API_KEY` is omitted, the app runs without overriding the default AI engine configuration in code.

## Firebase

Firebase is initialized at startup. Ensure Android and iOS are configured with the correct Firebase project files for push messaging to work.

## License

Nivvesh is an **open source initiative**; add a `LICENSE` file at the repository root (for example MIT or Apache-2.0) so others know how they may use and contribute to the code. `publish_to: 'none'` in `pubspec.yaml` only means the package is not published to pub.dev.
