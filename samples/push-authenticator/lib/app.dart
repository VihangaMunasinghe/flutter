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

import 'dart:async';

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:asgardeo_push_authenticator/config/app_config.dart';
import 'package:asgardeo_push_authenticator/providers/app_provider.dart';
import 'package:asgardeo_push_authenticator/providers/push_auth_provider.dart';
import 'package:asgardeo_push_authenticator/providers/theme_provider.dart';
import 'package:asgardeo_push_authenticator/router/app_router.dart';
import 'package:asgardeo_push_authenticator/services/messaging_service.dart';
import 'package:asgardeo_push_authenticator/widgets/alert_dialog_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root application widget.
///
/// Sets up GoRouter, theme, messaging listeners, and the global alert overlay.
class AsgardeoApp extends ConsumerStatefulWidget {
  const AsgardeoApp({super.key});

  @override
  ConsumerState<AsgardeoApp> createState() => _AsgardeoAppState();
}

class _AsgardeoAppState extends ConsumerState<AsgardeoApp> {
  late final GoRouter _router;
  void Function()? _cancelForegroundListener;
  void Function()? _cancelBackgroundTapListener;

  @override
  void initState() {
    super.initState();
    _router = buildAppRouter();
    _initPushNotifications();
  }

  @override
  void dispose() {
    _cancelForegroundListener?.call();
    _cancelBackgroundTapListener?.call();
    _router.dispose();
    super.dispose();
  }

  void _initPushNotifications() {
    unawaited(MessagingService.instance.requestPermission());

    _cancelForegroundListener =
        MessagingService.instance.listenForeground(_handleRawNotification);

    _cancelBackgroundTapListener =
        MessagingService.instance.listenBackgroundTap(_handleRawNotification);

    unawaited(
      MessagingService.instance.checkInitialMessage(_handleRawNotification),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final pending =
          await MessagingService.instance.pickupPendingNotification();
      if (pending != null) _handleRawNotification(pending);
    });
  }

  void _handleRawNotification(Map<String, dynamic> data) {
    final request = AsgardeoPushAuth.instance.parsePushNotification(data);
    if (request == null) return;
    ref.read(pushAuthNotifierProvider.notifier).addToCache(request);
    unawaited(_router.push('/push-auth/${request.pushId}'));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);
    final appState = ref.watch(appNotifierProvider);

    final colors = AppConfig.instance.theme;
    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: hexToColor(colors.screenBackground),
      appBarTheme: AppBarTheme(
        backgroundColor: hexToColor(colors.headerBackground),
        foregroundColor: hexToColor(colors.headerText),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: hexToColor(colors.button.primary.background),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: hexToColor(colors.headerBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: hexToColor(colors.headerBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        MaterialApp.router(
          title: AppConfig.instance.appHeaderText,
          theme: lightTheme,
          darkTheme: lightTheme.copyWith(brightness: Brightness.dark),
          themeMode: themeMode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
        if (appState.alertConfig != null)
          Positioned.fill(
            child: AlertDialogWidget(
              type: appState.alertConfig!.type,
              title: appState.alertConfig!.title,
              message: appState.alertConfig!.message,
              primaryButtonText: appState.alertConfig!.primaryButtonText,
              secondaryButtonText: appState.alertConfig!.secondaryButtonText,
              onPrimaryPress: appState.alertConfig!.onPrimaryPress,
              onSecondaryPress: appState.alertConfig!.onSecondaryPress,
              autoDismissTimeout: appState.alertConfig!.autoDismissTimeout,
            ),
          ),
      ],
    );
  }
}
