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

import 'dart:math';
import 'dart:typed_data';

import 'package:asgardeo_push_auth/src/crypto/asgardeo_crypto_engine.dart';
import 'package:asgardeo_push_auth/src/internal/constants/error_codes.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:asgardeo_push_auth/src/utils/rsa_pem_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pointycastle/export.dart';

/// [AsgardeoCryptoEngine] implementation using PointyCastle for
/// software-backed RSA-2048 cryptography and `flutter_secure_storage`
/// for private key persistence.
///
/// Private keys are stored as PKCS#1 PEM strings under their alias
/// in the platform's secure store (iOS Keychain /
/// Android EncryptedSharedPreferences). No biometric prompt or
/// device-credential requirement is imposed.
class SecureCryptoEngine implements AsgardeoCryptoEngine {

  /// Creates a [SecureCryptoEngine].
  ///
  /// An optional [storage] instance can be provided for testing.
  SecureCryptoEngine({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String> generateKeyPair(String alias) async {

    try {
      final keyGen = RSAKeyGenerator()
        ..init(
          ParametersWithRandom(
            RSAKeyGeneratorParameters(BigInt.from(65537), 2048, 64),
            _buildSecureRandom(),
          ),
        );

      final pair = keyGen.generateKeyPair();

      await _storage.write(
        key: alias,
        value: RsaPemUtils.encodePrivateKeyToPem(pair.privateKey),
      );

      return RsaPemUtils.encodePublicKeyToBase64(pair.publicKey);
    } on AsgardeoCryptoException {
      rethrow;
    } catch (e) {
      throw AsgardeoCryptoException(
        AsgardeoPushAuthErrorCode.keyPairGenerationFailed.format([alias]),
        code: AsgardeoPushAuthErrorCode.keyPairGenerationFailed.code,
        cause: e,
      );
    }
  }

  @override
  Future<List<int>> sign(String alias, List<int> data) async {

    try {
      final privatePem = await _storage.read(key: alias);
      if (privatePem == null) {
        throw AsgardeoCryptoException(
          AsgardeoPushAuthErrorCode.privateKeyNotFound.format([alias]),
          code: AsgardeoPushAuthErrorCode.privateKeyNotFound.code,
        );
      }

      final privateKey = RsaPemUtils.decodePrivateKeyFromPem(privatePem);
      final signer = RSASigner(SHA256Digest(), '0609608648016503040201')
        ..init(true, PrivateKeyParameter<RSAPrivateKey>(privateKey));

      final sig = signer.generateSignature(Uint8List.fromList(data));
      return sig.bytes;
    } on AsgardeoCryptoException {
      rethrow;
    } catch (e) {
      throw AsgardeoCryptoException(
        AsgardeoPushAuthErrorCode.signingFailed.format([alias]),
        code: AsgardeoPushAuthErrorCode.signingFailed.code,
        cause: e,
      );
    }
  }

  @override
  Future<void> deleteKeyPair(String alias) async {

    try {
      await _storage.delete(key: alias);
    } catch (e) {
      throw AsgardeoCryptoException(
        AsgardeoPushAuthErrorCode.keyDeletionFailed.format([alias]),
        code: AsgardeoPushAuthErrorCode.keyDeletionFailed.code,
        cause: e,
      );
    }
  }

  @override
  Future<bool> hasKeyPair(String alias) async {

    try {
      return await _storage.containsKey(key: alias);
    } catch (e) {
      throw AsgardeoCryptoException(
        AsgardeoPushAuthErrorCode.keyExistenceCheckFailed.format([alias]),
        code: AsgardeoPushAuthErrorCode.keyExistenceCheckFailed.code,
        cause: e,
      );
    }
  }

  static SecureRandom _buildSecureRandom() {
    final secureRandom = SecureRandom('Fortuna');
    final rng = Random.secure();
    final seed = Uint8List.fromList(
      List<int>.generate(32, (_) => rng.nextInt(256)),
    );
    secureRandom.seed(KeyParameter(seed));
    seed.fillRange(0, seed.length, 0);
    return secureRandom;
  }
}
