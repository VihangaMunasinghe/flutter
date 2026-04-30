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
import 'dart:math' as math;

import 'package:asgardeo_push_auth/src/crypto/asgardeo_crypto_engine.dart';
import 'package:asgardeo_push_auth/src/crypto/secure_crypto_engine.dart';
import 'package:asgardeo_push_auth/src/device_info/asgardeo_device_info_provider.dart';
import 'package:asgardeo_push_auth/src/device_info/platform_device_info_provider.dart';
import 'package:asgardeo_push_auth/src/http/asgardeo_http_manager.dart';
import 'package:asgardeo_push_auth/src/http/http_client_manager.dart';
import 'package:asgardeo_push_auth/src/internal/account_store.dart';
import 'package:asgardeo_push_auth/src/internal/biometric_service.dart';
import 'package:asgardeo_push_auth/src/internal/constants/error_codes.dart';
import 'package:asgardeo_push_auth/src/internal/crypto_service.dart';
import 'package:asgardeo_push_auth/src/internal/history_store.dart';
import 'package:asgardeo_push_auth/src/internal/qr_parser_service.dart';
import 'package:asgardeo_push_auth/src/internal/url_builder_service.dart';
import 'package:asgardeo_push_auth/src/internal/validator_service.dart';
import 'package:asgardeo_push_auth/src/logging/asgardeo_logger.dart';
import 'package:asgardeo_push_auth/src/logging/default_logger.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:asgardeo_push_auth/src/models/biometric_policy.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_account.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_record.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_request.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_response_status.dart';
import 'package:asgardeo_push_auth/src/models/push_provider.dart';
import 'package:asgardeo_push_auth/src/storage/asgardeo_storage_manager.dart';
import 'package:asgardeo_push_auth/src/storage/shared_preferences_storage_manager.dart';

/// Default maximum number of auth history records kept per account.
const int kDefaultMaxHistoryRecords = 20;

/// JWT expiry offset for auth responses (10 minutes).
const int kAuthResponseExpirySeconds = 600;

/// JWT expiry offset for unregistration and edit tokens (5 minutes).
const int kTokenExpirySeconds = 300;

/// Singleton facade for the push authentication SDK.
///
/// Instances are created exclusively by [AsgardeoPushAuthBuilder].
/// All fields are final — the instance is immutable after construction.
class AsgardeoPushAuth {

  /// Creates a new instance from the [builder] configuration.
  ///
  /// Called only by [AsgardeoPushAuthBuilder.build].
  AsgardeoPushAuth._builder(AsgardeoPushAuthBuilder builder)
      : _httpManager = builder.httpManager ?? HttpClientManager(),
        _logger = builder.logger ??
            DefaultLogger(level: builder.logLevel ?? LogLevel.none),
        _maxHistoryRecords = builder.maxHistoryRecords,
        _maxRetries = builder.maxRetries,
        _crypto = CryptoService(
          builder.cryptoEngine ?? SecureCryptoEngine(),
          policy: builder.biometricPolicy,
          biometricService: BiometricService(),
          localizedReason: builder.biometricLocalizedReason,
        ),
        _deviceInfoProvider =
            builder.deviceInfoProvider ?? PlatformDeviceInfoProvider(),
        _accountStore = AccountStore(
          builder.storageManager ?? SharedPreferencesStorageManager(),
        ),
        _historyStore = HistoryStore(
          builder.storageManager ?? SharedPreferencesStorageManager(),
        );

  // ─── Singleton management ──────────────────────────────

  static AsgardeoPushAuth? _instance;

  /// Returns the initialized [AsgardeoPushAuth] singleton instance.
  ///
  /// Throws [AsgardeoNotInitializedException] if
  /// [AsgardeoPushAuthBuilder.build] has not been called.
  static AsgardeoPushAuth get instance {

    if (_instance == null) {
      throw AsgardeoNotInitializedException(
        AsgardeoPushAuthErrorCode.notInitialized.message,
        code: AsgardeoPushAuthErrorCode.notInitialized.code,
      );
    }
    return _instance!;
  }

  /// Whether the singleton has been initialized.
  static bool get isInitialized => _instance != null;

  /// Resets the singleton for re-initialization or testing.
  static void reset() {

    _instance?._httpManager.dispose();
    _instance = null;
  }

