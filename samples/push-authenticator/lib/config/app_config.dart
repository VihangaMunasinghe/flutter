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

import 'dart:convert';

import 'package:flutter/services.dart';

/// A background/text color pair for avatar display.
class AvatarColorPair {
  const AvatarColorPair({required this.bg, required this.text});

  factory AvatarColorPair.fromJson(Map<String, dynamic> json) =>
      AvatarColorPair(
        bg: json['bg'] as String,
        text: json['text'] as String,
      );

  final String bg;
  final String text;
}

/// Developer mode configuration — allows overriding the server host.
class DevModeConfig {
  const DevModeConfig({
    required this.enabled, 
    required this.host, 
    required this.localServerCertificate
    });

  factory DevModeConfig.fromJson(Map<String, dynamic> json) => DevModeConfig(
        enabled: json['enabled'] as bool? ?? false,
        host: json['host'] as String? ?? '',
        localServerCertificate: json['localServerCertificate'] as String? ?? '',
      );

  final bool enabled;
  final String host;
  final String localServerCertificate;
}

/// Push feature configuration loaded from [assets/config/app_config.json].
class PushFeatureConfig {
  const PushFeatureConfig({
    required this.numberOfHistoryRecords,
    required this.useApnsOnIos,
  });

  factory PushFeatureConfig.fromJson(Map<String, dynamic> json) =>
      PushFeatureConfig(
        numberOfHistoryRecords: json['numberOfHistoryRecords'] as int? ?? 5,
        useApnsOnIos: json['useApnsOnIos'] as bool? ?? false,
      );

  /// Maximum number of push auth history records to retain per account.
  final int numberOfHistoryRecords;

  /// When `true`, uses native APNS on iOS instead of Firebase Cloud Messaging.
  /// Android always uses FCM regardless of this setting.
  final bool useApnsOnIos;
}

/// Feature flags loaded from [assets/config/app_config.json].
class FeatureConfig {
  const FeatureConfig({required this.push});

  factory FeatureConfig.fromJson(Map<String, dynamic> json) => FeatureConfig(
        push: PushFeatureConfig.fromJson(
            json['push'] as Map<String, dynamic>? ?? {}),
      );

  final PushFeatureConfig push;
}

/// Background/text color pair for a specific alert type.
class AlertTypeColors {
  const AlertTypeColors({required this.background, required this.text});

  factory AlertTypeColors.fromJson(Map<String, dynamic> json) =>
      AlertTypeColors(
        background: json['background'] as String,
        text: json['text'] as String,
      );

  final String background;
  final String text;
}

/// Alert color palette grouped by alert type.
class AlertColors {
  const AlertColors({
    required this.error,
    required this.info,
    required this.success,
    required this.loading,
    required this.message,
    required this.warning,
  });

  factory AlertColors.fromJson(Map<String, dynamic> json) => AlertColors(
        error: AlertTypeColors.fromJson(
            json['error'] as Map<String, dynamic>),
        info: AlertTypeColors.fromJson(json['info'] as Map<String, dynamic>),
        success: AlertTypeColors.fromJson(
            json['success'] as Map<String, dynamic>),
        loading: AlertTypeColors.fromJson(
            json['loading'] as Map<String, dynamic>),
        message: AlertTypeColors.fromJson(
            json['message'] as Map<String, dynamic>),
        warning: AlertTypeColors.fromJson(
            json['warning'] as Map<String, dynamic>),
      );

  final AlertTypeColors error;
  final AlertTypeColors info;
  final AlertTypeColors success;
  final AlertTypeColors loading;
  final AlertTypeColors message;
  final AlertTypeColors warning;
}

/// Validity-state color set for the TOTP timer ring.
class TimerValidityColors {
  const TimerValidityColors(
      {required this.low, required this.medium, required this.high});

  factory TimerValidityColors.fromJson(Map<String, dynamic> json) =>
      TimerValidityColors(
        low: json['low'] as String,
        medium: json['medium'] as String,
        high: json['high'] as String,
      );

  final String low;
  final String medium;
  final String high;
}

/// Code-circle timer colors.
class CodeCircleTimer {
  const CodeCircleTimer({required this.background, required this.validity});

  factory CodeCircleTimer.fromJson(Map<String, dynamic> json) =>
      CodeCircleTimer(
        background: json['background'] as String,
        validity: TimerValidityColors.fromJson(
            json['validity'] as Map<String, dynamic>),
      );

  final String background;
  final TimerValidityColors validity;
}

/// Code-circle widget color configuration.
class CodeCircleColors {
  const CodeCircleColors({
    required this.background,
    required this.timer,
    required this.shadowColor,
    required this.text,
    required this.subText,
  });

  factory CodeCircleColors.fromJson(Map<String, dynamic> json) =>
      CodeCircleColors(
        background: json['background'] as String,
        timer:
            CodeCircleTimer.fromJson(json['timer'] as Map<String, dynamic>),
        shadowColor: json['shadowColor'] as String,
        text: json['text'] as String,
        subText: json['subText'] as String,
      );

  final String background;
  final CodeCircleTimer timer;
  final String shadowColor;
  final String text;
  final String subText;
}

/// Background/text pair for a single button variant.
class ButtonVariantColors {
  const ButtonVariantColors({required this.background, required this.text});

