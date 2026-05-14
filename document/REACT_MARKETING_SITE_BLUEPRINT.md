# React marketing site — blueprint

This document is a **blueprint for a separate repository**: a **static** React website (landing page plus sections). It should **not** duplicate app functionality (no OTP, SMS, APIs, Isar, or Firebase). It **should** match the **Nivvesh mobile app** story, structure, and **visual theme** so marketing and product feel consistent.

**Open source initiative:** Nivvesh is an **open source initiative**. The marketing site should reflect that where appropriate—for example a short line in the footer that the project is open source, plus links to this Flutter repository and (when published) the site’s own repo and license.

**Canonical product facts:** derive copy from [PROJECT.md](./PROJECT.md) and the Flutter sources referenced there. Do not invent features the app does not implement.

---

## 1. Goals and non-goals

**Goals**

- Explain what Nivvesh is in plain language.
- Mirror the app’s **five main pillars** (Home, History, AI, Journey, Alerts) as marketing sections.
- Use the same **typography and color system** as the Flutter app (`lib/core/theme/app_theme.dart`, `lib/core/theme/app_colors.dart`).
- Provide clear **calls to action**: download app (store URLs when available), optional links to **support** and **product** pages that match the URLs configured in the Flutter app’s [`public_web_urls.dart`](../lib/core/constants/public_web_urls.dart).
- Reinforce that Nivvesh is an **open source initiative** in footer or about copy (consistent with [PROJECT.md](./PROJECT.md)).

**Non-goals**

- No sign-in to the mobile app, no calling application backends, no embedding AI keys or Firebase in the static site.
- No user dashboards or live financial data in the browser.
- No legal policy pages unless you add them separately (keep a short “privacy at a glance” section optional and high-level only).

**Marketing copy rules:** Do **not** publish **API hosts**, internal service URLs, or other backend-level links on the marketing site. Help, FD, and other **user-facing web pages** should match whatever first-party URLs ship in the Flutter app’s URL constants (see [`public_web_urls.dart`](../lib/core/constants/public_web_urls.dart))—mirror those paths in CTAs only, without documenting infrastructure.

---

## 2. Information architecture

Single-page app (SPA) with anchor sections **or** a few shallow routes. Suggested sections in order:

| Section | Purpose |
|---------|---------|
| **Hero** | Product name **Nivvesh**, one-line value prop (device-first money clarity, history, optional AI, journeys, alerts). Primary CTA: “Get the app” (App Store / Play Store when URLs exist). Optional secondary CTAs for help / FD-style pages: use the **same first-party web URLs** configured for the mobile app (see [`public_web_urls.dart`](../lib/core/constants/public_web_urls.dart)), or omit until live. |
| **Features** | Use the **full feature catalog** in §2.1 below—group into scannable blocks (Home, History & data, AI, Journey, Alerts & notifications, account & settings). |
| **How it works** | Short strip: install app → sign in → (Android) optional SMS/notifications for auto-capture → see home and history; optional AI for questions. Align wording with [PROJECT.md](./PROJECT.md) and the device-first story in the repository README. |
| **Trust / privacy (short)** | Lead with **on-device** parsing and **local** storage of transaction-derived data for the spend experience; optional AI only as described in README (in-the-moment help, no ledger hosted as a cloud expense archive by the app). Avoid legal claims you cannot support. |
| **Footer** | Logo, copyright, first-party **help** / **FD** links aligned with the mobile app URL constants, store badges (TBD), **open source initiative** line, links to this Flutter repo (and marketing repo if split). **No** API or backend hostnames. |

### 2.1 Mobile app — full feature catalog (for marketing copy)

Use this checklist so the React site reflects **everything the Flutter app actually does** (group and shorten for layout).

**Shell & navigation**

- Bottom navigation with five tabs: **Home**, **History**, **AI**, **Journey**, **Alerts** (`MainShell`, `app_router.dart`).
- **Splash → login** gating for signed-out users; authenticated users land on **Home**.
- **Light / dark** theme following system or in-app preference (`theme_provider`, `AppTheme`).

**Home**

- **Header** with user-oriented context (`HomeHeader`).
- **Balance** summary card (`HomeBalanceCard`).
- **Cashflow** card (`HomeCashflowCard`).
- **FD comparison** horizontal strip with illustrative bank rows and “View all” placeholder (`HomeFdComparison` — “Coming soon” until wired).
- Floating **FDs** action opening an **in-app browser** (URL from app constants, not duplicated on the marketing site as an API link).
- Optional route to **Investment** WebView when the app has a **post-login redirect URL** from its configuration (otherwise a friendly “complete login” state).

