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

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the list of registered push auth accounts, sourced from the SDK.
class AccountNotifier extends AsyncNotifier<List<PushAuthAccount>> {
  @override
  Future<List<PushAuthAccount>> build() =>
      AsgardeoPushAuth.instance.getAccounts();

  /// Reloads accounts from the SDK store and waits for the rebuild to complete.
  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

/// Provider for [AccountNotifier].
final accountNotifierProvider =
    AsyncNotifierProvider<AccountNotifier, List<PushAuthAccount>>(
  AccountNotifier.new,
);
