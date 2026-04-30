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

import 'package:local_auth/local_auth.dart';

/// Internal service that wraps `local_auth` for biometric availability
/// checks and user prompts.
class BiometricService {

  /// Creates a [BiometricService].
  ///
  /// An optional [auth] instance can be provided for testing.
  BiometricService({LocalAuthentication? auth})
      : _auth = auth ?? LocalAuthentication();

  final LocalAuthentication _auth;

  /// Returns `true` if the device supports biometric or device-credential
  /// (PIN / pattern / password) authentication.
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on Object {
      return false;
    }
  }

  /// Prompts the user with a biometric or device-credential dialog.
  ///
  /// Returns `true` if authentication succeeded, `false` if the user
  /// cancelled or failed.
  Future<bool> authenticate(String localizedReason) async {
    return _auth.authenticate(
      localizedReason: localizedReason,
      persistAcrossBackgrounding: true,
    );
  }
}
