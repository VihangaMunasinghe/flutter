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

/// Base exception for all errors thrown by the package.
class AsgardeoException implements Exception {

  /// Creates an [AsgardeoException].
  const AsgardeoException(this.message, {this.code, this.traceId, this.cause});

  /// An error code identifying the specific failure.
  ///
  /// For errors originating from server responses, this is the server's error
  /// code (e.g., `PDH-15009`). For package-internal errors, this is a package
  /// error code prefixed with `ASGPA-` (e.g., `ASGPA-2001`).
  final String? code;

  /// Server trace ID for correlating with server-side logs.
  final String? traceId;

  /// A human-readable description of the error.
  final String message;

  /// The underlying error that caused this failure, if any.
  final Object? cause;

  @override
  String toString() {

    final buffer = StringBuffer('AsgardeoException');
    if (code != null) {
      buffer.write(' [$code]');
    }
    buffer.write(': $message');
    if (traceId != null) {
      buffer.write(' (traceId: $traceId)');
    }
    if (cause != null) {
      buffer.write(' (cause: $cause)');
    }
    return buffer.toString();
  }
}

/// Thrown when the package is accessed before initialization.
class AsgardeoNotInitializedException extends AsgardeoException {

  /// Creates an [AsgardeoNotInitializedException].
  const AsgardeoNotInitializedException(
    super.message, {
    super.code,
  });
}

/// Thrown when `build()` is called more than once without `reset()`.
class AsgardeoAlreadyInitializedException extends AsgardeoException {

  /// Creates an [AsgardeoAlreadyInitializedException].
  const AsgardeoAlreadyInitializedException(
    super.message, {
    super.code,
  });
}

/// Thrown when input validation fails.
class AsgardeoValidationException extends AsgardeoException {

  /// Creates an [AsgardeoValidationException].
  const AsgardeoValidationException(
    super.message, {
    super.code,
    super.cause,
  });
}

/// Thrown when device registration fails.
class AsgardeoRegistrationException extends AsgardeoException {

  /// Creates an [AsgardeoRegistrationException].
  const AsgardeoRegistrationException(
    super.message, {
    super.code,
    super.traceId,
    super.cause,
  });
}

/// Thrown when a device registration is attempted but the user already has
/// a registered account on this device.
class AsgardeoDeviceAlreadyRegisteredException
    extends AsgardeoRegistrationException {

  /// Creates an [AsgardeoDeviceAlreadyRegisteredException].
  const AsgardeoDeviceAlreadyRegisteredException(
    super.message, {
    super.code,
    super.traceId,
  });
}

/// Thrown when sending an authentication response fails.
class AsgardeoAuthResponseException extends AsgardeoException {

  /// Creates an [AsgardeoAuthResponseException].
  const AsgardeoAuthResponseException(
    super.message, {
    super.code,
    super.traceId,
    super.cause,
  });
}

/// Thrown when a referenced account cannot be found locally.
class AsgardeoAccountNotFoundException extends AsgardeoException {

  /// Creates an [AsgardeoAccountNotFoundException].
  const AsgardeoAccountNotFoundException(
    super.message, {
    super.code,
    super.cause,
  });
}

/// Thrown when the server reports the device is not found (PDH-15009).
///
/// Can occur during device update or unregistration operations.
class AsgardeoDeviceNotFoundException extends AsgardeoException {

  /// Creates an [AsgardeoDeviceNotFoundException].
  const AsgardeoDeviceNotFoundException(
    super.message, {
    super.code,
    super.traceId,
    super.cause,
  });
}

/// Thrown when a device update request fails on the server.
class AsgardeoDeviceUpdateException extends AsgardeoException {

  /// Creates an [AsgardeoDeviceUpdateException].
  const AsgardeoDeviceUpdateException(
    super.message, {
    super.code,
    super.traceId,
    super.cause,
  });
}

/// Thrown when device unregistration fails on the server.
class AsgardeoUnregistrationException extends AsgardeoException {

  /// Creates an [AsgardeoUnregistrationException].
  const AsgardeoUnregistrationException(
    super.message, {
    super.code,
    super.traceId,
    super.cause,
  });
}

/// Thrown when a cryptographic operation fails.
class AsgardeoCryptoException extends AsgardeoException {

  /// Creates an [AsgardeoCryptoException].
  const AsgardeoCryptoException(
    super.message, {
    super.code,
    super.cause,
  });
}

/// Thrown when an actual network failure occurs (connection error, timeout).
///
/// This is only thrown for transport-level failures, not for server error
/// responses (4xx/5xx). Server errors throw operation-specific exceptions.
class AsgardeoNetworkException extends AsgardeoException {

  /// Creates an [AsgardeoNetworkException].
  const AsgardeoNetworkException(
    super.message, {
    this.statusCode,
    super.code,
    super.cause,
  });

  /// The HTTP status code, if available.
  final int? statusCode;
}

/// Thrown when a local storage operation fails.
class AsgardeoStorageException extends AsgardeoException {

  /// Creates an [AsgardeoStorageException].
  const AsgardeoStorageException(
    super.message, {
    super.code,
    super.cause,
  });
}

/// Thrown when biometric or device-credential authentication is required
/// (`BiometricPolicy.mandatory`) but the device does not support it.
class AsgardeoBiometricUnavailableException extends AsgardeoException {

  /// Creates an [AsgardeoBiometricUnavailableException].
  const AsgardeoBiometricUnavailableException(
    super.message, {
    super.code,
  });
}

/// Thrown when the biometric or device-credential prompt was shown but
/// the user cancelled or failed authentication.
///
/// Thrown for both `BiometricPolicy.enabled` and `BiometricPolicy.mandatory`
/// when the device supports biometrics but authentication does not succeed.
class AsgardeoBiometricAuthFailedException extends AsgardeoException {

  /// Creates an [AsgardeoBiometricAuthFailedException].
  const AsgardeoBiometricAuthFailedException(
    super.message, {
    super.code,
  });
}