  // ─── Dependencies ──────────────────────────────────────

  final AsgardeoHttpManager _httpManager;
  final AsgardeoLogger _logger;
  final int _maxHistoryRecords;
  final int _maxRetries;
  final CryptoService _crypto;
  final AsgardeoDeviceInfoProvider _deviceInfoProvider;
  final AccountStore _accountStore;
  final HistoryStore _historyStore;

  // ─── Device Registration ───────────────────────────────

  /// Registers this device with the Asgardeo server using a QR code payload.
  ///
  /// Parses [qrCodeJson], generates an RSA key pair, signs the registration
  /// challenge, and submits the registration request to the server.
  ///
  /// Throws [AsgardeoDeviceAlreadyRegisteredException] if the user already
  /// has a registered account on this device or 
  /// [AsgardeoRegistrationException] if the request fails.
  ///
  /// ### Parameters:
  /// * [qrCodeJson]: The raw JSON string scanned from the registration QR code.
  /// * [deviceToken]: The push notification token issued by the push provider.
  /// * [provider]: The push notification provider for this device
  ///   (e.g. `FCMPushProvider`, `AmazonSNSPushProvider`).
  ///
  /// ### Example:
  /// ```dart
  /// final accountId = await AsgardeoPushAuth.instance.registerDevice(
  ///   qrCodeJson,
  ///   deviceToken,
  ///   FCMPushProvider(),
  /// );
  /// ```
  Future<String> registerDevice(
    String qrCodeJson,
    String deviceToken,
    AsgardeoPushNotificationProvider provider,
  ) async {

    _logger.debug('Starting device registration.');

    ValidatorService.validatePushProvider(provider);
    final payload = QrParserService.parse(qrCodeJson);

    // Reject if an account already exists for this user.
    final existingAccount =
        await _accountStore.findMatchingAccount(payload);
    if (existingAccount != null) {
      _logger.error(
        'Account already registered for user "${payload.username}".',
      );
      throw AsgardeoDeviceAlreadyRegisteredException(
        AsgardeoPushAuthErrorCode.accountAlreadyRegistered
            .format([payload.username]),
        code: AsgardeoPushAuthErrorCode.accountAlreadyRegistered.code,
      );
    }

    // Generate key pair — public key returned, private key stored in hardware.
    final publicKeyBase64 =
        await _crypto.generateKeyPairAndGetPublicKeyBase64(payload.deviceId);
    _logger.debug('Key pair generated for device "${payload.deviceId}".');

    try {
      // Sign the registration challenge.
      final signature = await _crypto.generateChallengeSignature(
        payload.challenge,
        deviceToken,
        payload.deviceId,
      );

      final deviceInfo = await _deviceInfoProvider.getDeviceInfo();

      final registrationUrl = UrlBuilderService.buildRegistrationUrl(
        host: payload.host,
        tenantDomain: payload.tenantDomain,
        organizationId: payload.organizationId,
      );

      final body = jsonEncode({
        'deviceId': payload.deviceId,
        'name': deviceInfo.name,
        'model': deviceInfo.model,
        'deviceToken': deviceToken,
        'publicKey': publicKeyBase64,
        'signature': signature,
        'provider': provider.toJson(),
      });

      _logger.debug('Sending registration request to $registrationUrl.');

      final response = await _post(
        registrationUrl,
        body: body,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 201) {
        final errorResponse = _parseErrorResponse(response.body);
        final message = errorResponse?.message ??
            AsgardeoPushAuthErrorCode.requestFailed
                .format(['Registration', '${response.statusCode}']);

        _logger.error(message);
        throw AsgardeoRegistrationException(
          message,
          code: errorResponse?.code,
          traceId: errorResponse?.traceId,
        );
      }

      // Save new account in local storage.
      final accountId = _crypto.generateRandomId();
      final newAccount = PushAuthAccount(
        id: accountId,
        username: payload.username,
        displayName: payload.username,
        deviceId: payload.deviceId,
        host: payload.host,
        tenantDomain: payload.tenantDomain,
        organizationId: payload.organizationId,
        organizationName: payload.organizationName,
        userStoreDomain: payload.userStoreDomain,
      );
      await _accountStore.saveAccount(newAccount);

      _logger.info('Device registered. Account ID: $accountId.');
      return accountId;
    } catch (e) {
      // Clean up the generated key pair on any failure.
      _logger.debug(
        'Registration failed, cleaning up key pair for '
        '"${payload.deviceId}".',
      );
      await _crypto.deleteKeyPair(payload.deviceId);
      rethrow;
    }
  }

