# ⚙️ Configuration Guide

This guide explains how to configure and customize the Push Authenticator app for your organization's branding and requirements.

---

## 📑 Table of Contents

- [Application Configuration (`app_config.json`)](#-application-configuration-app_configjson)
  - [Configuration Structure](#configuration-structure)
    - [1. App Header Text](#1-app-header-text)
    - [2. Development Mode](#2-development-mode)
    - [3. Security Settings](#3-security-settings)
    - [4. Feature Configuration](#4-feature-configuration)
    - [5. UI Theme Configuration](#5-ui-theme-configuration)
      - [Theme Properties](#theme-properties)
      - [Color Customization](#color-customization)
  - [Customization Example](#customization-example)
- [Splash Screen Configuration](#-splash-screen-configuration)
- [App Icon Configuration](#-app-icon-configuration)
- [Logo and Branding Assets](#-logo-and-branding-assets)

---

## 🔧 Application Configuration (`app_config.json`)

The `assets/config/app_config.json` file contains the core application settings, including UI theming, security options, and feature configurations.

### Configuration Structure

#### 1. **App Header Text**
```json
"appHeaderText": "Authenticator"
```
- Defines the text displayed in the application header
- Change this to your organization's app name

#### 2. **Development Mode**
```json
"devMode": {
  "enabled": false,
  "host": "https://localhost:9443",
  "localServerCertificate": "assets/certs/wso2is.pem"
}
```
- `enabled`: Set to `true` to enable development mode, `false` for production
- `host`: WSO2 Identity Server host URL for development
- `localServerCertificate`: Path to the PEM certificate for the local server

> [!IMPORTANT]
> When `devMode.enabled` is `true`, the application creates a custom HTTP client that trusts the specified certificate, allowing connections to a local WSO2 Identity Server instance with a self-signed certificate. **Disable dev mode in production builds.**

#### 3. **Security Settings**
```json
"security": {
  "enableAppScreenLocks": false
}
```
- `enableAppScreenLocks`: Enables biometric/PIN authentication when accessing the app

#### 4. **Feature Configuration**
```json
"feature": {
  "push": {
    "numberOfHistoryRecords": 5,
    "useApnsOnIos": false
  }
}
```
- `push.numberOfHistoryRecords`: Maximum push authentication history records retained per account (recommended: 5–10)
- `push.useApnsOnIos`: When `true`, uses native Apple Push Notification service (APNs) instead of Firebase Cloud Messaging on iOS. Android always uses FCM regardless of this setting.

> [!NOTE]
> When using native APNs (`useApnsOnIos: true`), you must configure Amazon SNS as the push provider in Asgardeo/WSO2 Identity Server instead of FCM.

#### 5. **UI Theme Configuration**

The theme configuration allows you to customize the entire look and feel of the app.

```json
"ui": {
  "theme": {
    "activeTheme": "light",
    "light": {
      "colors": { /* light theme colors */ }
    }
  }
}
```

##### **Theme Properties:**

- **`activeTheme`**: Set to the name of the active theme (e.g., `"light"`)

##### **Color Customization:**

Each theme contains the following color categories:

**Screen Colors:**
```json
"screen": {
  "background": "#fbfbfb"
}
```
- Main background color for app screens

**Overlay Colors:**
```json
"overlay": {
  "background": "#00000080",
  "text": "#ffffff"
}
```
- Used for modal overlays and full-screen alert backgrounds

**Header Colors:**
```json
"header": {
  "background": "#ffffff",
  "text": "#17181aff",
  "dropdown": {
    "background": "#ffffff"
  }
}
```
- Navigation header and dropdown menu styling

**Button Colors:**
```json
"button": {
  "primary": {
    "background": "#FF7300",
    "text": "#ffffff"
  },
  "secondary": {
    "background": "#f0f1f3ff",
    "text": "#868c99ff"
  }
}
```
- Primary buttons: Main action buttons (use your brand color)
- Secondary buttons: Alternative/cancel actions

**Typography Colors:**
```json
"typography": {
  "primary": "#56585eff",
  "secondary": "#868c99ff"
}
```
- Text colors for primary and secondary content

**Card Colors:**
```json
"card": {
  "background": "#f5f6f9ff",
  "border": "#d1d9e6"
}
```
- Account cards, history cards, and list item styling

**Alert Colors:**
```json
"alert": {
  "error": {
    "background": "#fdebeaff",
    "text": "#F44336"
  },
  "info": {
    "background": "#e5f2fbff",
    "text": "#2196F3"
  },
  "success": {
    "background": "#edf9edff",
    "text": "#4CAF50"
  },
  "loading": {
    "background": "#fafafaff",
    "text": "#181818ff"
  },
  "message": {
    "background": "#ffffffff",
    "text": "#a2a2a2ff"
  },
  "warning": {
    "background": "#fff4e5ff",
    "text": "#FF9800"
  }
}
```
- Alert notification colors for different message types
- Each alert type has background and text color properties
- Used for the full-screen alert overlay throughout the app

**Code Circle Colors:**
```json
"codeCircle": {
  "background": "#f8f8f9",
  "timer": {
    "background": "#e2e3e4ff",
    "validity": {
      "low": "#F44336",
      "medium": "#FF9800",
      "high": "#4CAF50"
    }
  },
  "shadowColor": "#000000",
  "text": "#000000de",
  "subText": "#00000066"
}
```
- Code display circle styling
- `timer.validity` colors indicate time-based status (red = expiring, yellow = medium, green = fresh)

**Avatar Color Palette:**
```json
"avatar": [
  {
    "bg": "#FFB3B3",
    "text": "#B91C1C"
  },
  {
    "bg": "#B3E5FC",
    "text": "#0369A1"
  }
  // ... additional color combinations
]
```
- Array of color combinations for user account avatars
- Each entry contains background (`bg`) and text (`text`) colors
- The app deterministically assigns colors based on the account name, providing consistent visual differentiation between accounts
- Up to 20 color pairs can be configured

**Color Format:**

Colors support both 6-digit and 8-digit hex formats:
- 6-digit: `#FF7300` (RGB, full opacity)
- 8-digit: `#FF7300ff` (RGBA, explicit alpha channel)

### Customization Example

To brand the app for your organization:

```json
{
  "appHeaderText": "MyCompany Push Authenticator",
  "security": {
    "enableAppScreenLocks": true
  },
  "ui": {
    "theme": {
      "activeTheme": "light",
      "light": {
        "colors": {
          "button": {
            "primary": {
              "background": "#0066CC",
              "text": "#ffffff"
            }
          }
        }
      }
    }
  }
}
```

---

## 🚀 Splash Screen Configuration

The splash screen is configured in `pubspec.yaml` under the `flutter_native_splash` key:

```yaml
flutter_native_splash:
  color: "#ffffff"
  image: "assets/images/logo-icon.png"
  android_12:
    color: "#ffffff"
    icon_background_color: "#ffffff"
    image: "assets/images/logo-icon-splash-android.png"
```

| Property | Description |
|----------|-------------|
| `color` | Background color for the splash screen |
| `image` | Path to the splash screen logo/image |
| `android_12.color` | Background color for Android 12+ splash |
| `android_12.icon_background_color` | Icon circle background color on Android 12+ |
| `android_12.image` | Splash image specific to Android 12+ |

> [!IMPORTANT]
> The splash screen does **not support runtime theming** and cannot dynamically change based on the user's selected system theme. The splash screen configuration is static and set during the build process. Use neutral colors like white (`#ffffff`) or light gray that work well regardless of system theme.

After modifying splash screen settings, regenerate with:

```bash
dart run flutter_native_splash:create
```

---

## 🎨 App Icon Configuration

App icons are configured in `pubspec.yaml` under the `flutter_launcher_icons` key:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo-icon.png"
  adaptive_icon_background: "#ffffff"
  adaptive_icon_foreground: "assets/images/logo-icon.png"
  remove_alpha_ios: true
```

| Property | Description |
|----------|-------------|
| `android` / `ios` | Enable icon generation for each platform |
| `image_path` | Path to the source icon image |
| `adaptive_icon_background` | Background color for Android adaptive icons |
| `adaptive_icon_foreground` | Foreground image for Android adaptive icons |
| `remove_alpha_ios` | Remove alpha channel for iOS (required by App Store) |

After modifying icon settings, regenerate with:

```bash
dart run flutter_launcher_icons
```

---

## 🖼️ Logo and Branding Assets

The application uses three logo assets located in `assets/images/`:

| Asset | Purpose |
|-------|---------|
| `logo.png` | Primary logo displayed in the app header |
| `logo-icon.png` | App icon used for launcher icon and default splash screen |
| `logo-icon-splash-android.png` | Splash screen icon specific to Android 12+ |

### Logo Replacement

1. Replace the existing logo files in `assets/images/` with your branded versions
2. Ensure file names match exactly: `logo.png`, `logo-icon.png`, and `logo-icon-splash-android.png`
3. Regenerate launcher icons and splash screen:
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```
4. Update `appHeaderText` in `assets/config/app_config.json` to match your branding
