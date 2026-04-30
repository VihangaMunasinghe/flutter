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

import 'dart:async';
import 'dart:convert';

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:asgardeo_push_auth/src/internal/account_store.dart';
import 'package:asgardeo_push_auth/src/internal/history_store.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/fixtures.dart';
import 'helpers/in_memory_storage_manager.dart';

// ─── Mocks ──────────────────────────────────────────────────────────────────

class _MockHttpManager extends Mock implements AsgardeoHttpManager {}

class _MockCryptoEngine extends Mock implements AsgardeoCryptoEngine {}

class _MockDeviceInfoProvider extends Mock
    implements AsgardeoDeviceInfoProvider {}

// ─── Helpers ────────────────────────────────────────────────────────────────

/// Decodes a base64url-encoded string (no padding required).
String _fromBase64Url(String s) {
  final padded = s
      .replaceAll('-', '+')
      .replaceAll('_', '/')
      .padRight(s.length + (4 - s.length % 4) % 4, '=');
  return utf8.decode(base64Decode(padded));
}

/// Extracts the decoded JWT body from an authResponse POST body JSON string.
Map<String, dynamic> _extractJwtBody(String postBodyJson) {
  final outer = jsonDecode(postBodyJson) as Map<String, dynamic>;
  final jwt = outer['authResponse'] as String;
  final part = jwt.split('.')[1];
  return jsonDecode(_fromBase64Url(part)) as Map<String, dynamic>;
}

