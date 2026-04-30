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

import 'package:asgardeo_push_authenticator/screens/account_detail/account_detail_screen.dart';
import 'package:asgardeo_push_authenticator/screens/home/home_screen.dart';
import 'package:asgardeo_push_authenticator/screens/push_auth/push_auth_screen.dart';
import 'package:asgardeo_push_authenticator/screens/qr_scanner/qr_scanner_screen.dart';
import 'package:go_router/go_router.dart';

/// Builds the [GoRouter] for the app.
GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'account/:id',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return AccountDetailScreen(accountId: id);
            },
          ),
          GoRoute(
            path: 'qr-scanner',
            builder: (context, state) => const QrScannerScreen(),
          ),
          GoRoute(
            path: 'push-auth/:pushId',
            builder: (context, state) {
              final pushId = state.pathParameters['pushId']!;
              return PushAuthScreen(pushId: pushId);
            },
          ),
        ],
      ),
    ],
  );
}