**History (spend / transactions)**

- **Android:** read inbox SMS (with permission), parse financial messages (`SmsParser`), merge into **local database** (Isar), pull-to-refresh / sync style refresh.
- **iOS:** **PDF bank statement** import (`file_picker`), optional password retry for encrypted PDFs, parse and store locally (same Isar store).
- **Search** across transactions (`HistorySearchBar`, search providers).
- **Charts** for spend over time (`SpendChart`, `fl_chart`).
- **Filters:** time period, categories, debit/credit type, etc. (`FilterToolbar`, `filter_finance_provider`).
- **Category limit** style progress UI tied to alert configuration (`CategoryLimitProgressSliver`, `alert_config`).
- Quick link from History app bar to **Alerts**.

**AI assistant**

- Chat UI with **starter prompts**, **markdown** rendering for replies, scroll-to-latest behavior.
- **Speech-to-text** input path for dictating questions (when the device supports it).
- Assistant is **finance-scoped** in code: it uses a **snapshot built from on-device transaction data** in the system prompt (see `ai_chat_controller`, `finance_context_builder`). Default engine can be a **stub**; optional **Gemini** integration is compile-time configured in the app—not something the static site implements.

**Journey**

- List, **create**, and **edit** journeys (goal-style flows) with sheets and backend-backed persistence in the app (describe on the site as “plans and goals in the app” without API URLs).

**Alerts**

- Dedicated **Alerts** tab and configuration entry points tied to spend behavior (`alerts_page`, alert config).

**Notifications**

- Dedicated **Notifications** screen from routing (`NotificationsPage`).
- **Push** messaging stack initialized in the app; **local notifications** on Android for certain flows (e.g. savings-related or AI deep links as implemented in `main.dart` / savings evaluator).

**Auth & help**

- **Phone number + OTP** sign-in flow (`LoginPage`, `pinput`).
- **In-app help** browser opened from login (URL from app constants — mirror only the **public** page on the marketing site, not backend links).

**Background & system integration (Android-focused)**

- **Incoming SMS listener** and background handler for timely parsing/notifications where enabled (`telephony`, `background_sms_handler`).
- **Periodic background task** for monthly savings evaluation and optional motivational notifications (`Workmanager`, `savings_evaluator`).
- **Shared preferences** for small aggregates used by savings evaluation (not a cloud expense ledger).

**Other / deep links & platform services**

- Routes such as **`/finance`** (entry splash) and **`/finance/sheet`** (sheet-style entry to History) support alternate entry into the spend experience (`app_router.dart`).
- **Firebase** initialization for push (marketing: “stay updated” level only—no keys on web).
- Optional **file / PDF** flows and other dependencies listed in `pubspec.yaml` for parity with engineering (do not turn into promises the release build does not ship).

---

## 3. Theme parity (Flutter → web)

### 3.1 Typography

- **Font family:** **Inter** (the Flutter app uses `GoogleFonts.inter` in `app_theme.dart`).
- **Loading on web:** `@fontsource-variable/inter` or Google Fonts link with `display=swap`.
- **Weights:** `500` (labels, some titles), `600` (headings, buttons), `700` (hero headline).
- **Body:** comfortable line height **~1.5** for secondary copy (matches `bodyMedium` height in `app_theme.dart`).

### 3.2 CSS custom properties

Map Flutter `AppColorsBase` tokens to CSS variables. Use `:root` for **light** and `[data-theme="dark"]` or `.dark` for **dark** (or rely on `prefers-color-scheme`).

**Dark theme** (from `DarkAppColors` in `app_colors.dart`):

| Token | Hex | Usage |
|-------|-----|--------|
| `--color-background` | `#000000` | Page background |
| `--color-surface` | `#1C1B1F` | Cards, elevated surfaces |
| `--color-primary-text` | `#E6E1E5` | Headings, body |
| `--color-secondary-text` | `#938F99` | Muted text |
| `--color-muted` | `#8E8E93` | Nav inactive, hints |
| `--color-accent-primary` | `#34D399` | Primary CTA, positive emphasis |
| `--color-accent-primary-soft` | `#10B981` | Gradients / hover |
| `--color-accent-tint-10` | `rgba(52, 211, 153, 0.1)` | Active tab pill |
| `--color-income-positive` | `#34D399` | “Credit / saved” hints |
| `--color-expense-negative` | `#FB7185` | Spend / caution |
| `--color-surface-tint-high` | `rgba(31, 41, 55, 0.5)` | Glass panels (`#801F2937`) |
| `--color-border-subtle` | `rgba(55, 65, 81, 0.5)` | Dividers (`#80374151`) |
| `--color-error` | `#FFB4AB` | Error text only if needed |

