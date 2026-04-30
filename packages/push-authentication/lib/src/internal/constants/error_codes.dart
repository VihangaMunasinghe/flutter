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

/// SDK-internal error codes and messages.
///
/// Each value carries a unique code prefixed with `ASGPA-` and a
/// human-readable message template. Server error codes are
/// separate and come directly from server responses.
enum AsgardeoPushAuthErrorCode {

  // Initialization errors.

  /// SDK accessed before initialization.
  notInitialized(
    'ASGPA-1001',
    'SDK has not been initialized. '
        'Call AsgardeoPushAuthBuilder().build() first.',
  ),

  /// `build()` called more than once without `reset()`.
  alreadyInitialized(
    'ASGPA-1002',
    'SDK is already initialized. '
        'Call AsgardeoPushAuth.reset() before re-initializing.',
  ),

  // Validation errors.

  /// QR payload missing a required field.
  missingQrField(
    'ASGPA-2001',
    'QR payload is missing required field "%s".',
  ),

  /// Push auth request missing `pushId`.
  missingPushId(
    'ASGPA-2002',
    'Push authentication request is missing "pushId".',
  ),

  /// Push auth request missing `challenge`.
  missingChallenge(
    'ASGPA-2003',
    'Push authentication request is missing "challenge".',
  ),

  /// Push auth request missing `deviceId`.
  missingDeviceId(
    'ASGPA-2004',
    'Push authentication request is missing "deviceId".',
  ),

  /// Push provider name is empty.
  emptyProviderName(
    'ASGPA-2005',
    'Push provider name must not be empty.',
  ),

  /// Account ID is empty.
  emptyAccountId(
    'ASGPA-2006',
    'Account ID must not be empty.',
  ),

  /// No edit parameter provided for device update.
  noEditParam(
    'ASGPA-2007',
    'At least one of "name" or "pushToken" must be provided '
        'for a device update.',
  ),

  /// Push notification data missing a required field.
  missingPushNotificationField(
    'ASGPA-2010',
    'Push notification data is missing required field "%s".',
  ),

  /// QR code JSON is malformed or unparseable.
  invalidQrJson(
    'ASGPA-2008',
    'Invalid QR code JSON: %s',
  ),

  /// URL path cannot be resolved — relativePath, tenantDomain, and
  /// organizationId are all absent.
  unresolvableUrlPath(
    'ASGPA-2009',
    'Cannot resolve URL path: relativePath, tenantDomain, and '
        'organizationId are all absent.',
  ),

  // Account errors.

  /// Local account not found by ID.
  accountNotFoundById(
    'ASGPA-3001',
    'No account found with ID "%s".',
  ),

  /// Local account not found by device ID.
  accountNotFoundByDeviceId(
    'ASGPA-3002',
    'No account found for deviceId "%s".',
  ),

  /// An account is already registered for the given user.
  accountAlreadyRegistered(
    'ASGPA-3003',
    'An account is already registered for user "%s". '
        'Remove the existing account before re-registering.',
  ),

  // Network errors.

  /// HTTP request failed after retries.
  networkFailure(
    'ASGPA-4001',
    'Request to "%s" failed after %s attempts.',
  ),

  /// HTTP response indicated a failure status for an SDK operation.
  ///
  /// `%s` = operation name (e.g. "Registration"), `%s` = HTTP status code.
  requestFailed(
    'ASGPA-4002',
    '%s failed with status %s.',
  ),

  // Crypto errors.

  /// Cryptographic operation failed.
  cryptoFailure(
    'ASGPA-5001',
    'Cryptographic operation failed: %s',
  ),

  /// RSA key pair generation failed.
  keyPairGenerationFailed(
    'ASGPA-5002',
    'Failed to generate key pair for alias "%s".',
  ),

  /// Private key not found in storage for the given alias.
  privateKeyNotFound(
    'ASGPA-5003',
    'No private key found for alias "%s".',
  ),

  /// RSA signing operation failed.
  signingFailed(
    'ASGPA-5004',
    'Failed to sign data with alias "%s".',
  ),

  /// Key pair deletion failed.
  keyDeletionFailed(
    'ASGPA-5005',
    'Failed to delete key pair for alias "%s".',
  ),

  /// Key existence check failed.
  keyExistenceCheckFailed(
    'ASGPA-5006',
    'Failed to check key existence for alias "%s".',
  ),

  // Storage errors.

  /// Local storage operation failed.
  storageFailure(
    'ASGPA-6001',
    'Storage operation failed: %s',
  ),

  // Biometric errors.

  /// Biometric or device-credential authentication is not available on
  /// the device (mandatory policy only).
  biometricUnavailable(
    'ASGPA-7001',
    'Biometric authentication is required but not available on this device.',
  ),

  /// The biometric or device-credential prompt was cancelled or failed.
  biometricAuthFailed(
    'ASGPA-7002',
    'Biometric authentication failed or was cancelled.',
  );

  const AsgardeoPushAuthErrorCode(this.code, this.message);

  /// The unique error code (e.g., `ASGPA-2001`).
  final String code;

  /// The human-readable message template.
  ///
  /// May contain `%s` placeholders for interpolation via [format].
  final String message;

  /// Returns the message with `%s` placeholders replaced by [args].
  String format(List<String> args) {

    var result = message;
    for (final arg in args) {
      result = result.replaceFirst('%s', arg);
    }
    return result;
  }

  @override
  String toString() => '$code - $message';
}
