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

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';

/// A mock [AsgardeoHttpManager] for the example app.
///
/// Returns hardcoded success responses for each SDK endpoint so the
/// full registration → approve/deny → unregistration flow works
/// without a real Asgardeo server.
///
/// URL → status code mapping:
///
/// | Endpoint                         | Status |
/// |----------------------------------|--------|
/// | `/api/users/v1/me/push/devices`  | 201    |
/// | `/push-auth/authenticate`        | 200    |
/// | `.../devices/{id}/update`        | 204    |
/// | `.../devices/{id}/remove`        | 204    |
/// | Any other                        | 200    |
class MockHttpManager implements AsgardeoHttpManager {
  AsgardeoHttpResponse _respond(String url) {
    if (url.contains('/push/devices') &&
        !url.contains('/update') &&
        !url.contains('/remove')) {
      return const AsgardeoHttpResponse(statusCode: 201, body: '{}');
    }
    if (url.contains('/authenticate')) {
      return const AsgardeoHttpResponse(statusCode: 200, body: '{}');
    }
    if (url.contains('discovery-data')) {
      // Simulates the discovery-data endpoint response used by
      // registerDeviceWithToken. The body is passed directly to
      // registerDevice as QR JSON, so it must match the QR format.
      return const AsgardeoHttpResponse(
        statusCode: 200,
        body: '{"deviceId":"mock-device-001","challenge":"bW9jaw==",'
            '"username":"alice@example.com","host":"mock.asgardeo.io",'
            '"tenantDomain":"mock-org"}',
      );
    }
    // /update and /remove endpoints.
    return const AsgardeoHttpResponse(statusCode: 204, body: '');
  }

  @override
  Future<AsgardeoHttpResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async =>
      _respond(url);

  @override
  Future<AsgardeoHttpResponse> post(
    String url, {
    Map<String, String>? headers,
    String? body,
  }) async =>
      _respond(url);

  @override
  Future<AsgardeoHttpResponse> put(
    String url, {
    Map<String, String>? headers,
    String? body,
  }) async =>
      _respond(url);

  @override
  Future<AsgardeoHttpResponse> delete(
    String url, {
    Map<String, String>? headers,
  }) async =>
      _respond(url);

  @override
  Future<AsgardeoHttpResponse> patch(
    String url, {
    Map<String, String>? headers,
    String? body,
  }) async =>
      _respond(url);

  @override
  void dispose() {}
}
