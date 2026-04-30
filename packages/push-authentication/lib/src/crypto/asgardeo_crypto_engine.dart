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

/// Interface for cryptographic operations used by the SDK.
///
/// Keys are referenced by an alias string. Implementations are
/// responsible for securely storing private key material and
/// performing signing operations.
abstract class AsgardeoCryptoEngine {

  /// Generates an RSA-2048 key pair and stores it under [alias].
  /// Returns the public key in Base64-encoded format.
  Future<String> generateKeyPair(String alias);

  /// Signs [data] using the private key referenced by [alias].
  /// Uses RSA-SHA256 (PKCS#1 v1.5). Returns raw signature bytes.
  Future<List<int>> sign(String alias, List<int> data);

  /// Deletes the key pair referenced by [alias].
  Future<void> deleteKeyPair(String alias);

  /// Returns `true` if a key pair exists for the given [alias].
  Future<bool> hasKeyPair(String alias);
}
