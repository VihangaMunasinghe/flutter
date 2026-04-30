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

import 'dart:io';

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:asgardeo_push_authenticator/app.dart';
import 'package:asgardeo_push_authenticator/config/app_config.dart';
import 'package:asgardeo_push_authenticator/firebase_options.dart';
import 'package:asgardeo_push_authenticator/services/fcm_messaging_service.dart';
import 'package:asgardeo_push_authenticator/services/messaging_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/io_client.dart';

/// Top-level FCM background handler.
///
/// Delegates to [fcmBackgroundHandler], which stores the payload in
/// `SharedPreferences` for pickup when the app next launches.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) =>
    fcmBackgroundHandler(message);

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await AppConfig.load();

  if (!(AppConfig.instance.feature.push.useApnsOnIos && Platform.isIOS)) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  
  MessagingService.initialize();

  // In dev mode, set up an HTTP client that trusts the local WSO2 IS instance's
  // self-signed certificate.
  IOClient? httpClient;
  if (AppConfig.instance.devMode.enabled) {
    final certBytes = await rootBundle.load(
      AppConfig.instance.devMode.localServerCertificate
      );
    final context = SecurityContext(withTrustedRoots: true)
      ..setTrustedCertificatesBytes(certBytes.buffer.asUint8List());
    httpClient = IOClient(HttpClient(context: context));
  }

  (AsgardeoPushAuthBuilder()
        ..maxHistoryRecords =
            AppConfig.instance.feature.push.numberOfHistoryRecords
        ..httpManager = HttpClientManager(client: httpClient))
      .build();

  FlutterNativeSplash.remove();
  runApp(const ProviderScope(child: AsgardeoApp()));
}
