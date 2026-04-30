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

import 'package:asgardeo_push_auth/src/internal/constants/error_codes.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_request.dart';
import 'package:asgardeo_push_auth/src/models/push_provider.dart';

/// Internal service for centralized input validation.
///
/// All validation methods throw [AsgardeoValidationException]
/// with a descriptive message and SDK error code on failure.
class ValidatorService {

  /// Validates that the QR payload contains required fields:
  /// `deviceId`, `challenge`, `username`, and `host`.
  static void validateQrPayload(Map<String, dynamic> json) {

    const requiredFields = ['deviceId', 'challenge', 'username', 'host'];

    for (final field in requiredFields) {
      final value = json[field];
      if (value == null || (value is String && value.isEmpty)) {
        throw AsgardeoValidationException(
          AsgardeoPushAuthErrorCode.missingQrField.format([field]),
          code: AsgardeoPushAuthErrorCode.missingQrField.code,
        );
      }
    }
  }

  /// Validates that the push notification data map contains all mandatory
  /// fields before it is parsed into a [PushAuthRequest].
  static void validatePushNotificationData(Map<String, dynamic> data) {

    const requiredFields = [
      'pushId',
      'challenge',
      'deviceId',
      'username',
      'userStoreDomain',
      'applicationName',
      'notificationScenario',
      'ipAddress',
      'deviceOS',
      'browser',
    ];

    for (final field in requiredFields) {
      final value = data[field];
      if (value == null || (value is String && value.isEmpty)) {
        throw AsgardeoValidationException(
          AsgardeoPushAuthErrorCode.missingPushNotificationField
              .format([field]),
          code:
              AsgardeoPushAuthErrorCode.missingPushNotificationField.code,
        );
      }
    }
  }

  /// Validates that the push authentication request has the minimum
  /// required fields to send a response.
  static void validateAuthRequest(PushAuthRequest request) {

    if (request.pushId.isEmpty) {
      throw AsgardeoValidationException(
        AsgardeoPushAuthErrorCode.missingPushId.message,
        code: AsgardeoPushAuthErrorCode.missingPushId.code,
      );
    }
    if (request.challenge.isEmpty) {
      throw AsgardeoValidationException(
        AsgardeoPushAuthErrorCode.missingChallenge.message,
        code: AsgardeoPushAuthErrorCode.missingChallenge.code,
      );
    }
    if (request.deviceId.isEmpty) {
      throw AsgardeoValidationException(
        AsgardeoPushAuthErrorCode.missingDeviceId.message,
        code: AsgardeoPushAuthErrorCode.missingDeviceId.code,
      );
    }
  }

  /// Validates that the push provider has a non-empty name.
  static void validatePushProvider(AsgardeoPushNotificationProvider provider) {

    if (provider.name.isEmpty) {
      throw AsgardeoValidationException(
        AsgardeoPushAuthErrorCode.emptyProviderName.message,
        code: AsgardeoPushAuthErrorCode.emptyProviderName.code,
      );
    }
  }

  /// Validates that the account ID is non-empty.
  static void validateAccountId(String accountId) {

    if (accountId.isEmpty) {
      throw AsgardeoValidationException(
        AsgardeoPushAuthErrorCode.emptyAccountId.message,
        code: AsgardeoPushAuthErrorCode.emptyAccountId.code,
      );
    }
  }

  /// Validates that at least one of [name] or [pushToken] is provided
  /// for a device edit operation.
  static void validateEditParams({String? name, String? pushToken}) {

    if ((name == null || name.isEmpty) &&
        (pushToken == null || pushToken.isEmpty)) {
      throw AsgardeoValidationException(
        AsgardeoPushAuthErrorCode.noEditParam.message,
        code: AsgardeoPushAuthErrorCode.noEditParam.code,
      );
    }
  }
}
