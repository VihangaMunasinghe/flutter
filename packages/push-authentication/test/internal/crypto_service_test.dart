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

import 'package:asgardeo_push_auth/src/crypto/asgardeo_crypto_engine.dart';
import 'package:asgardeo_push_auth/src/internal/biometric_service.dart';
import 'package:asgardeo_push_auth/src/internal/crypto_service.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:asgardeo_push_auth/src/models/biometric_policy.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fixtures.dart';

class _MockCryptoEngine extends Mock implements AsgardeoCryptoEngine {}

class _MockBiometricService extends Mock implements BiometricService {}

/// Decodes a base64url-encoded string (no padding required).
String _decodeBase64Url(String encoded) {
  final normalized = encoded
      .replaceAll('-', '+')
      .replaceAll('_', '/')
      .padRight(
        encoded.length + (4 - encoded.length % 4) % 4,
        '=',
      );
  return utf8.decode(base64Decode(normalized));
}

void main() {
  late _MockCryptoEngine engine;
  late _MockBiometricService biometric;

  setUp(() {
    engine = _MockCryptoEngine();
    biometric = _MockBiometricService();
    registerFallbackValue(<int>[]);
  });

  CryptoService makeService(BiometricPolicy policy) => CryptoService(
        engine,
        policy: policy,
        biometricService: biometric,
        localizedReason: 'Test',
      );

  // ── generateKeyPairAndGetPublicKeyBase64 ───────────────

  group('generateKeyPairAndGetPublicKeyBase64', () {
    setUp(() {
      when(() => engine.generateKeyPair(any()))
          .thenAnswer((_) async => 'pubkey==');
    });

    test('returns the engine public key', () async {
      final svc = makeService(BiometricPolicy.disabled);
      expect(
        await svc.generateKeyPairAndGetPublicKeyBase64(kDeviceId),
        'pubkey==',
      );
    });

    test('wraps unknown exception in AsgardeoCryptoException', () async {
      when(() => engine.generateKeyPair(any()))
          .thenThrow(Exception('boom'));
      final svc = makeService(BiometricPolicy.disabled);
      await expectLater(
        svc.generateKeyPairAndGetPublicKeyBase64(kDeviceId),
        throwsA(isA<AsgardeoCryptoException>()),
      );
    });

    test('re-throws AsgardeoCryptoException unchanged', () async {
      const original = AsgardeoCryptoException('crypto fail', code: 'X');
      when(() => engine.generateKeyPair(any())).thenThrow(original);
      final svc = makeService(BiometricPolicy.disabled);
      await expectLater(
        svc.generateKeyPairAndGetPublicKeyBase64(kDeviceId),
        throwsA(
          isA<AsgardeoCryptoException>()
              .having((e) => e.message, 'message', 'crypto fail'),
        ),
      );
    });
  });

  // ── deleteKeyPair ──────────────────────────────────────

  group('deleteKeyPair', () {
    test('delegates to the engine', () async {
      when(() => engine.deleteKeyPair(any())).thenAnswer((_) async {});
      final svc = makeService(BiometricPolicy.disabled);
      await svc.deleteKeyPair(kDeviceId);
      verify(() => engine.deleteKeyPair(kDeviceId)).called(1);
    });
  });

  // ── generateChallengeSignature ─────────────────────────

  group('generateChallengeSignature', () {
    test('signs challenge.deviceToken and returns standard Base64', () async {
      final signatureBytes = [1, 2, 3];
      when(() => engine.sign(any(), any()))
          .thenAnswer((_) async => signatureBytes);
      final svc = makeService(BiometricPolicy.disabled);
      final result = await svc.generateChallengeSignature(
        kChallenge,
        kDeviceToken,
        kDeviceId,
      );
      expect(result, base64Encode(signatureBytes));
      // Verify the signed data is UTF-8('challenge.deviceToken').
      final captured = verify(() => engine.sign(kDeviceId, captureAny()))
          .captured
          .first as List<int>;
      expect(
        utf8.decode(captured),
        '$kChallenge.$kDeviceToken',
      );
    });
  });

  // ── generateSignedJwt ──────────────────────────────────

  group('generateSignedJwt', () {
    final sigBytes = [10, 20, 30];

    setUp(() {
      when(() => engine.sign(any(), any()))
          .thenAnswer((_) async => sigBytes);
    });

    test('returns exactly 3 dot-separated parts', () async {
      final svc = makeService(BiometricPolicy.disabled);
      final jwt = await svc.generateSignedJwt(
        {'alg': 'RS256', 'typ': 'JWT'},
        {'sub': 'test'},
        kDeviceId,
      );
      expect(jwt.split('.'), hasLength(3));
    });

    test('part 0 decodes to the supplied header JSON', () async {
      final svc = makeService(BiometricPolicy.disabled);
      final header = {'alg': 'RS256', 'typ': 'JWT'};
      final jwt = await svc.generateSignedJwt(
        header,
        {'sub': 'test'},
        kDeviceId,
      );
      final decoded =
          jsonDecode(_decodeBase64Url(jwt.split('.')[0]))
              as Map<String, dynamic>;
      expect(decoded['alg'], 'RS256');
      expect(decoded['typ'], 'JWT');
    });

    test('part 1 decodes to the supplied body JSON', () async {
      final svc = makeService(BiometricPolicy.disabled);
      final body = {'sub': 'alice', 'exp': 9999};
      final jwt = await svc.generateSignedJwt(
        {'alg': 'RS256', 'typ': 'JWT'},
        body,
        kDeviceId,
      );
      final decoded =
          jsonDecode(_decodeBase64Url(jwt.split('.')[1]))
              as Map<String, dynamic>;
      expect(decoded['sub'], 'alice');
      expect(decoded['exp'], 9999);
    });

    test('part 2 is the Base64url encoding of the signature bytes', () async {
      final svc = makeService(BiometricPolicy.disabled);
      final jwt = await svc.generateSignedJwt(
        {'alg': 'RS256', 'typ': 'JWT'},
        {'sub': 'test'},
        kDeviceId,
      );
      final expected = base64Encode(sigBytes)
          .replaceAll('=', '')
          .replaceAll('+', '-')
          .replaceAll('/', '_');
      expect(jwt.split('.')[2], expected);
    });
  });

  // ── generateRandomId ───────────────────────────────────

  group('generateRandomId', () {
    final uuidRegex =
        RegExp('^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}'
            r'-[89ab][0-9a-f]{3}-[0-9a-f]{12}$');

    test('returns a UUID v4 string', () {
      final svc = makeService(BiometricPolicy.disabled);
      expect(uuidRegex.hasMatch(svc.generateRandomId()), isTrue);
    });

    test('successive calls return different values', () {
      final svc = makeService(BiometricPolicy.disabled);
      expect(svc.generateRandomId(), isNot(svc.generateRandomId()));
    });
  });

  // ── Biometric gate ─────────────────────────────────────

  group('biometric gate', () {
    setUp(() {
      when(() => engine.generateKeyPair(any()))
          .thenAnswer((_) async => 'pubkey==');
    });

    test('disabled: engine invoked without biometric check', () async {
      final svc = makeService(BiometricPolicy.disabled);
      await svc.generateKeyPairAndGetPublicKeyBase64(kDeviceId);
      verifyNever(() => biometric.isAvailable());
    });

    test('enabled + available + auth succeeds: engine invoked', () async {
      when(() => biometric.isAvailable()).thenAnswer((_) async => true);
      when(() => biometric.authenticate(any()))
          .thenAnswer((_) async => true);
      final svc = makeService(BiometricPolicy.enabled);
      await svc.generateKeyPairAndGetPublicKeyBase64(kDeviceId);
      verify(() => engine.generateKeyPair(kDeviceId)).called(1);
    });

    test('enabled + unavailable: engine still invoked (silent skip)',
        () async {
      when(() => biometric.isAvailable()).thenAnswer((_) async => false);
      final svc = makeService(BiometricPolicy.enabled);
      await svc.generateKeyPairAndGetPublicKeyBase64(kDeviceId);
      verify(() => engine.generateKeyPair(kDeviceId)).called(1);
    });

    test('enabled + auth fails: throws AsgardeoBiometricAuthFailedException',
        () async {
      when(() => biometric.isAvailable()).thenAnswer((_) async => true);
      when(() => biometric.authenticate(any()))
          .thenAnswer((_) async => false);
      final svc = makeService(BiometricPolicy.enabled);
      await expectLater(
        svc.generateKeyPairAndGetPublicKeyBase64(kDeviceId),
        throwsA(isA<AsgardeoBiometricAuthFailedException>()),
      );
    });

    test(
        'mandatory + unavailable: '
        'throws AsgardeoBiometricUnavailableException', () async {
      when(() => biometric.isAvailable()).thenAnswer((_) async => false);
      final svc = makeService(BiometricPolicy.mandatory);
      await expectLater(
        svc.generateKeyPairAndGetPublicKeyBase64(kDeviceId),
        throwsA(isA<AsgardeoBiometricUnavailableException>()),
      );
    });

    test(
        'mandatory + auth fails: '
        'throws AsgardeoBiometricAuthFailedException', () async {
      when(() => biometric.isAvailable()).thenAnswer((_) async => true);
      when(() => biometric.authenticate(any()))
          .thenAnswer((_) async => false);
      final svc = makeService(BiometricPolicy.mandatory);
      await expectLater(
        svc.generateKeyPairAndGetPublicKeyBase64(kDeviceId),
        throwsA(isA<AsgardeoBiometricAuthFailedException>()),
      );
    });
  });
}
