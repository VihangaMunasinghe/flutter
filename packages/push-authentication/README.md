<div align="center">
  <img src="./docs/images/logo.png" alt="Asgardeo Logo" width="100" align="center"/>

  <h1 align="center">Asgardeo Push Auth Flutter Package</h1>

  <p align="center">
    <strong>Push-notification-based authentication package for Flutter</strong>
  </p>

  <p align="center">
    A Flutter package for integrating push-notification-based multi-factor authentication with <a href="https://wso2.com/asgardeo/">Asgardeo</a> and <a href="https://is.docs.wso2.com/en/latest">WSO2 Identity Server</a>. Handles device registration, push auth requests, approve/deny responses, and auth history — using RSA-2048 keys stored in platform secure storage.
  </p>

  <p align="center">
    <a href="https://pub.dev/packages/asgardeo_push_auth"><img src="https://img.shields.io/pub/v/asgardeo_push_auth.svg?style=for-the-badge" alt="pub.dev"/></a>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
    <img src="https://img.shields.io/badge/License-Apache%202.0-blue?style=for-the-badge" alt="License"/>
    <img src="https://img.shields.io/badge/Asgardeo-FF6B35?style=for-the-badge" alt="Asgardeo"/>
  </p>
</div>

---

## 📚 Table of Contents