  /// Registers this device with the Asgardeo server using an OAuth2 access
  /// token.
  ///
  /// Fetches the registration payload from the server's discovery-data endpoint
  /// and completes enrollment without requiring a QR code scan.
  ///
  /// Throws [AsgardeoDeviceAlreadyRegisteredException] if the user already
  /// has a registered account on this device or 
  /// [AsgardeoRegistrationException] if the request fails.
  ///
  /// ### Parameters:
  /// * [baseUrl]: The Asgardeo server base URL.
  /// * [accessToken]: A valid OAuth2 Bearer token for the authenticated user.
  /// * [deviceToken]: The push notification token issued by the push provider.
  /// * [provider]: The push notification provider for this device
  ///   (e.g. `FCMPushProvider`, `AmazonSNSPushProvider`).
  ///
  /// ### Example:
  /// ```dart
  /// final accountId = await AsgardeoPushAuth.instance.registerDeviceWithToken(
  ///   'https://api.asgardeo.io/t/myorg',
  ///   accessToken,
  ///   deviceToken,
  ///   FCMPushProvider(),
  /// );
  /// ```
  Future<String> registerDeviceWithToken(
    String baseUrl,
    String accessToken,
    String deviceToken,
    AsgardeoPushNotificationProvider provider,
  ) async {

    _logger.debug('Fetching push discovery data from $baseUrl.');

    final url = UrlBuilderService.buildDiscoveryDataUrl(baseUrl: baseUrl);
    final response = await _get(
      url,
      headers: {'Authorization': 'Bearer $accessToken'},
    );

    if (response.statusCode != 200) {
      final errorResponse = _parseErrorResponse(response.body);
      final message = errorResponse?.message ??
          AsgardeoPushAuthErrorCode.requestFailed
              .format(['Discovery data fetch', '${response.statusCode}']);
      _logger.error(message);
      throw AsgardeoRegistrationException(
        message,
        code: errorResponse?.code,
        traceId: errorResponse?.traceId,
      );
    }

    return registerDevice(response.body, deviceToken, provider);
  }

  // ─── Push Notification Parsing ─────────────────────────

  /// Parses raw push notification data into a typed [PushAuthRequest].
  ///
  /// Returns `null` if [data] does not belong to an Asgardeo push auth
  /// request, making this method suitable for filtering notifications in a
  /// shared handler.
  ///
  /// ### Parameters:
  /// * [data]: The notification payload map received from the push provider.
  /// * [sentTime]: The optional epoch-millisecond timestamp when the
  ///   notification was sent; used to calculate request age.
  ///
  /// ### Example:
  /// ```dart
  /// final request = AsgardeoPushAuth.instance.parsePushNotification(
  ///   message.data,
  ///   sentTime: message.sentTime,
  /// );
  /// if (request != null) {
  ///   // Handle the auth request.
  /// }
  /// ```
  PushAuthRequest? parsePushNotification(
    Map<String, dynamic> data, {
    int? sentTime,
  }) {

    _logger.debug('Parsing push notification data.');

    // FCM: pushId at the root level.
    if (data.containsKey('pushId')) {
      return _parseAndValidate(data, sentTime: sentTime);
    }

    // APNS: data nested under the 'data' key.
    final authData = data['data'];
    if (authData is Map && authData.containsKey('pushId')) {
      return _parseAndValidate(
        Map<String, dynamic>.from(authData),
        sentTime: sentTime,
      );
    }

    _logger.debug('Unrecognised push notification structure — ignoring.');
    return null;
  }

  // ─── Auth Response ─────────────────────────────────────

