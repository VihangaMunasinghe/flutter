# 📋 Asgardeo Push Authenticator — Codebase Documentation

## 📑 Table of Contents

- [Technology Stack](#-technology-stack)
- [Package Dependencies & Usage](#-package-dependencies--usage)
  - [Core Dependencies](#core-dependencies)
  - [Dev Dependencies](#dev-dependencies)
- [Directory Structure & Architecture](#-directory-structure--architecture)
  - [Root Level Files](#root-level-files)
  - [`lib/` Directory](#lib-directory)
  - [`assets/` Directory](#assets-directory)
- [Application Flow & Architecture](#-application-flow--architecture)
  - [Initialization Sequence](#initialization-sequence)
  - [Notification Handling](#notification-handling)
  - [Provider Hierarchy](#provider-hierarchy)
  - [Storage Architecture](#storage-architecture)
- [Key Features Implementation](#-key-features-implementation)
  - [Push Authentication](#push-authentication)
  - [QR Code Scanning](#qr-code-scanning)
  - [Number Challenge](#number-challenge)

---

## 🧑‍💻 Technology Stack

- **Framework**: Flutter
- **Language**: Dart
- **State Management**: [Riverpod](https://riverpod.dev/)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Push Auth SDK**: [`asgardeo_push_auth`](<PACKAGE_REPO_URL>)
- **Platform**: iOS & Android

> [!TIP]
> See [`pubspec.yaml`](../pubspec.yaml) for current dependency versions.

---

## 📦 Package Dependencies & Usage

### Core Dependencies

| Package | Purpose | Usage in Project |
|---------|---------|------------------|
| `flutter` | Flutter framework | Mobile app foundation |
| `asgardeo_push_auth` | Push authentication SDK | All push auth operations — registration, signing, responses, accounts, history |
| `cupertino_icons` | iOS-style icon library | Platform-appropriate icons |
| `firebase_core` | Firebase core services | Firebase initialization at app startup |
| `firebase_messaging` | Firebase Cloud Messaging | Push notification delivery and handling |
| `flutter_native_splash` | Native splash screen | Splash screen during app initialization |
| `flutter_riverpod` | State management | Reactive state management with providers |
| `go_router` | Declarative routing | Navigation between screens with path parameters |
| `http` | HTTP client | Custom HTTP client for dev mode with self-signed certificate support |
| `mobile_scanner` | QR/barcode scanning | Camera-based QR code scanning for device registration |
| `shared_preferences` | Key-value storage | Theme mode persistence and FCM background notification storage |

### Dev Dependencies

| Package | Purpose | Usage in Project |
|---------|---------|------------------|
| `flutter_test` | Testing framework | Unit and widget testing |
| `flutter_launcher_icons` | App icon generation | Generates adaptive icons for Android and iOS |
| `very_good_analysis` | Lint rules | Enforces code quality and consistent style |

---

## 📁 Directory Structure & Architecture

### Root Level Files

- **`pubspec.yaml`**: Project dependencies, asset declarations, splash screen and launcher icon configuration
- **`analysis_options.yaml`**: Dart analysis rules (uses `very_good_analysis`)

### `lib/` Directory

```
lib/
├── main.dart                          # App entry point and initialization
├── app.dart                           # Root widget, router, and messaging setup
├── firebase_options.dart              # Firebase platform configuration
├── config/
│   └── app_config.dart                # JSON-driven configuration and theming
├── providers/
│   ├── app_provider.dart              # Global app state and alert overlay
│   ├── account_provider.dart          # Account list state (from SDK)
│   ├── push_auth_provider.dart        # Push auth cache, registration, responses
│   └── theme_provider.dart            # Theme mode toggle with persistence
├── router/
│   └── app_router.dart                # GoRouter route definitions
├── screens/
│   ├── home/
│   │   ├── home_screen.dart           # Account list with search
│   │   └── widgets/
│   │       ├── account_list.dart      # Scrollable account list
│   │       ├── account_list_item.dart # Individual account row
│   │       └── search_box.dart        # Search input field
│   ├── account_detail/
│   │   ├── account_detail_screen.dart # Account info and push auth history
│   │   └── widgets/
│   │       ├── account_header.dart    # Avatar, username, organization display
│   │       ├── account_action_menu.dart # Update token/name, delete actions
│   │       ├── push_auth_history_list.dart # History list container
│   │       ├── history_card.dart      # Individual history entry
│   │       └── empty_card.dart        # Empty state placeholder
│   ├── qr_scanner/
│   │   ├── qr_scanner_screen.dart     # Full-screen QR scanning
│   │   └── widgets/
│   │       ├── scan_frame_painter.dart # Custom frame overlay painter
│   │       ├── scan_instructions.dart # Scanning instruction text
│   │       └── scan_back_button.dart  # Back navigation button
│   └── push_auth/
│       ├── push_auth_screen.dart      # Push auth approval/denial UI
│       └── widgets/
│           ├── request_header.dart    # Request info with relative time
│           ├── action_buttons.dart    # Approve/Deny button pair
│           ├── number_button.dart     # Number challenge selection button
│           ├── info_section.dart      # Request metadata display
│           └── security_notice.dart   # Security disclaimer text
├── services/
│   ├── messaging_service.dart         # Platform messaging factory
│   ├── push_messaging_service.dart    # Abstract messaging interface
│   ├── fcm_messaging_service.dart     # Firebase Cloud Messaging implementation
│   └── apns_messaging_service.dart    # Native APNs implementation (iOS)
├── widgets/
│   ├── avatar_widget.dart             # User avatar with initials
│   ├── app_bar_title_widget.dart      # Logo + app name header
│   ├── alert_dialog_widget.dart       # Full-screen alert overlay
│   ├── confirmation_dialog.dart       # Confirmation/input dialog
│   └── info_row_widget.dart           # Label/value display row
├── utils/
│   ├── qr_validator.dart              # QR code JSON validation
│   ├── get_username.dart              # Username extraction from domain/user
│   ├── get_initials.dart              # Initial letter extraction from name
│   ├── avatar_colors.dart             # Deterministic avatar color selection
│   ├── time_from_now.dart             # Relative time formatting
│   └── host_resolver.dart             # Dev mode host URL override
└── constants/
    ├── app_constants.dart             # App title, logo path, dimensions
    ├── storage_keys.dart              # SharedPreferences key constants
    └── screens/
        ├── home.dart                  # Home screen strings and dimensions
        ├── account_detail.dart        # Account detail strings and actions
        ├── qr_scanner.dart            # QR scanner strings
        └── push_auth.dart             # Push auth screen strings
```

### `assets/` Directory

```
assets/
├── config/
│   └── app_config.json                # Application configuration (theme, features, dev mode)
├── certs/
│   └── wso2is.pem                     # Self-signed certificate for local dev server
└── images/
    ├── logo.png                       # Primary app logo
    ├── logo-icon.png                  # App icon (used for launcher icon and splash)
    └── logo-icon-splash-android.png   # Android 12+ splash screen icon
```

---

## 🔄 Application Flow & Architecture

### Initialization Sequence

`main.dart` performs the following steps at app startup:

1. **Preserve splash screen** — `FlutterNativeSplash.preserve()`
2. **Load configuration** — `AppConfig.load()` reads `assets/config/app_config.json`
3. **Initialize Firebase** — `Firebase.initializeApp()` (skipped when using native APNs on iOS)
4. **Register background handler** — `FirebaseMessaging.onBackgroundMessage()` for FCM
5. **Initialize messaging service** — `MessagingService.initialize()` selects FCM or APNs
6. **Set up dev mode HTTP client** — Creates `IOClient` with self-signed certificate trust (if `devMode.enabled`)
7. **Build push auth SDK** — `AsgardeoPushAuthBuilder` configures history limits and HTTP client
8. **Remove splash and run app** — `FlutterNativeSplash.remove()` then `runApp()`

### Notification Handling

`app.dart` sets up notification listeners in `initState()`:

| Listener | Trigger | Behavior |
|----------|---------|----------|
| `listenForeground()` | Notification received while app is open | Parses payload via SDK, caches request, navigates to push auth screen |
| `listenBackgroundTap()` | User taps notification to open app from background | Same as foreground |
| `checkInitialMessage()` | App launched from a notification tap (terminated state) | Same as foreground |
| `pickupPendingNotification()` | App opened after FCM background handler stored payload | Retrieves from SharedPreferences, processes as above |

### Provider Hierarchy

| Provider | Notifier Type | State Type | Key Methods |
|----------|--------------|-----------|-------------|
| `appNotifierProvider` | `Notifier<AppState>` | `AppState` | `showAlert()`, `hideAlert()` |
| `accountNotifierProvider` | `AsyncNotifier<List<PushAuthAccount>>` | `AsyncValue<List<PushAuthAccount>>` | `refresh()` |
| `pushAuthNotifierProvider` | `Notifier<Map<String, PushAuthRequest>>` | `Map<String, PushAuthRequest>` | `addToCache()`, `removeFromCache()`, `registerDevice()`, `sendResponse()`, `unregisterDevice()`, `removeLocalAccount()`, `editDevice()` |
| `themeNotifierProvider` | `Notifier<ThemeMode>` | `ThemeMode` | `toggle()` |

### Storage Architecture

| Storage | Managed By | Data |
|---------|-----------|------|
| iOS Keychain / Android Keystore | SDK (`asgardeo_push_auth`) | RSA private keys |
| `FlutterSecureStorage` | SDK (`asgardeo_push_auth`) | Account metadata, push auth history |
| `SharedPreferences` | App | Theme mode preference, pending FCM background notifications |

---

## 🔧 Key Features Implementation

### Push Authentication

- **Device Registration**: QR code scanned → JSON validated via `qr_validator.dart` → `PushAuthNotifier.registerDevice()` delegates to SDK with device token and push provider
- **Push Provider Selection**: FCM by default; `AmazonSNSPushProvider(AmazonSNSPlatform.apns)` when `useApnsOnIos` is enabled on iOS
- **Auth Response**: `PushAuthNotifier.sendResponse()` sends approve/deny via SDK → request removed from cache
- **Device Management**: Update device name, refresh push token, unregister device — all via SDK methods through `PushAuthNotifier`
- **History**: `AsgardeoPushAuth.instance.getAuthHistory()` fetches records per account, displayed in `PushAuthHistoryList`

### QR Code Scanning

- **Camera Integration**: `MobileScanner` widget with full-screen preview
- **Custom Overlay**: `ScanFramePainter` draws a rounded frame cutout over the camera feed
- **Validation**: `validateQRData()` checks JSON structure and required fields (`deviceId`, `username`, `host`, `challenge`)
- **Flow**: Successful scan → show loading alert → register device → show success → navigate to account detail

### Number Challenge

- **Detection**: Push auth request includes an optional `numberChallenge` field
- **UI**: Three number buttons displayed (correct number + two random alternatives), shuffled randomly
- **Logic**: Selecting the correct number sends an `approved` response; selecting an incorrect number sends a `denied` response
