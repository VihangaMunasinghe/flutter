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

/// Validates a raw QR code string as an Asgardeo push authentication QR.
///
/// Returns the original [data] string if it is a valid push QR JSON payload,
/// or `null` if the QR is unrecognized or malformed.
///
/// The validated JSON string is passed directly to the SDK's
/// `registerDevice` method — no further parsing is needed at this layer.
String? validateQRData(String data) {
  try {
    final parsed = jsonDecode(data) as Map<String, dynamic>;
    const requiredFields = ['deviceId', 'username', 'host', 'challenge'];
    final hasAll = requiredFields.every(
      (f) => parsed.containsKey(f) && parsed[f] != null && parsed[f] != '',
    );
    return hasAll ? data : null;
  } on Object {
    return null;
  }
}
