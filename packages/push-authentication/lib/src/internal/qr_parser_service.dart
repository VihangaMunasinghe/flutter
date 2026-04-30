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

import 'package:asgardeo_push_auth/src/internal/constants/error_codes.dart';
import 'package:asgardeo_push_auth/src/internal/validator_service.dart';
import 'package:asgardeo_push_auth/src/models/asgardeo_exception.dart';
import 'package:asgardeo_push_auth/src/models/registration_payload.dart';

/// Internal service for parsing push authentication QR code data.
///
/// The QR code is expected to contain a JSON payload with the fields
/// required for device registration.
class QrParserService {

  /// Parses a raw JSON string from a QR code into a [RegistrationPayload].
  ///
  /// Throws [AsgardeoValidationException] if the JSON is malformed
  /// or required fields are missing.
  static RegistrationPayload parse(String rawJson) {

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(rawJson) as Map<String, dynamic>;
    } on Object catch (e) {
      throw AsgardeoValidationException(
        AsgardeoPushAuthErrorCode.invalidQrJson.format([e.toString()]),
        code: AsgardeoPushAuthErrorCode.invalidQrJson.code,
        cause: e,
      );
    }

    ValidatorService.validateQrPayload(json);
    return RegistrationPayload.fromJson(json);
  }
}