  factory ButtonVariantColors.fromJson(Map<String, dynamic> json) =>
      ButtonVariantColors(
        background: json['background'] as String,
        text: json['text'] as String,
      );

  final String background;
  final String text;
}

/// Button color configuration.
class ButtonColors {
  const ButtonColors({required this.primary, required this.secondary});

  factory ButtonColors.fromJson(Map<String, dynamic> json) => ButtonColors(
        primary: ButtonVariantColors.fromJson(
            json['primary'] as Map<String, dynamic>),
        secondary: ButtonVariantColors.fromJson(
            json['secondary'] as Map<String, dynamic>),
      );

  final ButtonVariantColors primary;
  final ButtonVariantColors secondary;
}

/// Full theme color palette for the current active theme.
class ThemeColors {
  const ThemeColors({
    required this.screenBackground,
    required this.alert,
    required this.codeCircle,
    required this.avatar,
    required this.button,
    required this.primaryText,
    required this.secondaryText,
    required this.cardBackground,
    required this.cardBorder,
    required this.headerBackground,
    required this.headerText,
  });

  factory ThemeColors.fromJson(Map<String, dynamic> json) {
    final avatarList =
        (json['avatar'] as List<dynamic>? ?? [])
            .map((e) =>
                AvatarColorPair.fromJson(e as Map<String, dynamic>))
            .toList();
    return ThemeColors(
      screenBackground:
          (json['screen'] as Map<String, dynamic>?)?['background']
                  as String? ??
              '#fbfbfb',
      alert:
          AlertColors.fromJson(json['alert'] as Map<String, dynamic>),
      codeCircle: CodeCircleColors.fromJson(
          json['codeCircle'] as Map<String, dynamic>),
      avatar: avatarList,
      button:
          ButtonColors.fromJson(json['button'] as Map<String, dynamic>),
      primaryText:
          (json['typography'] as Map<String, dynamic>?)?['primary']
                  as String? ??
              '#000000',
      secondaryText:
          (json['typography'] as Map<String, dynamic>?)?['secondary']
                  as String? ??
              '#666666',
      cardBackground:
          (json['card'] as Map<String, dynamic>?)?['background']
                  as String? ??
              '#ffffff',
      cardBorder:
          (json['card'] as Map<String, dynamic>?)?['border'] as String? ??
              '#cccccc',
      headerBackground:
          (json['header'] as Map<String, dynamic>?)?['background']
                  as String? ??
              '#ffffff',
      headerText:
          (json['header'] as Map<String, dynamic>?)?['text'] as String? ??
              '#000000',
    );
  }

  final String screenBackground;
  final AlertColors alert;
  final CodeCircleColors codeCircle;
  final List<AvatarColorPair> avatar;
  final ButtonColors button;
  final String primaryText;
  final String secondaryText;
  final String cardBackground;
  final String cardBorder;
  final String headerBackground;
  final String headerText;
}

/// Application configuration loaded from [assets/config/app_config.json].
///
/// Call [AppConfig.load] once at startup before accessing [AppConfig.instance].
class AppConfig {
  const AppConfig({
    required this.appHeaderText,
    required this.devMode,
    required this.feature,
    required this.theme,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final ui = json['ui'] as Map<String, dynamic>? ?? {};
    final themeMap = ui['theme'] as Map<String, dynamic>? ?? {};
    final activeTheme = themeMap['activeTheme'] as String? ?? 'light';
    final themeData = themeMap[activeTheme] as Map<String, dynamic>? ?? {};
    final colorsData = themeData['colors'] as Map<String, dynamic>? ?? {};

    return AppConfig(
      appHeaderText: json['appHeaderText'] as String? ?? 'Authenticator',
      devMode: DevModeConfig.fromJson(
          json['devMode'] as Map<String, dynamic>? ?? {}),
      feature: FeatureConfig.fromJson(
          json['feature'] as Map<String, dynamic>? ?? {}),
      theme: ThemeColors.fromJson(colorsData),
    );
  }

  static AppConfig? _instance;

  /// Returns the loaded configuration.
  ///
  /// Throws a [StateError] if [load] has not been called first.
  static AppConfig get instance {
    if (_instance == null) {
      throw StateError('AppConfig not loaded. Call AppConfig.load() first.');
    }
    return _instance!;
  }

  /// Loads [assets/config/app_config.json] and initialises [instance].
  static Future<void> load() async {
    final jsonStr =
        await rootBundle.loadString('assets/config/app_config.json');
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    _instance = AppConfig.fromJson(map);
  }

  final String appHeaderText;
  final DevModeConfig devMode;
  final FeatureConfig feature;
  final ThemeColors theme;
}

/// Parses a CSS hex color string (e.g. `#FF7300` or `#FF7300ff`) into a
/// Flutter [Color].
Color hexToColor(String hex) {
  final cleanHex = hex.replaceAll('#', '');
  if (cleanHex.length == 6) {
    return Color(int.parse('FF$cleanHex', radix: 16));
  } else if (cleanHex.length == 8) {
    // RRGGBBAA → AARRGGBB for Flutter Color.
    final r = cleanHex.substring(0, 2);
    final g = cleanHex.substring(2, 4);
    final b = cleanHex.substring(4, 6);
    final a = cleanHex.substring(6, 8);
    return Color(int.parse('$a$r$g$b', radix: 16));
  }
  return const Color(0xFF000000);
}