void main() {
  late _MockHttpManager mockHttp;
  late _MockCryptoEngine mockCrypto;
  late _MockDeviceInfoProvider mockDeviceInfo;
  late InMemoryStorageManager storage;

  void stubCrypto() {
    when(() => mockCrypto.generateKeyPair(any()))
        .thenAnswer((_) async => 'pubkey==');
    when(() => mockCrypto.sign(any(), any()))
        .thenAnswer((_) async => [1, 2, 3]);
    when(() => mockCrypto.deleteKeyPair(any()))
        .thenAnswer((_) async {});
  }

  void stubDeviceInfo() {
    when(() => mockDeviceInfo.getDeviceInfo())
        .thenAnswer((_) async => (name: 'Phone', model: 'Model X'));
  }

  /// Seeds storage with [kValidAccount] so auth-response tests can find it.
  Future<void> seedAccount() =>
      AccountStore(storage).saveAccount(kValidAccount);

  setUp(() {
    mockHttp = _MockHttpManager();
    mockCrypto = _MockCryptoEngine();
    mockDeviceInfo = _MockDeviceInfoProvider();
    storage = InMemoryStorageManager();

    registerFallbackValue(<int>[]);

    when(() => mockHttp.dispose()).thenAnswer((_) {});
    stubCrypto();
    stubDeviceInfo();

    AsgardeoPushAuth.reset();
    (AsgardeoPushAuthBuilder()
          ..httpManager = mockHttp
          ..storageManager = storage
          ..cryptoEngine = mockCrypto
          ..deviceInfoProvider = mockDeviceInfo
          ..biometricPolicy = BiometricPolicy.disabled
          ..maxRetries = 0)
        .build();
  });

  tearDown(AsgardeoPushAuth.reset);

  // ─── Singleton / builder ──────────────────────────────────────────────────

  group('AsgardeoPushAuthBuilder', () {
    test('isInitialized is false before build()', () {
      AsgardeoPushAuth.reset();
      expect(AsgardeoPushAuth.isInitialized, isFalse);
    });

    test('instance throws before build()', () {
      AsgardeoPushAuth.reset();
      expect(
        () => AsgardeoPushAuth.instance,
        throwsA(isA<AsgardeoNotInitializedException>()),
      );
    });

    test('double build() throws AsgardeoAlreadyInitializedException', () {
      expect(
        AsgardeoPushAuthBuilder().build,
        throwsA(isA<AsgardeoAlreadyInitializedException>()),
      );
    });

    test('reset() allows re-initialization', () {
      AsgardeoPushAuth.reset();
      expect(() => AsgardeoPushAuthBuilder().build(), returnsNormally);
    });
  });

  // ─── registerDevice ────────────────────────────────────────────────────────

  group('registerDevice', () {
    test('returns account ID on success (HTTP 201)', () async {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const AsgardeoHttpResponse(statusCode: 201, body: '{}'),
      );

      final id = await AsgardeoPushAuth.instance
          .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider());

      expect(id, isNotEmpty);
    });

    test('throws ASGPA-2008 for malformed QR JSON', () async {
      await expectLater(
        AsgardeoPushAuth.instance
            .registerDevice('not-json', kDeviceToken, FCMPushProvider()),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2008'),
        ),
      );
    });

    test('throws ASGPA-2001 when required QR field is missing', () async {
      const json =
          '{"challenge":"ch","username":"u","host":"h",'
          '"tenantDomain":"td"}';
      await expectLater(
        AsgardeoPushAuth.instance
            .registerDevice(json, kDeviceToken, FCMPushProvider()),
        throwsA(isA<AsgardeoValidationException>()),
      );
    });

    test('throws ASGPA-2005 for provider with empty name', () async {
      await expectLater(
        AsgardeoPushAuth.instance.registerDevice(
          kValidQrJson,
          kDeviceToken,
          CustomPushProvider(name: ''),
        ),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2005'),
        ),
      );
    });

    test('throws AsgardeoRegistrationException with server code on 4xx',
        () async {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async =>
            const AsgardeoHttpResponse(statusCode: 400, body: kServerErrorBody),
      );

      await expectLater(
        AsgardeoPushAuth.instance
            .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider()),
        throwsA(
          isA<AsgardeoRegistrationException>()
              .having((e) => e.code, 'code', 'ERR-001'),
        ),
      );
    });

    test('uses fallback message when 4xx body is not parseable', () async {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async =>
            const AsgardeoHttpResponse(statusCode: 400, body: 'bad body'),
      );

      await expectLater(
        AsgardeoPushAuth.instance
            .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider()),
        throwsA(isA<AsgardeoRegistrationException>()),
      );
    });

    test('throws AsgardeoNetworkException on transport failure', () async {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('network down'));

      await expectLater(
        AsgardeoPushAuth.instance
            .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider()),
        throwsA(isA<AsgardeoNetworkException>()),
      );
    });

    test('cleans up key pair on HTTP failure', () async {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async =>
            const AsgardeoHttpResponse(statusCode: 400, body: kServerErrorBody),
      );

      await expectLater(
        AsgardeoPushAuth.instance
            .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider()),
        throwsA(isA<AsgardeoRegistrationException>()),
      );

      verify(() => mockCrypto.deleteKeyPair(kDeviceId)).called(1);
    });

    test('cleans up key pair on network failure', () async {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenThrow(Exception('network down'));

      await expectLater(
        AsgardeoPushAuth.instance
            .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider()),
        throwsA(isA<AsgardeoNetworkException>()),
      );

      verify(() => mockCrypto.deleteKeyPair(kDeviceId)).called(1);
    });

    test('throws AsgardeoDeviceAlreadyRegisteredException when account exists',
        () async {
      await AccountStore(storage).saveAccount(kValidAccount);

      await expectLater(
        AsgardeoPushAuth.instance
            .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider()),
        throwsA(
          isA<AsgardeoDeviceAlreadyRegisteredException>()
              .having((e) => e.code, 'code', 'ASGPA-3003'),
        ),
      );
    });

    test('does not generate key pair when duplicate account exists', () async {
      await AccountStore(storage).saveAccount(kValidAccount);

      await expectLater(
        AsgardeoPushAuth.instance
            .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider()),
        throwsA(isA<AsgardeoDeviceAlreadyRegisteredException>()),
      );

      verifyNever(() => mockCrypto.generateKeyPair(any()));
    });
  });

  // ─── registerDeviceWithToken ───────────────────────────────────────────────

  group('registerDeviceWithToken', () {
    test('fetches discovery data then registers device', () async {
      when(
        () => mockHttp.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async =>
            const AsgardeoHttpResponse(statusCode: 200, body: kValidQrJson),
      );
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const AsgardeoHttpResponse(statusCode: 201, body: '{}'),
      );

      final id = await AsgardeoPushAuth.instance.registerDeviceWithToken(
        kHost,
        'access-token',
        kDeviceToken,
        FCMPushProvider(),
      );
      expect(id, isNotEmpty);
    });

    test('throws AsgardeoRegistrationException on 4xx discovery', () async {
      when(
        () => mockHttp.get(any(), headers: any(named: 'headers')),
      ).thenAnswer(
        (_) async =>
            const AsgardeoHttpResponse(statusCode: 401, body: kServerErrorBody),
      );

      await expectLater(
        AsgardeoPushAuth.instance.registerDeviceWithToken(
          kHost,
          'bad-token',
          kDeviceToken,
          FCMPushProvider(),
        ),
        throwsA(isA<AsgardeoRegistrationException>()),
      );
    });

    test('throws AsgardeoNetworkException on transport failure', () async {
      when(
        () => mockHttp.get(any(), headers: any(named: 'headers')),
      ).thenThrow(Exception('network down'));

      await expectLater(
        AsgardeoPushAuth.instance.registerDeviceWithToken(
          kHost,
          'token',
          kDeviceToken,
          FCMPushProvider(),
        ),
        throwsA(isA<AsgardeoNetworkException>()),
      );
    });
  });

  // ─── parsePushNotification ────────────────────────────────────────────────

  group('parsePushNotification', () {
    test('parses FCM flat structure (root-level pushId)', () {
      final data = <String, dynamic>{
        'pushId': kPushId,
        'challenge': kChallenge,
        'deviceId': kDeviceId,
        'username': kUsername,
        'tenantDomain': kTenantDomain,
        'userStoreDomain': 'PRIMARY',
        'applicationName': 'App',
        'notificationScenario': 'AUTHENTICATION',
        'ipAddress': '1.2.3.4',
        'deviceOS': 'iOS',
        'browser': 'Safari',
      };
      expect(
        AsgardeoPushAuth.instance.parsePushNotification(data),
        isA<PushAuthRequest>(),
      );
    });

    test('parses APNS nested structure (data.pushId)', () {
      final data = <String, dynamic>{
        'data': <String, dynamic>{
          'pushId': kPushId,
          'challenge': kChallenge,
          'deviceId': kDeviceId,
          'username': kUsername,
          'tenantDomain': kTenantDomain,
          'userStoreDomain': 'PRIMARY',
          'applicationName': 'App',
          'notificationScenario': 'AUTHENTICATION',
          'ipAddress': '1.2.3.4',
          'deviceOS': 'iOS',
          'browser': 'Safari',
        },
      };
      expect(
        AsgardeoPushAuth.instance.parsePushNotification(data),
        isA<PushAuthRequest>(),
      );
    });

    test('sentTime parameter is forwarded to PushAuthRequest', () {
      final data = <String, dynamic>{
        'pushId': kPushId,
        'challenge': kChallenge,
        'deviceId': kDeviceId,
        'username': kUsername,
        'tenantDomain': kTenantDomain,
        'userStoreDomain': 'PRIMARY',
        'applicationName': 'App',
        'notificationScenario': 'AUTHENTICATION',
        'ipAddress': '1.2.3.4',
        'deviceOS': 'iOS',
        'browser': 'Safari',
      };
      final request = AsgardeoPushAuth.instance
          .parsePushNotification(data, sentTime: 12345);
      expect(request!.sentTime, 12345);
    });

    test('returns null when mandatory field is missing', () {
      final data = <String, dynamic>{
        'pushId': kPushId,
        'challenge': kChallenge,
        'deviceId': kDeviceId,
        'username': kUsername,
        'tenantDomain': kTenantDomain,
        'userStoreDomain': 'PRIMARY',
        'applicationName': 'App',
        'notificationScenario': 'AUTHENTICATION',
        // ipAddress intentionally missing
        'deviceOS': 'iOS',
        'browser': 'Safari',
      };
      expect(
        AsgardeoPushAuth.instance.parsePushNotification(data),
        isNull,
      );
    });

    test('returns null for unrecognised structure', () {
      expect(
        AsgardeoPushAuth.instance
            .parsePushNotification({'unrelated': 'data'}),
        isNull,
      );
    });
  });

  // ─── sendAuthResponse ─────────────────────────────────────────────────────

  group('sendAuthResponse', () {
    setUp(seedAccount);

    void stubAuthPost({int status = 200}) {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async =>
            AsgardeoHttpResponse(statusCode: status, body: '{}'),
      );
    }

    test('HTTP 200 completes normally and records history', () async {
      stubAuthPost();
      await AsgardeoPushAuth.instance.sendAuthResponse(
        kValidRequest,
        PushAuthResponseStatus.approved,
      );
      final history =
          await HistoryStore(storage).getHistory(kAccountId);
      expect(history, hasLength(1));
    });

    test('HTTP 202 completes normally', () async {
      stubAuthPost(status: 202);
      await expectLater(
        AsgardeoPushAuth.instance.sendAuthResponse(
          kValidRequest,
          PushAuthResponseStatus.approved,
        ),
        completes,
      );
    });

    test('approved + selectedNumber → numberChallenge in JWT body',
        () async {
      stubAuthPost();
      await AsgardeoPushAuth.instance.sendAuthResponse(
        kValidRequest,
        PushAuthResponseStatus.approved,
        selectedNumber: 42,
      );
      final captured = verify(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;
      final jwtBody = _extractJwtBody(captured.last as String);
      expect(jwtBody.containsKey('numberChallenge'), isTrue);
      expect(jwtBody['numberChallenge'], '42');
    });

    test('denied + selectedNumber → no numberChallenge in JWT body',
        () async {
      stubAuthPost();
      await AsgardeoPushAuth.instance.sendAuthResponse(
        kValidRequest,
        PushAuthResponseStatus.denied,
        selectedNumber: 42,
      );
      final captured = verify(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: captureAny(named: 'body'),
        ),
      ).captured;
      final jwtBody = _extractJwtBody(captured.last as String);
      expect(jwtBody.containsKey('numberChallenge'), isFalse);
    });

    test('throws ASGPA-2002 for empty pushId', () async {
      const badRequest = PushAuthRequest(
        pushId: '',
        challenge: kChallenge,
        deviceId: kDeviceId,
        username: kUsername,
        tenantDomain: kTenantDomain,
        userStoreDomain: 'PRIMARY',
        applicationName: 'App',
        notificationScenario: 'AUTHENTICATION',
        ipAddress: '',
        deviceOS: '',
        browser: '',
        sentTime: 0,
      );
      await expectLater(
        AsgardeoPushAuth.instance
            .sendAuthResponse(badRequest, PushAuthResponseStatus.approved),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2002'),
        ),
      );
    });

    test('throws ASGPA-2003 for empty challenge', () async {
      const badRequest = PushAuthRequest(
        pushId: kPushId,
        challenge: '',
        deviceId: kDeviceId,
        username: kUsername,
        tenantDomain: kTenantDomain,
        userStoreDomain: 'PRIMARY',
        applicationName: 'App',
        notificationScenario: 'AUTHENTICATION',
        ipAddress: '',
        deviceOS: '',
        browser: '',
        sentTime: 0,
      );
      await expectLater(
        AsgardeoPushAuth.instance
            .sendAuthResponse(badRequest, PushAuthResponseStatus.approved),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2003'),
        ),
      );
    });

    test('throws ASGPA-3002 when account not found by deviceId', () async {
      const unknownRequest = PushAuthRequest(
        pushId: kPushId,
        challenge: kChallenge,
        deviceId: 'unknown-device',
        username: kUsername,
        tenantDomain: kTenantDomain,
        userStoreDomain: 'PRIMARY',
        applicationName: 'App',
        notificationScenario: 'AUTHENTICATION',
        ipAddress: '',
        deviceOS: '',
        browser: '',
        sentTime: 0,
      );
      await expectLater(
        AsgardeoPushAuth.instance.sendAuthResponse(
          unknownRequest,
          PushAuthResponseStatus.approved,
        ),
        throwsA(
          isA<AsgardeoAccountNotFoundException>()
              .having((e) => e.code, 'code', 'ASGPA-3002'),
        ),
      );
    });

    test('throws AsgardeoAuthResponseException on 4xx', () async {
      stubAuthPost(status: 403);
      await expectLater(
        AsgardeoPushAuth.instance.sendAuthResponse(
          kValidRequest,
          PushAuthResponseStatus.approved,
        ),
        throwsA(isA<AsgardeoAuthResponseException>()),
      );
    });
  });

  // ─── updateDevice ─────────────────────────────────────────────────────────

  group('updateDevice', () {
    setUp(seedAccount);

    void stubEditPost({int status = 204}) {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => AsgardeoHttpResponse(statusCode: status, body: '{}'),
      );
    }

    test('name only, HTTP 204 → completes normally', () async {
      stubEditPost();
      await expectLater(
        AsgardeoPushAuth.instance
            .updateDevice(kAccountId, name: 'New Name'),
        completes,
      );
    });

    test('pushToken only, HTTP 204 → completes normally', () async {
      stubEditPost();
      await expectLater(
        AsgardeoPushAuth.instance
            .updateDevice(kAccountId, pushToken: 'new-token'),
        completes,
      );
    });

    test('both provided, HTTP 204 → completes normally', () async {
      stubEditPost();
      await expectLater(
        AsgardeoPushAuth.instance.updateDevice(
          kAccountId,
          name: 'New Name',
          pushToken: 'new-token',
        ),
        completes,
      );
    });

    test('throws ASGPA-2006 for empty accountId', () async {
      await expectLater(
        AsgardeoPushAuth.instance
            .updateDevice('', name: 'Name'),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2006'),
        ),
      );
    });

    test('throws ASGPA-2007 when both params are null', () async {
      await expectLater(
        AsgardeoPushAuth.instance.updateDevice(kAccountId),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2007'),
        ),
      );
    });

    test('throws ASGPA-3001 when account not found', () async {
      await expectLater(
        AsgardeoPushAuth.instance
            .updateDevice('unknown-id', name: 'X'),
        throwsA(
          isA<AsgardeoAccountNotFoundException>()
              .having((e) => e.code, 'code', 'ASGPA-3001'),
        ),
      );
    });

    test('throws AsgardeoDeviceUpdateException on 5xx', () async {
      stubEditPost(status: 500);
      await expectLater(
        AsgardeoPushAuth.instance
            .updateDevice(kAccountId, name: 'X'),
        throwsA(isA<AsgardeoDeviceUpdateException>()),
      );
    });

    test('throws AsgardeoDeviceNotFoundException on PDH-15009', () async {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const AsgardeoHttpResponse(
          statusCode: 404,
          body: '{"code":"PDH-15009","message":"Device not found"}',
        ),
      );
      await expectLater(
        AsgardeoPushAuth.instance
            .updateDevice(kAccountId, name: 'X'),
        throwsA(isA<AsgardeoDeviceNotFoundException>()),
      );
    });
  });

  // ─── unregisterDevice ─────────────────────────────────────────────────────

  group('unregisterDevice', () {
    setUp(seedAccount);

    void stubUnregPost({int status = 204}) {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => AsgardeoHttpResponse(statusCode: status, body: '{}'),
      );
    }

    test('HTTP 204 → account, key pair, and history are removed', () async {
      // Also add a history record to verify it is cleared.
      await HistoryStore(storage)
          .addRecord(kAccountId, kValidRecord, maxItems: 10);

      stubUnregPost();
      await AsgardeoPushAuth.instance.unregisterDevice(kAccountId);

      verify(() => mockCrypto.deleteKeyPair(kDeviceId)).called(1);
      expect(
        await AccountStore(storage).findById(kAccountId),
        isNull,
      );
      expect(
        await HistoryStore(storage).getHistory(kAccountId),
        isEmpty,
      );
    });

    test('throws ASGPA-2006 for empty accountId', () async {
      await expectLater(
        AsgardeoPushAuth.instance.unregisterDevice(''),
        throwsA(
          isA<AsgardeoValidationException>()
              .having((e) => e.code, 'code', 'ASGPA-2006'),
        ),
      );
    });

    test('throws ASGPA-3001 when account not found', () async {
      await expectLater(
        AsgardeoPushAuth.instance.unregisterDevice('unknown-id'),
        throwsA(
          isA<AsgardeoAccountNotFoundException>()
              .having((e) => e.code, 'code', 'ASGPA-3001'),
        ),
      );
    });

    test('throws AsgardeoUnregistrationException on 5xx', () async {
      stubUnregPost(status: 500);
      await expectLater(
        AsgardeoPushAuth.instance.unregisterDevice(kAccountId),
        throwsA(isA<AsgardeoUnregistrationException>()),
      );
    });

    test('throws AsgardeoDeviceNotFoundException on PDH-15009', () async {
      when(
        () => mockHttp.post(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer(
        (_) async => const AsgardeoHttpResponse(
          statusCode: 404,
          body: '{"code":"PDH-15009","message":"Device not found"}',
        ),
      );
      await expectLater(
        AsgardeoPushAuth.instance.unregisterDevice(kAccountId),
        throwsA(isA<AsgardeoDeviceNotFoundException>()),
      );
    });
  });

  // ─── Account management ───────────────────────────────────────────────────

  group('account management', () {
    setUp(seedAccount);

    test('getAccounts() returns all stored accounts', () async {
      expect(
        await AsgardeoPushAuth.instance.getAccounts(),
        hasLength(1),
      );
    });

    test('getAccount(id) returns the matching account', () async {
      final account =
          await AsgardeoPushAuth.instance.getAccount(kAccountId);
      expect(account?.id, kAccountId);
    });

    test('getAccount(id) returns null when not found', () async {
      expect(
        await AsgardeoPushAuth.instance.getAccount('unknown'),
        isNull,
      );
    });

    test('getAccountByDeviceId() returns the matching account', () async {
      final account = await AsgardeoPushAuth.instance
          .getAccountByDeviceId(kDeviceId);
      expect(account?.deviceId, kDeviceId);
    });

    test('getAccountByDeviceId() returns null when not found', () async {
      expect(
        await AsgardeoPushAuth.instance
            .getAccountByDeviceId('unknown'),
        isNull,
      );
    });

    test('removeLocalAccount() deletes key pair, history, and account',
        () async {
      await HistoryStore(storage)
          .addRecord(kAccountId, kValidRecord, maxItems: 10);

      await AsgardeoPushAuth.instance.removeLocalAccount(kAccountId);

      verify(() => mockCrypto.deleteKeyPair(kDeviceId)).called(1);
      expect(
        await AccountStore(storage).findById(kAccountId),
        isNull,
      );
      expect(
        await HistoryStore(storage).getHistory(kAccountId),
        isEmpty,
      );
    });
  });

  // ─── Auth history ──────────────────────────────────────────────────────────

  group('getAuthHistory', () {
    test('returns stored records for the given account', () async {
      await HistoryStore(storage)
          .addRecord(kAccountId, kValidRecord, maxItems: 10);

      final history =
          await AsgardeoPushAuth.instance.getAuthHistory(kAccountId);
      expect(history, hasLength(1));
      expect(history.first.pushAuthId, kPushId);
    });
  });

  // ─── Retry logic ──────────────────────────────────────────────────────────

  group('retry logic', () {
    setUp(() {
      AsgardeoPushAuth.reset();
      (AsgardeoPushAuthBuilder()
            ..httpManager = mockHttp
            ..storageManager = storage
            ..cryptoEngine = mockCrypto
            ..deviceInfoProvider = mockDeviceInfo
            ..biometricPolicy = BiometricPolicy.disabled
            ..maxRetries = 1)
          .build();
    });

    test('5xx on first attempt is retried; succeeds on second', () {
      FakeAsync().run((fake) {
        var callCount = 0;
        when(
          () => mockHttp.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount < 2) {
            return const AsgardeoHttpResponse(statusCode: 503, body: '');
          }
          return const AsgardeoHttpResponse(statusCode: 201, body: '{}');
        });

        String? result;
        unawaited(
          AsgardeoPushAuth.instance
              .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider())
              .then((id) => result = id),
        );

        fake
          ..flushMicrotasks()
          ..elapse(const Duration(seconds: 1))
          ..flushMicrotasks();

        expect(result, isNotNull);
        expect(callCount, 2);
      });
    });

    test('network error on first attempt is retried; succeeds on second', () {
      FakeAsync().run((fake) {
        var callCount = 0;
        when(
          () => mockHttp.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          if (callCount < 2) throw Exception('connection reset');
          return const AsgardeoHttpResponse(statusCode: 201, body: '{}');
        });

        String? result;
        unawaited(
          AsgardeoPushAuth.instance
              .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider())
              .then((id) => result = id),
        );

        fake
          ..flushMicrotasks()
          ..elapse(const Duration(seconds: 1))
          ..flushMicrotasks();

        expect(result, isNotNull);
      });
    });

    test('4xx is not retried (returns immediately)', () {
      FakeAsync().run((fake) {
        var callCount = 0;
        when(
          () => mockHttp.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async {
          callCount++;
          return const AsgardeoHttpResponse(statusCode: 400, body: '{}');
        });

        Object? error;
        unawaited(
          AsgardeoPushAuth.instance
              .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider())
              .onError<Object>((e, _) { error = e; return ''; }),
        );

        fake.flushMicrotasks();

        // 4xx is not retried — only 1 call, no timer elapsed.
        expect(callCount, 1);
        expect(error, isA<AsgardeoRegistrationException>());
      });
    });

    test('all 5xx attempts exhausted → AsgardeoRegistrationException', () {
      FakeAsync().run((fake) {
        when(
          () => mockHttp.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer(
          (_) async =>
              const AsgardeoHttpResponse(statusCode: 503, body: ''),
        );

        Object? error;
        unawaited(
          AsgardeoPushAuth.instance
              .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider())
              .onError<Object>((e, _) { error = e; return ''; }),
        );

        fake
          ..flushMicrotasks()
          ..elapse(const Duration(seconds: 1))
          ..flushMicrotasks();

        // The final 5xx response is returned to registerDevice, which
        // throws AsgardeoRegistrationException (not AsgardeoNetworkException).
        // AsgardeoNetworkException is only thrown when all attempts throw
        // network-level exceptions (not HTTP errors).
        expect(error, isA<AsgardeoRegistrationException>());
      });
    });

    test('all network-exception attempts exhausted → AsgardeoNetworkException',
        () {
      FakeAsync().run((fake) {
        when(
          () => mockHttp.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenThrow(Exception('connection refused'));

        Object? error;
        unawaited(
          AsgardeoPushAuth.instance
              .registerDevice(kValidQrJson, kDeviceToken, FCMPushProvider())
              .onError<Object>((e, _) { error = e; return ''; }),
        );

        fake
          ..flushMicrotasks()
          ..elapse(const Duration(seconds: 1))
          ..flushMicrotasks();

        expect(error, isA<AsgardeoNetworkException>());
      });
    });
  });
}