- [Features](#-features)
- [Installation](#-installation)
- [Quick Start](#-quick-start)
- [Configuration](#️-configuration)
  - [Builder Options](#-builder-options)
  - [Custom HTTP Client](#-custom-http-client)
- [Usage](#-usage)
  - [Register Device (QR Code)](#1-register-device-qr-code)
  - [Register Device (Access Token)](#2-register-device-access-token)
  - [Parse Push Notification](#3-parse-push-notification)
  - [Approve or Deny](#4-approve-or-deny)
  - [Update Device](#5-update-device)
  - [Unregister Device](#6-unregister-device)
  - [Remove Local Account](#7-remove-local-account)
  - [List Accounts](#8-list-accounts)
  - [Get Account](#9-get-account)
  - [Auth History](#10-auth-history)
- [Push Providers](#-push-providers)
- [Biometric Policy](#-biometric-policy)
- [Error Handling](#-error-handling)
- [Extensibility](#-extensibility)
- [API Reference](#-api-reference)
- [License](#-license)

---

## ✨ Features

- **Device Registration** — Register devices via QR code scan or OAuth2 access token
- **Push Authentication** — Parse incoming push notifications and send approve/deny responses
- **Number Challenge** — Support for number-matching push authentication flows
- **Device Management** — Update device name, refresh push token, and unregister devices
- **Auth History** — Local tracking of all push authentication events
- **RSA-2048 Signing** — Cryptographic request signing with platform-secure key storage
- **Biometric Gating** — Optional biometric/device-credential authentication before key operations
- **Automatic Retries** — Built-in retry logic with exponential backoff for transient failures
- **Pluggable Architecture** — Replace crypto, storage, HTTP, logging, and device-info implementations

---

## 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  asgardeo_push_auth: <version>
```

Then run:

```bash
flutter pub get
```

---

## 🚀 Quick Start

Initialize the package once at app startup before any other package calls:

```dart
import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  AsgardeoPushAuthBuilder().build();

  runApp(const MyApp());
}
```

Access the singleton anywhere in your app:

```dart
final asgardeoPushAuth = AsgardeoPushAuth.instance;
```

---

## ⚙️ Configuration

### 🔧 Builder Options

Customize the package by setting properties on `AsgardeoPushAuthBuilder` before calling `build()`:

```dart
(AsgardeoPushAuthBuilder()
      ..logLevel = LogLevel.debug
      ..maxHistoryRecords = 50
      ..maxRetries = 2
      ..biometricPolicy = BiometricPolicy.enabled
      ..biometricLocalizedReason = 'Verify your identity')
    .build();
```

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `httpManager` | `AsgardeoHttpManager?` | `HttpClientManager()` | Custom HTTP client for network requests |
| `storageManager` | `AsgardeoStorageManager?` | `SharedPreferencesStorageManager()` | Persistent storage for accounts and history |
| `cryptoEngine` | `AsgardeoCryptoEngine?` | `SecureCryptoEngine()` | RSA key generation and signing engine |
| `deviceInfoProvider` | `AsgardeoDeviceInfoProvider?` | `PlatformDeviceInfoProvider()` | Device name and model provider |
| `logger` | `AsgardeoLogger?` | `DefaultLogger()` | Custom logger implementation |
| `logLevel` | `LogLevel?` | `LogLevel.none` | Log verbosity (`none`, `error`, `info`, `debug`) |
| `biometricPolicy` | `BiometricPolicy` | `BiometricPolicy.enabled` | Biometric gate for private-key operations |
| `biometricLocalizedReason` | `String` | `'Authenticate to confirm this action'` | Text shown in the biometric prompt |
| `maxHistoryRecords` | `int` | `20` | Maximum auth history records per account |
| `maxRetries` | `int` | `1` | Retry attempts for transient network/5xx errors (0 to disable) |

> [!NOTE]
> Calling `build()` more than once without `AsgardeoPushAuth.reset()` throws `AsgardeoAlreadyInitializedException`.

### 🔒 Custom HTTP Client

To connect to a local WSO2 Identity Server with a self-signed certificate:

```dart
import 'dart:io';
import 'package:http/io_client.dart';

final context = SecurityContext(withTrustedRoots: true)
  ..setTrustedCertificatesBytes(certBytes);
final httpClient = IOClient(HttpClient(context: context));

(AsgardeoPushAuthBuilder()
      ..httpManager = HttpClientManager(client: httpClient))
    .build();
```

---

## 📖 Usage

All operations are accessed through the `AsgardeoPushAuth.instance` singleton.

### 1. Register Device (QR Code)

Scan the QR code from the Asgardeo console, then register the device with the raw JSON string and the device's push token:

```dart
try {
  final accountId = await AsgardeoPushAuth.instance.registerDevice(
    qrCodeJson,        // Raw JSON string from QR scan
    deviceToken,       // FCM/APNs push token
    FCMPushProvider(), // Or AmazonSNSPushProvider(AmazonSNSPlatform.fcm)
  );
  print('Registered. Account ID: $accountId');
} on AsgardeoValidationException catch (e) {
  // Invalid QR code data.
} on AsgardeoDeviceAlreadyRegisteredException catch (e) {
  // Account already registered for this user on this device.
} on AsgardeoRegistrationException catch (e) {
  // Server rejected the registration.
} on AsgardeoNetworkException catch (e) {
  // Network error after retries exhausted.
}
```

### 2. Register Device (Access Token)

Register without a QR code by providing an OAuth2 access token. The package fetches the registration payload from the server's discovery-data endpoint:

```dart
try {
  final accountId = await AsgardeoPushAuth.instance.registerDeviceWithToken(
    'https://api.asgardeo.io/t/myorg', // Asgardeo server base URL
    accessToken,                        // OAuth2 Bearer token
    deviceToken,                        // FCM/APNs push token
    AmazonSNSPushProvider(AmazonSNSPlatform.fcm),
  );
  print('Registered. Account ID: $accountId');
} on AsgardeoDeviceAlreadyRegisteredException catch (e) {
  // Account already registered for this user on this device.
} on AsgardeoRegistrationException catch (e) {
  // Registration or discovery-data fetch failed.
} on AsgardeoNetworkException catch (e) {
  // Network error.
}
```

### 3. Parse Push Notification

Convert raw push notification data into a typed `PushAuthRequest`. Returns `null` for non-Asgardeo notifications, making it safe to use in shared handlers:

```dart
final request = AsgardeoPushAuth.instance.parsePushNotification(
  message.data,
  sentTime: message.sentTime?.millisecondsSinceEpoch,
);

if (request != null) {
  print('App: ${request.applicationName}');
  print('User: ${request.username}');
  print('IP: ${request.ipAddress}');
  print('Number challenge: ${request.numberChallenge ?? "none"}');
}
```

### 4. Approve or Deny

Send the user's decision for a pending push authentication request:

```dart
// Approve
try {
  await AsgardeoPushAuth.instance.sendAuthResponse(
    request,
    PushAuthResponseStatus.approved,
    selectedNumber: 42, // Only for number-challenge flows
  );
} on AsgardeoAccountNotFoundException catch (e) {
  // No local account for this device ID.
} on AsgardeoAuthResponseException catch (e) {
  // Server rejected the response.
} on AsgardeoNetworkException catch (e) {
  // Network error.
}

// Deny
await AsgardeoPushAuth.instance.sendAuthResponse(
  request,
  PushAuthResponseStatus.denied,
);
```

### 5. Update Device

Update the device's display name or push token on the server. Call this when the FCM/APNs token is refreshed by the platform:

```dart
// Update push token
try {
  await AsgardeoPushAuth.instance.updateDevice(
    accountId,
    pushToken: newToken,
  );
} on AsgardeoDeviceNotFoundException catch (e) {
  // Device no longer exists on the server.
} on AsgardeoDeviceUpdateException catch (e) {
  // Update failed.
}

// Rename device
await AsgardeoPushAuth.instance.updateDevice(
  accountId,
  name: "Alice's iPhone",
);
```

### 6. Unregister Device

Remove the device from the Asgardeo server and delete all local data (account, keys, history):

```dart
try {
  await AsgardeoPushAuth.instance.unregisterDevice(accountId);
} on AsgardeoDeviceNotFoundException {
  // Device already removed on the server — clean up local data.
  await AsgardeoPushAuth.instance.removeLocalAccount(accountId);
} on AsgardeoUnregistrationException catch (e) {
  // Server rejected the unregistration.
} on AsgardeoNetworkException catch (e) {
  // Network error.
}
```

### 7. Remove Local Account

Delete the local account, key pair, and history without contacting the server. Use when the device was already removed server-side:

```dart
await AsgardeoPushAuth.instance.removeLocalAccount(accountId);
```

### 8. List Accounts

Retrieve all locally registered accounts:

```dart
final accounts = await AsgardeoPushAuth.instance.getAccounts();
for (final account in accounts) {
  print('${account.username} (${account.organizationName ?? account.tenantDomain})');
}
```

### 9. Get Account

Look up a single account by its local ID or server-assigned device ID:

```dart
// By account ID
final account = await AsgardeoPushAuth.instance.getAccount(accountId);

// By device ID
final account = await AsgardeoPushAuth.instance.getAccountByDeviceId(deviceId);
```

### 10. Auth History

Retrieve the push authentication history for a given account:

```dart
final records = await AsgardeoPushAuth.instance.getAuthHistory(accountId);
for (final record in records) {
  print('${record.applicationName} — ${record.status}');
}
```

---

## 📡 Push Providers

The package supports multiple push notification providers. Pass the appropriate provider during device registration.

| Provider | Usage | Description |
|----------|-------|-------------|
| `FCMPushProvider()` | `FCMPushProvider()` | Firebase Cloud Messaging (direct FCM) |
| `AmazonSNSPushProvider` | `AmazonSNSPushProvider(AmazonSNSPlatform.fcm)` | Amazon SNS with FCM as the underlying platform |
| `AmazonSNSPushProvider` | `AmazonSNSPushProvider(AmazonSNSPlatform.apns)` | Amazon SNS with APNs as the underlying platform |
| `CustomPushProvider` | `CustomPushProvider(name: 'MyProvider', metadata: {...})` | Custom push provider for extensibility |

**Example — choosing provider based on platform:**

```dart
import 'dart:io';

final provider = Platform.isIOS
    ? AmazonSNSPushProvider(AmazonSNSPlatform.apns)
    : AmazonSNSPushProvider(AmazonSNSPlatform.fcm);

final accountId = await asgardeoPushAuth.registerDevice(qrCodeJson, deviceToken, provider);
```

---

## 🔐 Biometric Policy

The `BiometricPolicy` enum controls whether biometric/device-credential authentication is required before private-key operations (signing, key generation):

| Policy | Behavior |
|--------|----------|
| `BiometricPolicy.disabled` | No biometric prompt. Operations proceed immediately. |
| `BiometricPolicy.enabled` | Prompts when biometrics are available; skips silently if the device doesn't support it. This is the **default**. |
| `BiometricPolicy.mandatory` | Requires biometric authentication. Throws `AsgardeoBiometricUnavailableException` if the device doesn't support it. |

```dart
(AsgardeoPushAuthBuilder()
      ..biometricPolicy = BiometricPolicy.mandatory
      ..biometricLocalizedReason = 'Authenticate to approve login')
    .build();
```

---

## 🚨 Error Handling

All exceptions extend `AsgardeoException`, which provides `message`, `code`, `traceId`, and `cause` fields.

| Exception | Thrown When |
|-----------|------------|
| `AsgardeoNotInitializedException` | `AsgardeoPushAuth.instance` accessed before `build()` |
| `AsgardeoAlreadyInitializedException` | `build()` called twice without `reset()` |
| `AsgardeoValidationException` | Input validation fails (invalid QR data, empty params) |
| `AsgardeoDeviceAlreadyRegisteredException` | Account already registered for the user on this device |
| `AsgardeoRegistrationException` | Server rejects device registration |
| `AsgardeoAuthResponseException` | Server rejects an approve/deny response |
| `AsgardeoAccountNotFoundException` | No local account found for the given ID |
| `AsgardeoDeviceNotFoundException` | Server reports the device no longer exists |
| `AsgardeoDeviceUpdateException` | Server rejects a device update request |
| `AsgardeoUnregistrationException` | Server rejects device unregistration |
| `AsgardeoNetworkException` | Transport-level failure after retries exhausted |
| `AsgardeoCryptoException` | Cryptographic operation failure |
| `AsgardeoBiometricUnavailableException` | Biometric required but device doesn't support it |
| `AsgardeoBiometricAuthFailedException` | Biometric prompt shown but user cancelled or failed |
| `AsgardeoStorageException` | Local storage read/write failure |

**Example — structured error handling:**

```dart
try {
  await asgardeoPushAuth.registerDevice(qrJson, token, provider);
} on AsgardeoValidationException catch (e) {
  // Client-side validation error.
  print('Invalid input: ${e.message}');
} on AsgardeoDeviceAlreadyRegisteredException catch (e) {
  // Account already exists — prompt user to remove the existing account.
  print('Already registered: ${e.message}');
} on AsgardeoRegistrationException catch (e) {
  // Server error — check e.code and e.traceId for debugging.
  print('Server error [${e.code}]: ${e.message}');
} on AsgardeoNetworkException catch (e) {
  // Network failure.
  print('Network error: ${e.message}');
}
```

---

## 🧩 Extensibility

The package uses abstract interfaces that can be replaced with custom implementations:

| Interface | Default Implementation | Purpose |
|-----------|----------------------|---------|
| `AsgardeoCryptoEngine` | `SecureCryptoEngine` | RSA key pair generation and data signing |
| `AsgardeoStorageManager` | `SharedPreferencesStorageManager` | Persistent storage for accounts and history |
| `AsgardeoHttpManager` | `HttpClientManager` | HTTP GET/POST operations |
| `AsgardeoLogger` | `DefaultLogger` | Package log output |
| `AsgardeoDeviceInfoProvider` | `PlatformDeviceInfoProvider` | Device name and model resolution |

**Example — custom logger:**

```dart
class MyLogger implements AsgardeoLogger {
  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {
    // Send to your crash reporting service.
  }

  @override
  void info(String message) => print('[INFO] $message');

  @override
  void debug(String message) => print('[DEBUG] $message');
}

(AsgardeoPushAuthBuilder()..logger = MyLogger()).build();
```

---

## 📋 API Reference

### Core

| Class | Description |
|-------|-------------|
| `AsgardeoPushAuth` | Singleton facade — entry point for all package operations |
| `AsgardeoPushAuthBuilder` | Builder for constructing and configuring the singleton |

### Models

| Class | Description |
|-------|-------------|
| `PushAuthRequest` | Parsed incoming push authentication request |
| `PushAuthRecord` | Auth history record |
| `PushAuthAccount` | Registered device account |
| `PushAuthResponseStatus` | Enum: `approved`, `denied` |
| `BiometricPolicy` | Enum: `disabled`, `enabled`, `mandatory` |
| `RegistrationPayload` | Parsed QR code registration data |

### Push Providers

| Class | Description |
|-------|-------------|
| `AsgardeoPushNotificationProvider` | Abstract push provider interface |
| `FCMPushProvider` | Firebase Cloud Messaging provider |
| `AmazonSNSPushProvider` | Amazon SNS provider (FCM or APNs platform) |
| `AmazonSNSPlatform` | Enum: `fcm`, `apns` |
| `CustomPushProvider` | User-defined push provider |

### Interfaces

| Class | Description |
|-------|-------------|
| `AsgardeoCryptoEngine` | Abstract crypto operations interface |
| `SecureCryptoEngine` | Software-backed RSA engine (default) |
| `AsgardeoStorageManager` | Abstract persistent storage interface |
| `SharedPreferencesStorageManager` | SharedPreferences-backed storage (default) |
| `AsgardeoHttpManager` | Abstract HTTP operations interface |
| `HttpClientManager` | `http` package-backed HTTP client (default) |
| `AsgardeoLogger` | Abstract logging interface |
| `DefaultLogger` | Console logger with configurable `LogLevel` |
| `AsgardeoDeviceInfoProvider` | Abstract device info interface |
| `PlatformDeviceInfoProvider` | `device_info_plus`-backed provider (default) |

### Exceptions

| Class | Description |
|-------|-------------|
| `AsgardeoException` | Base exception class |
| `AsgardeoNotInitializedException` | Package not initialized |
| `AsgardeoAlreadyInitializedException` | Package already initialized |
| `AsgardeoValidationException` | Input validation failure |
| `AsgardeoRegistrationException` | Device registration failure |
| `AsgardeoAuthResponseException` | Auth response submission failure |
| `AsgardeoAccountNotFoundException` | Local account not found |
| `AsgardeoDeviceNotFoundException` | Device not found on server |
| `AsgardeoDeviceUpdateException` | Device update failure |
| `AsgardeoUnregistrationException` | Device unregistration failure |
| `AsgardeoNetworkException` | Network/transport failure |
| `AsgardeoCryptoException` | Cryptographic operation failure |
| `AsgardeoBiometricUnavailableException` | Biometric hardware unavailable |
| `AsgardeoBiometricAuthFailedException` | Biometric authentication failed/cancelled |
| `AsgardeoStorageException` | Local storage failure |

---

## 📄 License

Copyright 2026 WSO2 LLC. (https://www.wso2.com)

Licensed under the [Apache License, Version 2.0](LICENSE).

---

<div align="center">
  <p>
    <sub>Built with <a href="https://flutter.dev">Flutter</a> by <a href="https://wso2.com">WSO2</a></sub>
  </p>
</div>
