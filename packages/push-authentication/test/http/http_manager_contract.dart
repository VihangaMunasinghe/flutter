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

import 'package:asgardeo_push_auth/src/http/asgardeo_http_manager.dart';
import 'package:flutter_test/flutter_test.dart';

/// Callback that arranges the underlying mock to respond with
/// the given [statusCode] and [body] for the given HTTP [method].
typedef ArrangeResponse = void Function(
  String method,
  int statusCode,
  String body,
);

/// Shared contract tests for [AsgardeoHttpManager] implementations.
void runHttpManagerContractTests({
  required String implementationName,
  required AsgardeoHttpManager Function() subjectFactory,
  required ArrangeResponse arrangeResponse,
}) {
  group('AsgardeoHttpManager contract → $implementationName', () {
    const url = 'https://example.com/api';
    const headers = {'Authorization': 'Bearer token'};

    // ── GET ──────────────────────────────────────────────

    group('get', () {
      test('returns correct statusCode and body', () async {
        arrangeResponse('GET', 200, '{"ok":true}');
        final subject = subjectFactory();
        final response = await subject.get(url, headers: headers);
        expect(response.statusCode, 200);
        expect(response.body, '{"ok":true}');
      });
    });

    // ── POST ─────────────────────────────────────────────

    group('post', () {
      test('returns correct statusCode and body', () async {
        arrangeResponse('POST', 201, '{"id":"1"}');
        final subject = subjectFactory();
        final response = await subject.post(
          url,
          headers: headers,
          body: '{"name":"test"}',
        );
        expect(response.statusCode, 201);
        expect(response.body, '{"id":"1"}');
      });
    });

    // ── PUT ──────────────────────────────────────────────

    group('put', () {
      test('returns correct statusCode and body', () async {
        arrangeResponse('PUT', 200, '{"updated":true}');
        final subject = subjectFactory();
        final response = await subject.put(
          url,
          headers: headers,
          body: '{"name":"updated"}',
        );
        expect(response.statusCode, 200);
        expect(response.body, '{"updated":true}');
      });
    });

    // ── DELETE ────────────────────────────────────────────

    group('delete', () {
      test('returns correct statusCode and body', () async {
        arrangeResponse('DELETE', 204, '');
        final subject = subjectFactory();
        final response = await subject.delete(url, headers: headers);
        expect(response.statusCode, 204);
        expect(response.body, '');
      });
    });

    // ── PATCH ────────────────────────────────────────────

    group('patch', () {
      test('returns correct statusCode and body', () async {
        arrangeResponse('PATCH', 200, '{"patched":true}');
        final subject = subjectFactory();
        final response = await subject.patch(
          url,
          headers: headers,
          body: '{"field":"value"}',
        );
        expect(response.statusCode, 200);
        expect(response.body, '{"patched":true}');
      });
    });

    // ── dispose ──────────────────────────────────────────

    group('dispose', () {
      test('completes without error', () {
        final subject = subjectFactory();
        expect(subject.dispose, returnsNormally);
      });
    });
  });
}
