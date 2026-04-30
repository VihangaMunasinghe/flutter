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

import 'package:asgardeo_push_auth/src/models/push_auth_record.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';

void main() {
  group('PushAuthRecord', () {
    // ── fromJson / toJson round-trip ───────────────────────

    test('round-trip preserves all fields', () {
      final json = kValidRecord.toJson();
      final restored = PushAuthRecord.fromJson(json);
      expect(restored.pushAuthId, kValidRecord.pushAuthId);
      expect(restored.applicationName, kValidRecord.applicationName);
      expect(restored.status, kValidRecord.status);
      expect(restored.respondedTime, kValidRecord.respondedTime);
      expect(restored.ipAddress, kValidRecord.ipAddress);
      expect(restored.deviceOS, kValidRecord.deviceOS);
      expect(restored.browser, kValidRecord.browser);
      expect(restored.accountId, kValidRecord.accountId);
    });

    test('missing optional fields default to empty string', () {
      final record = PushAuthRecord.fromJson({
        'pushAuthId': kPushId,
        'status': 'APPROVED',
        'respondedTime': 1000000,
      });
      expect(record.applicationName, '');
      expect(record.ipAddress, '');
      expect(record.deviceOS, '');
      expect(record.browser, '');
      expect(record.accountId, '');
    });
  });
}
