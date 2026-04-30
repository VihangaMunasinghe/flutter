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
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// RSA key PEM and Base64 codec utilities.
class RsaPemUtils {
  RsaPemUtils._();

  // ── Public API ────────────────────────────────────────────────

  /// Encodes [key] to a PKCS#1 PEM string
  /// (`-----BEGIN RSA PRIVATE KEY-----`).
  static String encodePrivateKeyToPem(RSAPrivateKey key) =>
      _wrapPem('RSA PRIVATE KEY', _encodePrivateKeyDer(key));

  /// Encodes [key] to raw Base64 string without PEM headers.
  static String encodePublicKeyToBase64(RSAPublicKey key) =>
      base64Encode(_encodePublicKeyDer(key));

  /// Decodes a PKCS#1 PEM private key to an [RSAPrivateKey].
  static RSAPrivateKey decodePrivateKeyFromPem(String pem) =>
      _decodePrivateKeyDer(_unwrapPem('RSA PRIVATE KEY', pem));

  // ── DER encoding ──────────────────────────────────────────────

  static Uint8List _encodePrivateKeyDer(RSAPrivateKey key) {
    final d = key.privateExponent!;
    final p = key.p!;
    final q = key.q!;
    return _derSequence([
      _derInteger(BigInt.zero),          // version
      _derInteger(key.modulus!),         // modulus      (n)
      _derInteger(key.publicExponent!),  // publicExp    (e)
      _derInteger(d),                    // privateExp   (d)
      _derInteger(p),                    // prime1       (p)
      _derInteger(q),                    // prime2       (q)
      _derInteger(d % (p - BigInt.one)), // exponent1   (dP)
      _derInteger(d % (q - BigInt.one)), // exponent2   (dQ)
      _derInteger(q.modInverse(p)),      // coefficient (qInv)
    ]);
  }

  static Uint8List _encodePublicKeyDer(RSAPublicKey key) {
    final rsaSeq = _derSequence([
      _derInteger(key.modulus!),
      _derInteger(key.publicExponent!),
    ]);
    final algId = _derSequence([
      _derOid(),
      Uint8List.fromList([0x05, 0x00]), // NULL
    ]);
    return _derSequence([algId, _derBitString(rsaSeq)]);
  }

  // ── DER decoding ──────────────────────────────────────────────

  static RSAPrivateKey _decodePrivateKeyDer(Uint8List der) {
    var offset = 0;
    offset += 1; // outer SEQUENCE tag
    final outerLen = _readLength(der, offset);
    offset += outerLen.consumed;
    // version INTEGER — skip.
    offset += _readInteger(der, offset).consumed;
    // n
    final n = _readInteger(der, offset);
    offset += n.consumed;
    // e — skip value; PointyCastle recalculates it from d, p, q.
    offset += _readInteger(der, offset).consumed;
    // d
    final d = _readInteger(der, offset);
    offset += d.consumed;
    // p
    final p = _readInteger(der, offset);
    offset += p.consumed;
    // q
    final q = _readInteger(der, offset);
    return RSAPrivateKey(n.value, d.value, p.value, q.value);
  }

  // ── DER primitives ────────────────────────────────────────────

  static Uint8List _derSequence(List<Uint8List> items) {
    final body = items.expand((item) => item).toList();
    return Uint8List.fromList(
      [0x30, ..._derLength(body.length), ...body],
    );
  }

  static Uint8List _derInteger(BigInt value) {
    var bytes = _bigIntToBytes(value);
    // Prepend 0x00 sign byte when the high bit is set so DER
    // interprets the integer as positive.
    if (bytes[0] & 0x80 != 0) {
      bytes = Uint8List.fromList([0x00, ...bytes]);
    }
    return Uint8List.fromList(
      [0x02, ..._derLength(bytes.length), ...bytes],
    );
  }

  static Uint8List _derOid() {
    // OID 1.2.840.113549.1.1.1 (rsaEncryption).
    const oidBytes = [
      0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01,
    ];
    return Uint8List.fromList([0x06, oidBytes.length, ...oidBytes]);
  }

  static Uint8List _derBitString(Uint8List data) {
    // Leading 0x00 byte encodes "zero unused bits in the last byte".
    return Uint8List.fromList(
      [0x03, ..._derLength(data.length + 1), 0x00, ...data],
    );
  }

  static List<int> _derLength(int length) {
    if (length <= 127) return [length];
    final bytes = <int>[];
    var remaining = length;
    while (remaining > 0) {
      bytes.insert(0, remaining & 0xff);
      remaining >>= 8;
    }
    return [0x80 | bytes.length, ...bytes];
  }

  static Uint8List _bigIntToBytes(BigInt value) {
    var hex = value.toRadixString(16);
    if (hex.length.isOdd) hex = '0$hex';
    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }

  // ── DER reader ────────────────────────────────────────────────

  static ({int value, int consumed}) _readLength(
    Uint8List data,
    int offset,
  ) {
    final first = data[offset];
    if (first & 0x80 == 0) return (value: first, consumed: 1);
    final numBytes = first & 0x7f;
    var length = 0;
    for (var i = 1; i <= numBytes; i++) {
      length = (length << 8) | data[offset + i];
    }
    return (value: length, consumed: 1 + numBytes);
  }

  static ({BigInt value, int consumed}) _readInteger(
    Uint8List data,
    int offset,
  ) {
    final lenResult = _readLength(data, offset + 1);
    final start = offset + 1 + lenResult.consumed;
    var bytes = data.sublist(start, start + lenResult.value);
    // Strip leading 0x00 sign byte if present.
    if (bytes.isNotEmpty && bytes[0] == 0x00) bytes = bytes.sublist(1);
    final value = bytes.fold(
      BigInt.zero,
      (acc, b) => (acc << 8) | BigInt.from(b),
    );
    return (value: value, consumed: 1 + lenResult.consumed + lenResult.value);
  }

  // ── PEM helpers ───────────────────────────────────────────────

  static String _wrapPem(String label, Uint8List der) {
    final b64 = base64Encode(der);
    final lines = RegExp('.{1,64}')
        .allMatches(b64)
        .map((m) => m.group(0)!)
        .join('\n');
    return '-----BEGIN $label-----\n$lines\n-----END $label-----';
  }

  static Uint8List _unwrapPem(String label, String pem) {
    return base64Decode(
      pem
          .replaceAll('-----BEGIN $label-----', '')
          .replaceAll('-----END $label-----', '')
          .replaceAll(RegExp(r'\s+'), ''),
    );
  }
}
