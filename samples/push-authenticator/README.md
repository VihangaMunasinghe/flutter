<div align="center">
  <img src="./docs/images/logo.png" alt="Asgardeo Logo" width="100" align="center"/>

  <h1 align="center">Asgardeo Push Authenticator</h1>

  <p align="center">
    <strong>Flutter Mobile Application for Push-Based Authentication</strong>
  </p>

  <p align="center">
    A reference mobile push authenticator application built with Flutter and <a href="https://wso2.com/asgardeo/">Asgardeo</a>/<a href="https://is.docs.wso2.com/en/latest">WSO2 Identity Server</a> that enables push notification based authentication on iOS and Android devices.
  </p>

  <p align="center">
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
    <img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart"/>
    <img src="https://img.shields.io/badge/Asgardeo-FF6B35?style=for-the-badge" alt="Asgardeo"/>
  </p>
</div>

---

## 📚 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
  - [Tested Platform Versions](#-tested-platform-versions)
  - [Prerequisites](#-prerequisites)
  - [Initial Setup](#-initial-setup)
  - [Configuration](#️-configuration)
    - [Firebase Cloud Messaging (FCM) Setup](#-firebase-cloud-messaging-fcm-setup)
    - [Apple Developer Account Setup](#-apple-developer-account-setup)
  - [Run the Application](#️-run-the-application)
    - [Update Bundle ID](#️-update-bundle-id)
    - [Android Setup](#-android-setup)
    - [iOS Setup](#-ios-setup)
    - [Useful Commands](#-useful-commands)
  - [Production Build](#-production-build)
- [Application Configuration and Theming](#️-application-configuration-and-theming)
- [Architecture](#️-architecture)

---

## ✨ Features

🔐 **Core Features**
- **Easy Account Setup** — Seamless device registration using the in-app QR scanner
- **Multi-State Push Notifications** — Push notification delivery across foreground, background, and terminated app states
- **Number Challenge Support** — Advanced push authentication with number challenge prompts
- **Push Login History** — Complete tracking and history of all push authentication activities
- **Push Device Management** — Device renaming, token refresh, and unregistration
- **Dual Push Provider Support** — Choose between Firebase Cloud Messaging (FCM) and native Apple Push Notification service (APNs) on iOS

🛡️ **Security Features**
- **Secure Key Storage** — RSA-2048 key pairs stored securely in iOS Keychain and Android Keystore
- **Biometric Authentication** — Device biometric/credential authentication for app access control
- **Push Authentication Controls** — Secure push approval and denial mechanisms
- **Account Deletion** — Complete account removal with secure data cleanup

## 🚀 Quick Start

Get the Asgardeo Push Authenticator app up and running in minutes.

> [!NOTE]
> - **Android**: Push notifications work on both physical devices and emulators.
> - **iOS**: A physical device is required for push notifications. APNs does not work on the iOS Simulator.
> - **Biometrics**: Biometric authentication features require physical device hardware on both platforms.

### 📱 Tested Platform Versions

| Platform | Version | Build Name |
|----------|---------|------------|
| Android  | 16      | Baklava    |
| iOS      | 26.3    | —          |

### 📋 Prerequisites

- **Flutter SDK** (version 3.11 or higher) — [Install Flutter](https://docs.flutter.dev/get-started/install)
- **Android Studio** — for Android development and emulator management
- **Xcode** (macOS only) — for iOS development, required for signing and running on iOS devices
- **CocoaPods** (macOS only) — `sudo gem install cocoapods`
- **Physical iOS device** — required for testing push notifications on iOS

### 📥 Initial Setup

**Clone and install dependencies**

```bash
git clone <REPO_URL>
cd asgardeo-flutter-samples
flutter pub get
```

### ⚙️ Configuration

Push notifications are essential for the push authenticator app functionality. Complete the following configuration steps before running the application.

#### 🔥 Firebase Cloud Messaging (FCM) Setup

> [!TIP]
> Official Documentation: [Firebase Setup Guide](https://firebase.google.com/docs/cloud-messaging)

##### Step 1: Create Firebase Project

1. Navigate to [Firebase Console](https://console.firebase.google.com/)
2. Click **Add project** or select an existing project
3. Follow the setup wizard to create your project

##### Step 2: Configure Firebase Apps

**For Android:**

1. In Firebase Console, go to **Project Settings** (gear icon)
2. Under **Your apps**, click **Add app** > Select **Android** icon
3. Register your app with your package name (e.g., `com.yourcompany.authenticator`)
4. Download the `google-services.json` file
5. Place it in `android/app/`

> [!TIP]
> Official Guide: [Add Firebase to Android](https://firebase.google.com/docs/android/setup)

**For iOS:**

1. In Firebase Console, go to **Project Settings**
2. Under **Your apps**, click **Add app** > Select **iOS** icon
3. Register your app with your Bundle ID (e.g., `com.yourcompany.authenticator`)
4. Download the `GoogleService-Info.plist` file
5. Place it in `ios/Runner/`

> [!TIP]
> Official Guide: [Add Firebase to iOS](https://firebase.google.com/docs/ios/setup)

##### Step 3: Upload APNs Authentication Key to Firebase

For iOS push notifications to work through FCM, you need to upload your Apple Push Notification service (APNs) authentication key to Firebase.

1. In Firebase Console, go to **Project Settings** > **Cloud Messaging** tab
2. Scroll to **Apple app configuration** section
3. Upload your **APNs Authentication Key** (`.p8` file) — see [Apple Developer Setup](#-apple-developer-account-setup) below
4. Enter your **Key ID** and **Team ID**

> [!TIP]
> Official Guide: [Set up APNs with FCM](https://firebase.google.com/docs/cloud-messaging/ios/certs)

##### Step 4: Configure Asgardeo/WSO2 Identity Server Push Provider

1. Download the Firebase service account JSON file:
   - In Firebase Console, go to **Project Settings** > **Service accounts**
   - Click **Generate new private key**
   - Download the `service-account.json` file

2. Configure push provider in Asgardeo/WSO2 Identity Server:
   - Navigate to your Asgardeo/WSO2 Identity Server organization
   - Add the `service-account.json` to push provider configuration

> [!TIP]
> Official Guide: Configure Push Provider in [Asgardeo](https://wso2.com/asgardeo/docs/guides/notification-channels/configure-push-provider/) / [WSO2 Identity Server](https://is.docs.wso2.com/en/latest/guides/notification-channels/configure-push-provider/)

##### Configuration Files Structure

Ensure your project has the following Firebase configuration files:

```
android/
└── app/
    └── google-services.json         # Firebase Android config

ios/
└── Runner/
    └── GoogleService-Info.plist     # Firebase iOS config
```

##### Using Native APNs on iOS (Optional)

This application supports using native APNs instead of FCM on iOS. To enable this, update `assets/config/app_config.json`:

```json
{
  "feature": {
    "push": {
      "useApnsOnIos": true
    }
  }
}
```

When `useApnsOnIos` is `true`, Firebase is not initialized on iOS and the app communicates directly through APNs. Android always uses FCM regardless of this setting.

> [!NOTE]
> When using native APNs, you must configure Amazon SNS as the push provider in Asgardeo/WSO2 Identity Server instead of FCM.

#### 🍎 Apple Developer Account Setup

> [!TIP]
> Official Documentation: [Apple Developer Program](https://developer.apple.com/programs/)

Push notifications on iOS require proper Apple Developer account configuration.

##### Step 1: Create App ID with Push Notifications

1. Sign in to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click on **Identifiers** > **+** (Add button)
4. Select **App IDs** > **Continue**
5. Select **App** > **Continue**
6. Configure your App ID:
   - **Description**: Enter a description (e.g., "Asgardeo Push Authenticator")
   - **Bundle ID**: Enter your Bundle ID (e.g., `com.yourcompany.authenticator`)
   - **Capabilities**: Check **Push Notifications**
7. Click **Continue** > **Register**

> [!TIP]
> Official Guide: [Register an App ID](https://developer.apple.com/help/account/manage-identifiers/register-an-app-id/)

##### Step 2: Register Your Device

1. In Apple Developer Portal, go to **Devices**
2. Click **+** (Add button)
3. Enter **Device Name** and **Device UDID**
   - To find UDID: Connect device > Open Finder/iTunes > Click on device > Click on serial number to reveal UDID
4. Click **Continue** > **Register**

> [!TIP]
> Official Guide: [Register a Device](https://developer.apple.com/help/account/register-devices/register-a-single-device/)

##### Step 3: Create Provisioning Profile

1. In Apple Developer Portal, go to **Profiles**
2. Click **+** (Add button)
3. Select **iOS App Development** > **Continue**
4. Select your **App ID** > **Continue**
5. Select your **Certificate** > **Continue**
6. Select your **Devices** > **Continue**
7. Enter **Provisioning Profile Name** > **Generate**
8. **Download** the provisioning profile (`.mobileprovision` file)
9. **Install** the provisioning profile on your Mac:
   - Double-click the downloaded `.mobileprovision` file, or
   - Drag and drop it into Xcode

> [!TIP]
> Official Guide: [Create a Provisioning Profile](https://developer.apple.com/help/account/provisioning-profiles/create-a-development-provisioning-profile)

##### Step 4: Generate APNs Authentication Key

This key is needed for Firebase Cloud Messaging to send push notifications to iOS devices.

1. In Apple Developer Portal, go to **Keys**
2. Click **+** (Add button)
3. Enter **Key Name** (e.g., "FCM Push Notifications")
4. Check **Apple Push Notifications service (APNs)**
5. Click **Continue** > **Register**
6. **Download** the `.p8` key file (you can only download it once!)
7. Note down the **Key ID** and **Team ID** (found in top-right corner)

> [!TIP]
> Official Guide: [Create APNs Authentication Key](https://developer.apple.com/help/account/keys/create-a-private-key)

##### Step 5: Upload APNs Key to Firebase

1. Go back to [Firebase Console](#step-3-upload-apns-authentication-key-to-firebase)
2. Upload the `.p8` file along with **Key ID** and **Team ID**

> [!IMPORTANT]
> Keep your `.p8` file secure! You cannot download it again from Apple Developer Portal.

### ▶️ Run the Application

Before running the app, update the bundle identifiers to match your Firebase and Apple Developer configurations.

#### 🏷️ Update Bundle ID

**Android** — Edit `android/app/build.gradle.kts` and update the `applicationId`:

```kotlin
android {
    defaultConfig {
        applicationId = "com.yourcompany.authenticator"
    }
}
```

**iOS** — Open `ios/Runner.xcworkspace` in Xcode:

1. Select the **Runner** target
2. Go to the **Signing & Capabilities** tab
3. Update the **Bundle Identifier** (e.g., `com.yourcompany.authenticator`)
4. Select your **Team** and **Provisioning Profile**

> [!IMPORTANT]
> - The **iOS Bundle Identifier** must match the Bundle ID configured in [Apple Developer Portal](#step-1-create-app-id-with-push-notifications)
> - The **Android applicationId** must match the package name configured in [Firebase Console](#step-2-configure-firebase-apps)

#### 🤖 Android Setup

**Option A: Physical Device**

1. On your Android device, enable **Developer Options**:
   - Go to **Settings** > **About Phone**
   - Tap **Build Number** 7 times until you see "You are now a developer!"
2. Enable **USB Debugging**:
   - Go to **Settings** > **Developer Options**
   - Toggle on **USB Debugging**
3. Connect your device to your computer via USB
4. When prompted on the device, tap **Allow** to trust the computer
5. Verify the device is detected:
   ```bash
   flutter devices
   ```
6. Run the application:
   ```bash
   flutter run -d <device-id>
   ```

**Option B: Android Emulator**

1. Open **Android Studio** > **Virtual Device Manager** (or **Tools** > **Device Manager**)
2. Click **Create Virtual Device**
3. Select a device definition and a system image with **Google Play Services** (required for FCM)
4. Launch the emulator
5. Run the application:
   ```bash
   flutter run -d <emulator-id>
   ```

> [!TIP]
> For detailed Android setup instructions, see the [Flutter Android Setup Guide](https://docs.flutter.dev/get-started/install).

#### 🍎 iOS Setup

> [!NOTE]
> iOS development requires macOS with Xcode installed. Push notifications require a physical iOS device — the iOS Simulator does not support APNs.

1. **Install iOS dependencies**:
   ```bash
   cd ios && pod install && cd ..
   ```

2. **Open the project in Xcode**:
   ```bash
   open ios/Runner.xcworkspace
   ```

   > [!IMPORTANT]
   > Always open `Runner.xcworkspace` (not `Runner.xcodeproj`) to ensure CocoaPods dependencies are included.

3. **Configure code signing**:
   - Select the **Runner** target in the project navigator
   - Go to the **Signing & Capabilities** tab
   - Select your **Team** from the dropdown
   - Set the **Bundle Identifier** to match your [Apple Developer Portal](#step-1-create-app-id-with-push-notifications) and [Firebase](#step-2-configure-firebase-apps) configuration
   - Ensure the **Push Notifications** capability is listed (if not, click **+ Capability** and add it)

4. **Connect your physical iOS device** via USB

5. **Trust the developer certificate** on your device:
   - On the iOS device, go to **Settings** > **General** > **VPN & Device Management**
   - Under **Developer App**, tap your developer profile
   - Tap **Trust** and confirm

6. **Run the application**:
   - Select your connected device from the device dropdown in the Xcode toolbar
   - Click the **Run** button (or press `Cmd + R`)
   - Alternatively, use the Flutter CLI:
     ```bash
     flutter run -d <device-id>
     ```

> [!TIP]
> For detailed iOS setup instructions, see the [Flutter iOS Setup Guide](https://docs.flutter.dev/get-started/install/macos/mobile-ios).

#### 💻 Useful Commands

```bash
# List all connected devices and emulators
flutter devices

# Run on a specific device (use the device ID from `flutter devices`)
flutter run -d <device-id>

# Run on the first available device
flutter run
```

### 🏆 Production Build

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (requires Xcode and valid signing configuration)
flutter build ios --release
```

> [!TIP]
> See the [Flutter deployment documentation](https://docs.flutter.dev/deployment) for detailed production build and release instructions.

## ⚒️ Application Configuration and Theming

The application is configured through `assets/config/app_config.json`. This file controls feature flags, developer mode settings, and the complete UI theme.

```json
{
  "appHeaderText": "Authenticator",
  "devMode": {
    "enabled": false,
    "host": "https://localhost:9443",
    "localServerCertificate": "assets/certs/wso2is.pem"
  },
  "feature": {
    "push": {
      "numberOfHistoryRecords": 5,
      "useApnsOnIos": false
    }
  },
  "ui": {
    "theme": {
      "activeTheme": "light",
      "light": {
        "colors": { ... }
      }
    }
  }
}
```

| Key | Description |
|-----|-------------|
| `appHeaderText` | Application title displayed in the header |
| `devMode.enabled` | Enables developer mode with self-signed certificate support |
| `devMode.host` | Local WSO2 Identity Server host URL |
| `devMode.localServerCertificate` | Path to the PEM certificate for the local server |
| `feature.push.numberOfHistoryRecords` | Maximum push auth history records retained per account |
| `feature.push.useApnsOnIos` | Use native APNs instead of FCM on iOS |
| `ui.theme.activeTheme` | Active theme name (e.g., `light`) |
| `ui.theme.<name>.colors` | Complete color palette for the theme |

> [!TIP]
> When `devMode.enabled` is `true`, the application trusts the specified certificate, allowing connections to a local WSO2 Identity Server instance with a self-signed certificate.

For detailed configuration and theming documentation, refer to the [configuration guide](./docs/CONFIGURATION.md).

## 🏗️ Architecture

This application follows a layered architecture using [Riverpod](https://riverpod.dev/) for state management and [GoRouter](https://pub.dev/packages/go_router) for navigation.

```
lib/
├── main.dart                  # App entry point and initialization
├── app.dart                   # Root widget, router, and messaging setup
├── config/
│   └── app_config.dart        # JSON-driven configuration and theming
├── providers/
│   ├── push_auth_provider.dart    # Push auth state (cache, register, respond)
│   ├── account_provider.dart      # Account list state
│   ├── app_provider.dart          # Global app state (alerts, loading)
│   └── theme_provider.dart        # Theme mode state
├── services/
│   ├── messaging_service.dart     # Platform messaging resolver (FCM / APNs)
│   ├── fcm_messaging_service.dart # Firebase Cloud Messaging implementation
│   └── apns_messaging_service.dart# Native APNs implementation
├── router/
│   └── app_router.dart        # GoRouter route definitions
├── screens/                   # Screen widgets
└── widgets/                   # Reusable UI components
```

The application uses the [`asgardeo_push_auth`](<PACKAGE_REPO_URL>) Flutter SDK to handle all push authentication operations including device registration, challenge signing, and auth response submission.

For detailed architecture and codebase documentation, refer to the [architecture](./docs/ARCHITECTURE.md) and [codebase](./docs/CODE.md) guides.

---

## License

This project is licensed under the Apache License 2.0 — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  <p>
    <sub>Built with <a href="https://flutter.dev">Flutter</a> by <a href="https://wso2.com">WSO2</a></sub>
  </p>
</div>
