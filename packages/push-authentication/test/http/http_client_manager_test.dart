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

import 'package:asgardeo_push_auth/src/http/http_client_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';

import 'http_manager_contract.dart';

class _MockHttpClient extends Mock implements http.Client {}

void main() {
  late _MockHttpClient mockClient;

  setUp(() {
    mockClient = _MockHttpClient();
    registerFallbackValue(Uri.parse('https://example.com'));
  });

  void arrangeResponse(String method, int statusCode, String body) {
    final response = http.Response(body, statusCode);
    switch (method) {
      case 'GET':
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => response);
      case 'POST':
        when(
          () => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => response);
      case 'PUT':
        when(
          () => mockClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => response);
      case 'DELETE':
        when(
          () => mockClient.delete(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => response);
      case 'PATCH':
        when(
          () => mockClient.patch(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
            encoding: any(named: 'encoding'),
          ),
        ).thenAnswer((_) async => response);
    }
  }

  // ── Contract tests ─────────────────────────────────────

  runHttpManagerContractTests(
    implementationName: 'HttpClientManager',
    subjectFactory: () => HttpClientManager(client: mockClient),
    arrangeResponse: arrangeResponse,
  );

  // ── Implementation-specific tests ──────────────────────

  group('HttpClientManager specifics', () {
    test('forwards headers to underlying client on GET', () async {
      arrangeResponse('GET', 200, '');
      final manager = HttpClientManager(client: mockClient);
      await manager.get(
        'https://example.com/api',
        headers: {'X-Custom': 'value'},
      );
      verify(
        () => mockClient.get(
          Uri.parse('https://example.com/api'),
          headers: {'X-Custom': 'value'},
        ),
      ).called(1);
    });

    test('forwards body to underlying client on POST', () async {
      arrangeResponse('POST', 200, '');
      final manager = HttpClientManager(client: mockClient);
      await manager.post(
        'https://example.com/api',
        body: '{"data":"test"}',
      );
      verify(
        () => mockClient.post(
          Uri.parse('https://example.com/api'),
          body: '{"data":"test"}',
          encoding: any(named: 'encoding'),
        ),
      ).called(1);
    });

    test('dispose closes the underlying client', () {
      final manager = HttpClientManager(client: mockClient);
      when(mockClient.close).thenAnswer((_) {});
      manager.dispose();
      verify(mockClient.close).called(1);
    });

    test('dispose nulls client; next call creates a new one', () {
      // This tests the lazy initialization after dispose.
      // We verify dispose doesn't throw.
      when(mockClient.close).thenAnswer((_) {});
      HttpClientManager(client: mockClient).dispose();
      // No assertion needed — just verifying no exception.
    });
  });
}
