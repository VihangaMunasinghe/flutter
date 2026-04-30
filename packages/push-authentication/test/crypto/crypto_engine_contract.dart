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
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shared contract tests for [AsgardeoCryptoEngine] implementations.
///
/// Each implementation test file calls this function with its own
/// factory and arrange callbacks.
void runCryptoEngineContractTests({
  required String implementationName,
  required AsgardeoCryptoEngine Function() subjectFactory,
  required void Function() arrangeGenerateKeyPairSuccess,
  required void Function() arrangeGenerateKeyPairFailure,
  required void Function() arrangeSignSuccess,
  required void Function() arrangeSignFailureKeyNotFound,
  required void Function() arrangeSignFailure,
  required void Function() arrangeDeleteSuccess,
  required void Function() arrangeDeleteFailure,
  required void Function() arrangeHasKeyPairTrue,
  required void Function() arrangeHasKeyPairFalse,
  required void Function() arrangeHasKeyPairFailure,
}) {
  group('AsgardeoCryptoEngine contract → $implementationName', () {
    const alias = 'test-alias';
    final testData = utf8.encode('hello world');

    // ── generateKeyPair ──────────────────────────────────

    group('generateKeyPair', () {
      test('returns a non-empty Base64 string on success', () async {
        arrangeGenerateKeyPairSuccess();
        final subject = subjectFactory();
        final publicKey = await subject.generateKeyPair(alias);
        expect(publicKey, isNotEmpty);
        // Must be valid Base64.
        expect(() => base64Decode(publicKey), returnsNormally);
      });

      test(
        'throws AsgardeoCryptoException with code ASGPA-5002 '
        'on failure',
        () async {
          arrangeGenerateKeyPairFailure();
          final subject = subjectFactory();
          await expectLater(
            subject.generateKeyPair(alias),
            throwsA(
              isA<AsgardeoCryptoException>()
                  .having((e) => e.code, 'code', 'ASGPA-5002'),
            ),
          );
        },
      );

      test('re-throws AsgardeoCryptoException unchanged', () async {
        arrangeGenerateKeyPairFailure();
        final subject = subjectFactory();
        await expectLater(
          subject.generateKeyPair(alias),
          throwsA(isA<AsgardeoCryptoException>()),
        );
      });
    });

    // ── sign ─────────────────────────────────────────────

    group('sign', () {
      test('returns a non-empty List<int> on success', () async {
        arrangeSignSuccess();
        final subject = subjectFactory();
        final signature = await subject.sign(alias, testData);
        expect(signature, isNotEmpty);
      });

      test(
        'throws AsgardeoCryptoException with code ASGPA-5003 '
        'when key not found',
        () async {
          arrangeSignFailureKeyNotFound();
          final subject = subjectFactory();
          await expectLater(
            subject.sign(alias, testData),
            throwsA(
              isA<AsgardeoCryptoException>()
                  .having((e) => e.code, 'code', 'ASGPA-5003'),
            ),
          );
        },
      );

      test(
        'throws AsgardeoCryptoException with code ASGPA-5004 '
        'on signing failure',
        () async {
          arrangeSignFailure();
          final subject = subjectFactory();
          await expectLater(
            subject.sign(alias, testData),
            throwsA(
              isA<AsgardeoCryptoException>()
                  .having((e) => e.code, 'code', 'ASGPA-5004'),
            ),
          );
        },
      );
    });

    // ── deleteKeyPair ────────────────────────────────────

    group('deleteKeyPair', () {
      test('completes without error on success', () async {
        arrangeDeleteSuccess();
        final subject = subjectFactory();
        await expectLater(
          subject.deleteKeyPair(alias),
          completes,
        );
      });

      test(
        'throws AsgardeoCryptoException with code ASGPA-5005 '
        'on failure',
        () async {
          arrangeDeleteFailure();
          final subject = subjectFactory();
          await expectLater(
            subject.deleteKeyPair(alias),
            throwsA(
              isA<AsgardeoCryptoException>()
                  .having((e) => e.code, 'code', 'ASGPA-5005'),
            ),
          );
        },
      );
    });

    // ── hasKeyPair ───────────────────────────────────────

    group('hasKeyPair', () {
      test('returns true when key exists', () async {
        arrangeHasKeyPairTrue();
        final subject = subjectFactory();
        expect(await subject.hasKeyPair(alias), isTrue);
      });

      test('returns false when key is absent', () async {
        arrangeHasKeyPairFalse();
        final subject = subjectFactory();
        expect(await subject.hasKeyPair(alias), isFalse);
      });

      test(
        'throws AsgardeoCryptoException with code ASGPA-5006 '
        'on failure',
        () async {
          arrangeHasKeyPairFailure();
          final subject = subjectFactory();
          await expectLater(
            subject.hasKeyPair(alias),
            throwsA(
              isA<AsgardeoCryptoException>()
                  .having((e) => e.code, 'code', 'ASGPA-5006'),
            ),
          );
        },
      );
    });
  });
}