**Light theme** (from `LightAppColors`):

| Token | Hex | Usage |
|-------|-----|--------|
| `--color-background` | `#FFFBFE` | Page background |
| `--color-primary-text` | `#1C1B1F` | Main text |
| `--color-secondary-text` | `#49454F` | Secondary |
| `--color-muted` | `#79747E` | Muted |
| `--color-accent-primary` | `#10B981` | Primary CTA |
| `--color-accent` | `#6750A4` | Secondary brand / purple accents |
| `--color-accent-container` | `#EADDFF` | Soft purple fills |
| `--color-income-positive` | `#059669` | Positive money |
| `--color-expense-negative` | `#E11D48` | Negative / spend |
| `--color-border` | `#E5E0EC` | Default borders |

**ColorScheme alignment:** In both themes the Material `ColorScheme` uses **accent green** as `primary` with **black** `onPrimary` for filled buttons in Flutter — mirror that for primary buttons on the web (green background, black label text).

### 3.3 Components (match `app_theme.dart` / shell)

| Component | Spec |
|-----------|------|
| **Primary button** | Background `--color-accent-primary`, text **black**, `border-radius: 12px`, font-weight **600**, font-size **14px** (see `FilledButtonTheme`). |
| **Secondary / outline** | Transparent or surface fill, border from `--color-border` or `--color-border-subtle`, same radius **12px**, weight **500**. |
| **Chips / pills** | `border-radius: 9999px` (Flutter uses `100`), padding ~`12px × 6px`, border using accent at ~35% opacity in dark or `outlineVariant` in light. |
| **Top bar / hero header** | **Transparent** background, no elevation (see `AppBarTheme`). |
| **Glass footer (optional)** | Backdrop blur (~20px) + semi-transparent surface tint to echo `MainShell` bottom navigation (`BackdropFilter` + `surfaceTintHigh` in `main_shell.dart`). |

### 3.4 Assets to reuse

Copy from this Flutter repo into the React repo’s `public/` or `src/assets/`:

| File | Notes |
|------|--------|
| `assets/nivvesh_logo.png` | Primary logo |
| `assets/nivvesh_app_plain_logo.png` | Alternate / wordmark |
| Splash reference | `pubspec.yaml` → `flutter_native_splash` uses `#0F1115` and `assets/splash_logo.png` — useful for a dark “brand stripe” or loading aesthetic |

---

## 4. Technical stack (recommended)

- **Build:** Vite + **React 18+** + **TypeScript**.
- **Routing:** `react-router-dom` for `/` plus optional routes like `/privacy` later; or a single page with `id` anchors (`#features`, `#how-it-works`).
- **Styling:** **Tailwind CSS** v4 or v3 with `theme.extend.colors` bound to the CSS variables above **or** plain CSS modules importing a `tokens.css`.
- **Icons:** `lucide-react` or inline SVGs that map to Material-style metaphors used in the app (home, history, sparkles/AI, map/journey, bell/alerts) for visual consistency without bundling Material Icons if you want a smaller bundle.
- **Hosting:** any static host (Vercel, Netlify, S3 + CloudFront, GitHub Pages).

---

## 5. Accessibility and SEO

- Ensure **contrast** for green-on-black buttons (WCAG AA where possible); if needed, slightly lighten text or use a white button with green border for the hero CTA variant.
- Visible **focus rings** on interactive elements.
- One **`<h1>`** in the hero; section headings **`h2`–`h3`** in order.
- **Meta:** `title`, `description`, Open Graph image (export from logo at 1200×630).

---

## 6. First-party web links only (no API or backend URLs on the site)

Help, FD, and similar CTAs must point to the **same user-facing pages** the mobile app opens from its URL constants file—**update that Dart file first**, then mirror **only those public web links** in the React footer or hero. Never document or link **application API** or **internal service** endpoints on the marketing site.

---

## 7. Deliverable checklist for the React repo

- [ ] Inter loaded; light/dark tokens applied.
- [ ] Hero + Features + How it works + Footer implemented as static content.
- [ ] CTAs: app stores (placeholder OK); help / FD links match the mobile app’s public URL constants (§6).
- [ ] No calls to application backends; no API or internal hostnames in copy or env.
- [ ] README in the React repo links back to this Flutter repo or to `PROJECT.md` for factual updates, and states that the product is an **open source initiative** (with license link when available).

When the mobile product changes, **update [PROJECT.md](./PROJECT.md) first**, then refresh marketing copy to match.
