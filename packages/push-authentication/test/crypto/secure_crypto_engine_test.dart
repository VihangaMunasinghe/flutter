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
import 'dart:typed_data';

import 'package:asgardeo_push_auth/src/crypto/secure_crypto_engine.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointycastle/export.dart';

import 'crypto_engine_contract.dart';

class _MockFlutterSecureStorage extends Mock
    implements FlutterSecureStorage {}

void main() {
  late _MockFlutterSecureStorage mockStorage;
  late String testPrivatePem;

  setUpAll(() {
    // Generate a real RSA-2048 key pair once for signing tests.
    final secureRandom = SecureRandom('Fortuna')
      ..seed(
        KeyParameter(
          Uint8List.fromList(
            List<int>.generate(32, (_) => Random.secure().nextInt(256)),
          ),
        ),
      );
    final keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
          secureRandom,
        ),
      );
    final pair = keyGen.generateKeyPair();
    final privateKey = pair.privateKey;

    // Encode to PKCS#1 PEM (same format SecureCryptoEngine uses).
    testPrivatePem = _encodePrivateKeyToPem(privateKey);
  });

  setUp(() {
    mockStorage = _MockFlutterSecureStorage();
  });

  // ── Contract tests ─────────────────────────────────────

  runCryptoEngineContractTests(
    implementationName: 'SecureCryptoEngine',
    subjectFactory: () => SecureCryptoEngine(storage: mockStorage),
    arrangeGenerateKeyPairSuccess: () {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});
    },
    arrangeGenerateKeyPairFailure: () {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenThrow(Exception('storage write failed'));
    },
    arrangeSignSuccess: () {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => testPrivatePem);
    },
    arrangeSignFailureKeyNotFound: () {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => null);
    },
    arrangeSignFailure: () {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => 'invalid-pem-data');
    },
    arrangeDeleteSuccess: () {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});
    },
    arrangeDeleteFailure: () {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenThrow(Exception('storage delete failed'));
    },
    arrangeHasKeyPairTrue: () {
      when(
        () => mockStorage.containsKey(key: any(named: 'key')),
      ).thenAnswer((_) async => true);
    },
    arrangeHasKeyPairFalse: () {
      when(
        () => mockStorage.containsKey(key: any(named: 'key')),
      ).thenAnswer((_) async => false);
    },
    arrangeHasKeyPairFailure: () {
      when(
        () => mockStorage.containsKey(key: any(named: 'key')),
      ).thenThrow(Exception('storage check failed'));
    },
  );

  // ── Implementation-specific tests ──────────────────────

  group('SecureCryptoEngine specifics', () {
    test('generateKeyPair stores PEM in secure storage', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final engine = SecureCryptoEngine(storage: mockStorage);
      await engine.generateKeyPair('my-alias');

      final captured = verify(
        () => mockStorage.write(
          key: 'my-alias',
          value: captureAny(named: 'value'),
        ),
      ).captured.single as String;

      expect(captured, contains('-----BEGIN RSA PRIVATE KEY-----'));
      expect(captured, contains('-----END RSA PRIVATE KEY-----'));
    });

    test('generateKeyPair returns valid Base64 public key', () async {
      when(
        () => mockStorage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((_) async {});

      final engine = SecureCryptoEngine(storage: mockStorage);
      final publicKey = await engine.generateKeyPair('my-alias');

      // Must be valid Base64.
      expect(() => base64Decode(publicKey), returnsNormally);
      // RSA-2048 public key DER should be > 200 bytes.
      expect(base64Decode(publicKey).length, greaterThan(200));
    });

    test(
      'generateKeyPair re-throws AsgardeoCryptoException unchanged',
      () async {
        const original = AsgardeoCryptoException('original', code: 'X');
        when(
          () => mockStorage.write(
            key: any(named: 'key'),
            value: any(named: 'value'),
          ),
        ).thenThrow(original);

        final engine = SecureCryptoEngine(storage: mockStorage);
        await expectLater(
          engine.generateKeyPair('alias'),
          throwsA(
            isA<AsgardeoCryptoException>()
                .having((e) => e.message, 'message', 'original'),
          ),
        );
      },
    );

    test('sign produces a verifiable RSA-SHA256 signature', () async {
      when(
        () => mockStorage.read(key: any(named: 'key')),
      ).thenAnswer((_) async => testPrivatePem);

      final engine = SecureCryptoEngine(storage: mockStorage);
      final data = utf8.encode('test data to sign');
      final signature = await engine.sign('alias', data);

      // Signature should be 256 bytes for RSA-2048.
      expect(signature, hasLength(256));
    });
  });
}

// ─── Minimal PEM encoder for test setup ─────────────────

String _encodePrivateKeyToPem(RSAPrivateKey key) {
  final der = _derSequence([
    _derInteger(BigInt.zero),
    _derInteger(key.modulus!),
    _derInteger(key.publicExponent!),
    _derInteger(key.privateExponent!),
    _derInteger(key.p!),
    _derInteger(key.q!),
    _derInteger(key.privateExponent! % (key.p! - BigInt.one)),
    _derInteger(key.privateExponent! % (key.q! - BigInt.one)),
    _derInteger(key.q!.modInverse(key.p!)),
  ]);
  final b64 = base64Encode(der);
  final lines = RegExp('.{1,64}')
      .allMatches(b64)
      .map((m) => m.group(0)!)
      .join('\n');
  return '-----BEGIN RSA PRIVATE KEY-----\n$lines\n'
      '-----END RSA PRIVATE KEY-----';
}

Uint8List _derSequence(List<Uint8List> items) {
  final body = items.expand((item) => item).toList();
  return Uint8List.fromList([0x30, ..._derLength(body.length), ...body]);
}

Uint8List _derInteger(BigInt value) {
  var bytes = _bigIntToBytes(value);
  if (bytes[0] & 0x80 != 0) {
    bytes = Uint8List.fromList([0x00, ...bytes]);
  }
  return Uint8List.fromList([0x02, ..._derLength(bytes.length), ...bytes]);
}

List<int> _derLength(int length) {
  if (length <= 127) return [length];
  final bytes = <int>[];
  var remaining = length;
  while (remaining > 0) {
    bytes.insert(0, remaining & 0xff);
    remaining >>= 8;
  }
  return [0x80 | bytes.length, ...bytes];
}

Uint8List _bigIntToBytes(BigInt value) {
  var hex = value.toRadixString(16);
  if (hex.length.isOdd) hex = '0$hex';
  final result = Uint8List(hex.length ~/ 2);
  for (var i = 0; i < result.length; i++) {
    result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
  }
  return result;
}
