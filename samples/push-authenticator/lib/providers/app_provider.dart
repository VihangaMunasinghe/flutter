// Copyright (c) 2026, WSO2 LLC. (https://www.wso2.com).
//
// WSO2 LLC. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App-level authentication status.
enum AppAuthenticationStatus { pending, authenticated, unauthenticated }

/// Alert type used to select the icon and color scheme in the alert overlay.
enum AlertType { success, error, info, loading, warning, message }

/// Configuration for the global alert overlay.
class AlertConfig {
  const AlertConfig({
    required this.type,
    required this.title,
    required this.message,
    this.primaryButtonText,
    this.secondaryButtonText,
    this.onPrimaryPress,
    this.onSecondaryPress,
    this.autoDismissTimeout,
  });

  final AlertType type;
  final String title;
  final String message;
  final String? primaryButtonText;
  final String? secondaryButtonText;
  final void Function()? onPrimaryPress;
  final void Function()? onSecondaryPress;

  /// If set, the alert is automatically dismissed after this many milliseconds.
  final int? autoDismissTimeout;
}

/// Immutable global app state holding the authentication status and an
/// optional alert overlay configuration.
class AppState {
  const AppState({
    required this.authStatus,
    this.alertConfig,
  });

  final AppAuthenticationStatus authStatus;
  final AlertConfig? alertConfig;

  AppState copyWith({
    AppAuthenticationStatus? authStatus,
    AlertConfig? Function()? alertConfig,
  }) =>
      AppState(
        authStatus: authStatus ?? this.authStatus,
        alertConfig:
            alertConfig != null ? alertConfig() : this.alertConfig,
      );
}

/// Manages global app authentication state and the alert overlay.
///
/// The app starts in the [AppAuthenticationStatus.authenticated] state.
/// Biometric authentication is handled at the SDK level during each
/// cryptographic operation.
class AppNotifier extends Notifier<AppState> {
  @override
  AppState build() =>
      const AppState(authStatus: AppAuthenticationStatus.authenticated);

  /// Shows a full-screen alert overlay with [config].
  void showAlert(AlertConfig config) {
    state = state.copyWith(alertConfig: () => config);
  }

  /// Hides the currently visible alert overlay.
  void hideAlert() {
    state = state.copyWith(alertConfig: () => null);
  }
}

/// Riverpod provider for [AppNotifier].
final appNotifierProvider = NotifierProvider<AppNotifier, AppState>(
  AppNotifier.new,
);
