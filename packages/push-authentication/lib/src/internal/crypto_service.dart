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
import 'dart:math';

import 'package:asgardeo_push_auth/src/crypto/asgardeo_crypto_engine.dart';
import 'package:asgardeo_push_auth/src/internal/biometric_service.dart';
import 'package:asgardeo_push_auth/src/internal/constants/error_codes.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:asgardeo_push_auth/src/models/biometric_policy.dart';

/// Internal service that orchestrates cryptographic operations.
///
/// Delegates key management and signing to the injected
/// [AsgardeoCryptoEngine], and handles JWT construction,
/// base64url encoding, and challenge signature assembly.
///
/// Before every private-key operation, [_gate] enforces the configured
/// [BiometricPolicy] by prompting the user via [BiometricService].
class CryptoService {

  /// Creates a [CryptoService] with the given crypto engine and biometric
  /// policy.
  CryptoService(
    this._engine, {
    required this.policy,
    required this.biometricService,
    required this.localizedReason,
  });

  final AsgardeoCryptoEngine _engine;

  /// The biometric policy applied before each private-key operation.
  final BiometricPolicy policy;

  /// Service used to check biometric availability and prompt the user.
  final BiometricService biometricService;

  /// Reason string shown in the biometric prompt dialog.
  final String localizedReason;

  // ─── Biometric gate ────────────────────────────────────

  /// Enforces [policy] before a private-key operation.
  ///
  /// - [BiometricPolicy.disabled]: proceeds immediately.
  /// - [BiometricPolicy.enabled]: prompts if available; skips silently if not.
  /// - [BiometricPolicy.mandatory]: requires biometric support; always prompts.
  Future<void> _gate() async {
    if (policy == BiometricPolicy.disabled) return;

    final available = await biometricService.isAvailable();

    if (!available) {
      if (policy == BiometricPolicy.mandatory) {
        throw AsgardeoBiometricUnavailableException(
          AsgardeoPushAuthErrorCode.biometricUnavailable.message,
          code: AsgardeoPushAuthErrorCode.biometricUnavailable.code,
        );
      }
      // enabled + not available → skip silently.
      return;
    }

    final authenticated = await biometricService.authenticate(localizedReason);
    if (!authenticated) {
      throw AsgardeoBiometricAuthFailedException(
        AsgardeoPushAuthErrorCode.biometricAuthFailed.message,
        code: AsgardeoPushAuthErrorCode.biometricAuthFailed.code,
      );
    }
  }

  // ─── Public operations ─────────────────────────────────

  /// Generates an RSA key pair and returns the public key as
  /// a Base64-encoded string (PEM headers stripped).
  Future<String> generateKeyPairAndGetPublicKeyBase64(String alias) async {

    await _gate();

    try {
      final publicKey = await _engine.generateKeyPair(alias);
      return publicKey;
    } catch (e) {
      if (e is AsgardeoCryptoException) rethrow;
      throw AsgardeoCryptoException(
        AsgardeoPushAuthErrorCode.keyPairGenerationFailed.format([alias]),
        code: AsgardeoPushAuthErrorCode.keyPairGenerationFailed.code,
        cause: e,
      );
    }
  }

  /// Deletes the key pair referenced by [alias].
  Future<void> deleteKeyPair(String alias) async {

    await _engine.deleteKeyPair(alias);
  }

  /// Signs the registration challenge: RSA-SHA256("$challenge.$deviceToken").
  ///
  /// Returns the signature as a standard Base64-encoded string.
  Future<String> generateChallengeSignature(
    String challenge,
    String deviceToken,
    String alias,
  ) async {

    await _gate();

    final dataToSign = utf8.encode('$challenge.$deviceToken');
    final signatureBytes = await _engine.sign(alias, dataToSign);
    return base64Encode(signatureBytes);
  }

  /// Builds and signs a JWT with the given [header] and [body].
  ///
  /// Assembled as: base64url(header).base64url(body).base64url(signature)
  /// with RS256 (RSA-SHA256 PKCS#1 v1.5) signing.
  Future<String> generateSignedJwt(
    Map<String, dynamic> header,
    Map<String, dynamic> body,
    String alias,
  ) async {

    await _gate();

    final unsignedJwt = _buildUnsignedJwt(header, body);
    final signatureBytes = await _engine.sign(alias, utf8.encode(unsignedJwt));
    return '$unsignedJwt.${_encodeBase64Url(signatureBytes)}';
  }

  /// Generates a UUID v4 using a cryptographically secure RNG.
  String generateRandomId() {

    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    // Set version (4) and variant (RFC 4122) bits.
    bytes[6] = (bytes[6] & 0x0F) | 0x40;
    bytes[8] = (bytes[8] & 0x3F) | 0x80;

    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20, 32)}';
  }

  // ─── Private helpers ───────────────────────────────────

  /// Builds the unsigned portion: base64url(header).base64url(body).
  String _buildUnsignedJwt(
    Map<String, dynamic> header,
    Map<String, dynamic> body,
  ) {

    final encodedHeader = _encodeBase64Url(utf8.encode(jsonEncode(header)));
    final encodedBody = _encodeBase64Url(utf8.encode(jsonEncode(body)));
    return '$encodedHeader.$encodedBody';
  }

  /// Encodes bytes to URL-safe Base64 without padding.
  String _encodeBase64Url(List<int> bytes) {

    return base64Encode(bytes)
        .replaceAll('=', '')
        .replaceAll('+', '-')
        .replaceAll('/', '_');
  }
}
