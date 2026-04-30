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

/// Controls how the package gates cryptographic operations behind
/// biometric or device-credential authentication.
enum BiometricPolicy {
  /// No biometric prompt is shown; operations proceed immediately.
  disabled,

  /// Prompts when biometrics are available; skips silently if not.
  ///
  /// Throws `AsgardeoBiometricAuthFailedException` on cancellation or failure.
  ///
  /// This is the default policy.
  enabled,

  /// Requires biometric or device-credential authentication.
  ///
  /// Throws `AsgardeoBiometricUnavailableException` if the device does not
  /// support it, or `AsgardeoBiometricAuthFailedException` on failure.
  mandatory,
}