  /// Sends an approve or deny response for a pending push authentication
  /// request.
  ///
  /// Constructs and signs a JWT containing the user's decision and submits it
  /// to the Asgardeo authentication endpoint.
  /// Throws [AsgardeoAuthResponseException] if the request fails.
  ///
  /// ### Parameters:
  /// * [request]: The [PushAuthRequest] received from the push notification.
  /// * [status]: The user's decision — [PushAuthResponseStatus.approved] or
  ///   [PushAuthResponseStatus.denied].
  /// * [selectedNumber]: The number selected by the user; optional, and only
  ///   applicable when the number challenge is enabled for this request.
  ///
  /// ### Example:
  /// ```dart
  /// await AsgardeoPushAuth.instance.sendAuthResponse(
  ///   request,
  ///   PushAuthResponseStatus.approved,
  ///   selectedNumber: 42,
  /// );
  /// ```
  Future<void> sendAuthResponse(
    PushAuthRequest request,
    PushAuthResponseStatus status, {
    int? selectedNumber,
  }) async {

    _logger.debug(
      'Sending ${status.name} response for pushId "${request.pushId}".',
    );

    ValidatorService.validateAuthRequest(request);

    // Look up the account to get the host for URL construction.
    final account = await _accountStore.findByDeviceId(request.deviceId);
    if (account == null) {
      throw AsgardeoAccountNotFoundException(
        AsgardeoPushAuthErrorCode.accountNotFoundByDeviceId
            .format([request.deviceId]),
        code: AsgardeoPushAuthErrorCode.accountNotFoundByDeviceId.code,
      );
    }

    final header = <String, dynamic>{
      'alg': 'RS256',
      'typ': 'JWT',
      'deviceId': request.deviceId,
    };

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body = <String, dynamic>{
      'pushAuthId': request.pushId,
      'challenge': request.challenge,
      'response': status.name.toUpperCase(),
      'exp': now + kAuthResponseExpirySeconds,
    };

    if (status == PushAuthResponseStatus.approved && selectedNumber != null) {
      body['numberChallenge'] = selectedNumber.toString();
    }

    final jwt = await _crypto.generateSignedJwt(
      header,
      body,
      request.deviceId,
    );

    final authUrl = UrlBuilderService.buildAuthenticateUrl(
      host: account.host,
      relativePath: request.relativePath,
      tenantDomain: request.tenantDomain,
      organizationId: request.organizationId,
    );

    _logger.debug('Sending auth response to $authUrl.');

    final response = await _post(
      authUrl,
      body: jsonEncode({'authResponse': jwt}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 202) {
      final errorResponse = _parseErrorResponse(response.body);
      final message = errorResponse?.message ??
          AsgardeoPushAuthErrorCode.requestFailed
              .format(['Auth response', '${response.statusCode}']);

      _logger.error(message);
      throw AsgardeoAuthResponseException(
        message,
        code: errorResponse?.code,
        traceId: errorResponse?.traceId,
      );
    }

    // Record auth history.
    final record = PushAuthRecord(
      pushAuthId: request.pushId,
      applicationName: request.applicationName,
      status: status.name.toUpperCase(),
      respondedTime: DateTime.now().millisecondsSinceEpoch,
      ipAddress: request.ipAddress,
      deviceOS: request.deviceOS,
      browser: request.browser,
      accountId: account.id,
    );

    await _historyStore.addRecord(
      account.id,
      record,
      maxItems: _maxHistoryRecords,
    );

    _logger.info(
      'Auth response sent. Status: ${status.name.toUpperCase()}.',
    );
  }

  // ─── Device Update ─────────────────────────────────────

  /// Updates the registered device's display name or push token on the server.
  ///
  /// At least one of [name] or [pushToken] must be provided.
  /// Throws [AsgardeoDeviceUpdateException] if the update fails, or
  /// [AsgardeoDeviceNotFoundException] if the device no longer exists.
  ///
  /// ### Parameters:
  /// * [accountId]: The ID of the account whose device to update.
  /// * [name]: The new display name for the device.
  /// * [pushToken]: The refreshed push notification token for the device.
  ///
  /// ### Example:
  /// ```dart
  /// await AsgardeoPushAuth.instance.updateDevice(
  ///   accountId,
  ///   pushToken: newToken,
  /// );
  /// ```
  Future<void> updateDevice(
    String accountId, {
    String? name,
    String? pushToken,
  }) async {

    _logger.debug('Updating device for account "$accountId".');

    ValidatorService.validateAccountId(accountId);
    ValidatorService.validateEditParams(name: name, pushToken: pushToken);

    final account = await _accountStore.findById(accountId);
    if (account == null) {
      throw AsgardeoAccountNotFoundException(
        AsgardeoPushAuthErrorCode.accountNotFoundById.format([accountId]),
        code: AsgardeoPushAuthErrorCode.accountNotFoundById.code,
      );
    }

    final header = <String, dynamic>{'alg': 'RS256', 'typ': 'JWT'};
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body = <String, dynamic>{
      'exp': now + kTokenExpirySeconds,
    };
    if (name != null) body['name'] = name;
    if (pushToken != null) body['deviceToken'] = pushToken;

    final jwt = await _crypto.generateSignedJwt(
      header,
      body,
      account.deviceId,
    );

    final editUrl = UrlBuilderService.buildEditUrl(
      host: account.host,
      deviceId: account.deviceId,
      tenantDomain: account.tenantDomain,
      organizationId: account.organizationId,
    );

    final response = await _post(
      editUrl,
      body: jsonEncode({'token': jwt}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 204) {
      final errorResponse = _parseErrorResponse(response.body);
      final message = errorResponse?.message ??
          AsgardeoPushAuthErrorCode.requestFailed
              .format(['Device update', '${response.statusCode}']);

      _logger.error(message);

      if (errorResponse?.code == 'PDH-15009') {
        throw AsgardeoDeviceNotFoundException(
          message,
          code: errorResponse?.code,
          traceId: errorResponse?.traceId,
        );
      }
      throw AsgardeoDeviceUpdateException(
        message,
        code: errorResponse?.code,
        traceId: errorResponse?.traceId,
      );
    }

    _logger.info('Device updated for account "$accountId".');
  }

  // ─── Device Unregistration ─────────────────────────────

  /// Unregisters this device from the Asgardeo server and removes all
  /// associated local data.
  ///
  /// Throws [AsgardeoUnregistrationException] if the server request fails, or
  /// [AsgardeoDeviceNotFoundException] if the device no longer exists.
  ///
  /// ### Parameters:
  /// * [accountId]: The ID of the account to unregister.
  ///
  /// ### Example:
  /// ```dart
  /// await AsgardeoPushAuth.instance.unregisterDevice(accountId);
  /// ```
  Future<void> unregisterDevice(String accountId) async {

    _logger.debug('Unregistering device for account "$accountId".');

    ValidatorService.validateAccountId(accountId);

    final account = await _accountStore.findById(accountId);
    if (account == null) {
      throw AsgardeoAccountNotFoundException(
        AsgardeoPushAuthErrorCode.accountNotFoundById.format([accountId]),
        code: AsgardeoPushAuthErrorCode.accountNotFoundById.code,
      );
    }

    final header = <String, dynamic>{'alg': 'RS256', 'typ': 'JWT'};
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final body = <String, dynamic>{
      'exp': now + kTokenExpirySeconds,
    };

    final jwt = await _crypto.generateSignedJwt(
      header,
      body,
      account.deviceId,
    );

    final unregUrl = UrlBuilderService.buildUnregistrationUrl(
      host: account.host,
      deviceId: account.deviceId,
      tenantDomain: account.tenantDomain,
      organizationId: account.organizationId,
    );

    final response = await _post(
      unregUrl,
      body: jsonEncode({'token': jwt}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 204) {
      final errorResponse = _parseErrorResponse(response.body);
      final message = errorResponse?.message ??
          AsgardeoPushAuthErrorCode.requestFailed
              .format(['Unregistration', '${response.statusCode}']);

      _logger.error(message);

      if (errorResponse?.code == 'PDH-15009') {
        throw AsgardeoDeviceNotFoundException(
          message,
          code: errorResponse?.code,
          traceId: errorResponse?.traceId,
        );
      }
      throw AsgardeoUnregistrationException(
        message,
        code: errorResponse?.code,
        traceId: errorResponse?.traceId,
      );
    }

    // Clean up local data.
    await _crypto.deleteKeyPair(account.deviceId);
    await _historyStore.clearHistory(accountId);
    await _accountStore.removeAccount(accountId);

    _logger.info('Device unregistered for account "$accountId".');
  }

  // ─── Account Management ────────────────────────────────

  /// Returns all locally stored [PushAuthAccount] records.
  ///
  /// ### Example:
  /// ```dart
  /// final accounts = await AsgardeoPushAuth.instance.getAccounts();
  /// ```
  Future<List<PushAuthAccount>> getAccounts() async {

    return _accountStore.getAccounts();
  }

  /// Returns the [PushAuthAccount] with the given [accountId], or `null`.
  ///
  /// ### Parameters:
  /// * [accountId]: The ID of the account to look up.
  ///
  /// ### Example:
  /// ```dart
  /// final account = await AsgardeoPushAuth.instance.getAccount(accountId);
  /// ```
  Future<PushAuthAccount?> getAccount(String accountId) async {

    return _accountStore.findById(accountId);
  }

  /// Returns the [PushAuthAccount] associated with [deviceId], or `null`.
  ///
  /// ### Parameters:
  /// * [deviceId]: The device ID assigned by the server during registration.
  ///
  /// ### Example:
  /// ```dart
  /// final account = await AsgardeoPushAuth.instance
  ///     .getAccountByDeviceId(deviceId);
  /// ```
  Future<PushAuthAccount?> getAccountByDeviceId(String deviceId) async {

    return _accountStore.findByDeviceId(deviceId);
  }

  /// Removes the local account and all associated data without contacting
  /// the server.
  ///
  /// Use [unregisterDevice] to also remove the device from the server.
  ///
  /// ### Parameters:
  /// * [accountId]: The ID of the account to remove.
  ///
  /// ### Example:
  /// ```dart
  /// await AsgardeoPushAuth.instance.removeLocalAccount(accountId);
  /// ```
  Future<void> removeLocalAccount(String accountId) async {

    _logger.debug('Removing local account data for "$accountId".');

    ValidatorService.validateAccountId(accountId);

    final account = await _accountStore.findById(accountId);
    if (account != null) {
      await _crypto.deleteKeyPair(account.deviceId);
    }
    await _historyStore.clearHistory(accountId);
    await _accountStore.removeAccount(accountId);

    _logger.info('Local account data removed for "$accountId".');
  }

  // ─── Auth History ──────────────────────────────────────

  /// Returns the push authentication history for the given [accountId].
  ///
  /// ### Parameters:
  /// * [accountId]: The ID of the account whose history to retrieve.
  ///
  /// ### Example:
  /// ```dart
  /// final history = await AsgardeoPushAuth.instance.getAuthHistory(accountId);
  /// ```
  Future<List<PushAuthRecord>> getAuthHistory(String accountId) async {

    return _historyStore.getHistory(accountId);
  }

  // ─── Private Helpers ───────────────────────────────────

  /// Validates [data] and parses it into a [PushAuthRequest].
  ///
  /// Returns `null` if validation fails.
  PushAuthRequest? _parseAndValidate(
    Map<String, dynamic> data, {
    int? sentTime,
  }) {
    try {
      ValidatorService.validatePushNotificationData(data);
    } on AsgardeoValidationException catch (e) {
      _logger.debug('Invalid push notification data — ignoring. ${e.message}');
      return null;
    }
    return PushAuthRequest.fromJson(data, sentTime: sentTime);
  }

  /// Parses an error response body from the server.
  ///
  /// Returns `null` if the body is not valid JSON or missing fields.
  static ({String code, String message, String? traceId})?
      _parseErrorResponse(String responseBody) {

    try {
      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return (
        code: json['code'] as String,
        message: json['message'] as String,
        traceId: json['traceId'] as String?,
      );
    } on Object {
      return null;
    }
  }

  /// Sends an HTTP request with retry logic for transient failures.
  ///
  /// Retries on network errors and 5xx responses up to [_maxRetries] times
  /// with exponential backoff. Does not retry 4xx responses.
  Future<AsgardeoHttpResponse> _sendRequest(
    Future<AsgardeoHttpResponse> Function() request,
    String url,
  ) async {

    Object? lastError;

    for (var attempt = 0; attempt <= _maxRetries; attempt++) {
      if (attempt > 0) {
        _logger.debug('Retrying request to "$url" (attempt ${attempt + 1}).');
        await Future<void>.delayed(
          Duration(seconds: math.pow(2, attempt - 1).toInt()),
        );
      }

      try {
        final response = await request();

        // Retry on 5xx server errors (not on final attempt).
        if (response.statusCode >= 500 && attempt < _maxRetries) {
          _logger.debug(
            'Server error ${response.statusCode}, will retry.',
          );
          lastError = 'Server error ${response.statusCode}';
          continue;
        }

        return response;
      } catch (e) {
        if (e is AsgardeoException) rethrow;
        lastError = e;
        if (attempt < _maxRetries) {
          _logger.debug('Network error, will retry.');
          continue;
        }
      }
    }

    throw AsgardeoNetworkException(
      AsgardeoPushAuthErrorCode.networkFailure
          .format([url, '${_maxRetries + 1}']),
      code: AsgardeoPushAuthErrorCode.networkFailure.code,
      cause: lastError,
    );
  }

  /// Sends an HTTP GET with retry.
  Future<AsgardeoHttpResponse> _get(
    String url, {
    required Map<String, String> headers,
  }) =>
      _sendRequest(
        () => _httpManager.get(url, headers: headers),
        url,
      );

  /// Sends an HTTP POST with retry.
  Future<AsgardeoHttpResponse> _post(
    String url, {
    required String body,
    required Map<String, String> headers,
  }) =>
      _sendRequest(
        () => _httpManager.post(url, headers: headers, body: body),
        url,
      );
}

/// Builder for initializing the [AsgardeoPushAuth] singleton.
///
/// All configuration is optional — sensible defaults are provided.
/// Call [build] to finalize initialization. The resulting singleton
/// is immutable; calling [build] again without [AsgardeoPushAuth.reset]
/// throws [AsgardeoAlreadyInitializedException].
///
/// ```dart
/// (AsgardeoPushAuthBuilder()
///     ..logLevel = LogLevel.debug
///     ..maxHistoryRecords = 50)
///   .build();
/// ```
class AsgardeoPushAuthBuilder {

  /// Custom HTTP manager. Uses `HttpClientManager` if not set.
  AsgardeoHttpManager? httpManager;

  /// Custom storage manager. Uses `SharedPreferencesStorageManager` if not set.
  AsgardeoStorageManager? storageManager;

  /// Custom crypto engine. Uses [SecureCryptoEngine] if not set.
  AsgardeoCryptoEngine? cryptoEngine;

  /// Custom device info provider. Uses `PlatformDeviceInfoProvider` if not set.
  AsgardeoDeviceInfoProvider? deviceInfoProvider;

  /// Custom logger. Uses `DefaultLogger` if not set.
  AsgardeoLogger? logger;

  /// Log level for the default logger. Ignored if a custom [logger] is set.
  LogLevel? logLevel;

  /// Biometric gate policy applied before every private-key operation.
  ///
  /// Defaults to [BiometricPolicy.enabled] — the user is prompted when the
  /// device supports biometric or device-credential authentication.
  BiometricPolicy biometricPolicy = BiometricPolicy.enabled;

  /// Reason string displayed in the biometric prompt dialog.
  ///
  /// Defaults to a generic action confirmation message.
  String biometricLocalizedReason = 'Authenticate to confirm this action';


  /// Max auth history records per account.
  int maxHistoryRecords = kDefaultMaxHistoryRecords;

  /// Max retry attempts for transient network errors and 5xx responses.
  ///
  /// Default is `1` (2 total attempts). Set to `0` to disable retries.
  int maxRetries = 1;

  /// Builds and returns the initialized [AsgardeoPushAuth] singleton.
  ///
  /// Unset properties default to their built-in implementations.
  /// Throws [AsgardeoAlreadyInitializedException] if the package is already
  /// initialized; call [AsgardeoPushAuth.reset] first.
  ///
  /// ### Example:
  /// ```dart
  /// (AsgardeoPushAuthBuilder()
  ///     ..logLevel = LogLevel.debug)
  ///   .build();
  /// ```
  AsgardeoPushAuth build() {

    if (AsgardeoPushAuth.isInitialized) {
      throw AsgardeoAlreadyInitializedException(
        AsgardeoPushAuthErrorCode.alreadyInitialized.message,
        code: AsgardeoPushAuthErrorCode.alreadyInitialized.code,
      );
    }

    final instance = AsgardeoPushAuth._builder(this);
    AsgardeoPushAuth._instance = instance;
    instance._logger.info('SDK initialized successfully.');
    return instance;
  }
}
