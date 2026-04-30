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

import 'package:asgardeo_push_auth/src/models/push_auth_account.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_record.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_request.dart';
import 'package:asgardeo_push_auth/src/models/registration_payload.dart';

// ─── Common field values ───────────────────────────────────────────────────

/// Device identifier used across tests.
const kDeviceId = 'device-001';

/// Challenge string used across tests.
const kChallenge = 'challenge-abc';

/// Username used across tests.
const kUsername = 'alice@example.com';

/// Asgardeo server host used across tests.
const kHost = 'https://api.asgardeo.io';

/// Tenant domain used across tests.
const kTenantDomain = 'myorg.com';

/// Organization ID used across tests.
const kOrgId = 'org-123';

/// Account ID used across tests.
const kAccountId = 'account-001';

/// Push notification ID used across tests.
const kPushId = 'push-001';

/// FCM device token used across tests.
const kDeviceToken = 'fcm-token-xyz';

// ─── JSON payloads ────────────────────────────────────────────────────────

/// Valid QR / discovery-data JSON (includes tenantDomain).
const kValidQrJson =
    '{"deviceId":"device-001","challenge":"challenge-abc",'
    '"username":"alice@example.com","host":"https://api.asgardeo.io",'
    '"tenantDomain":"myorg.com"}';

/// Server error response body.
const kServerErrorBody =
    '{"code":"ERR-001","message":"Something went wrong","traceId":"trace-abc"}';

/// Empty 201/204 response body.
const kEmptyBody = '{}';

// ─── Model instances ──────────────────────────────────────────────────────

/// A valid [PushAuthAccount] for use in tests.
const kValidAccount = PushAuthAccount(
  id: kAccountId,
  username: kUsername,
  displayName: kUsername,
  deviceId: kDeviceId,
  host: kHost,
  tenantDomain: kTenantDomain,
);

/// A valid [RegistrationPayload] for use in tests.
const kValidPayload = RegistrationPayload(
  deviceId: kDeviceId,
  challenge: kChallenge,
  username: kUsername,
  host: kHost,
  tenantDomain: kTenantDomain,
);

/// A valid [PushAuthRequest] with all required fields.
const kValidRequest = PushAuthRequest(
  pushId: kPushId,
  challenge: kChallenge,
  deviceId: kDeviceId,
  username: kUsername,
  tenantDomain: kTenantDomain,
  userStoreDomain: 'PRIMARY',
  applicationName: 'TestApp',
  notificationScenario: 'AUTHENTICATION',
  ipAddress: '192.168.1.1',
  deviceOS: 'iOS',
  browser: 'Safari',
  sentTime: 1000000,
);

/// A [PushAuthRecord] for use in tests.
const kValidRecord = PushAuthRecord(
  pushAuthId: kPushId,
  applicationName: 'TestApp',
  status: 'APPROVED',
  respondedTime: 1000000,
  ipAddress: '192.168.1.1',
  deviceOS: 'iOS',
  browser: 'Safari',
  accountId: kAccountId,
);
