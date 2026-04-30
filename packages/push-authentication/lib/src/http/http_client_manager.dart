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
import 'package:http/http.dart' as http;

/// [AsgardeoHttpManager] implementation using the `http` package.
class HttpClientManager implements AsgardeoHttpManager {

  /// Creates an [HttpClientManager].
  ///
  /// An optional pre-configured [client] can be provided.
  HttpClientManager({http.Client? client}) : _client = client;

  http.Client? _client;

  http.Client get _httpClient => _client ??= http.Client();

  @override
  Future<AsgardeoHttpResponse> get(
    String url, {
    Map<String, String>? headers,
  }) async {

    final response = await _httpClient.get(
      Uri.parse(url),
      headers: headers,
    );

    return AsgardeoHttpResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  @override
  Future<AsgardeoHttpResponse> post(
    String url, {
    Map<String, String>? headers,
    String? body,
  }) async {

    final response = await _httpClient.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return AsgardeoHttpResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  @override
  Future<AsgardeoHttpResponse> put(
    String url, {
    Map<String, String>? headers,
    String? body,
  }) async {

    final response = await _httpClient.put(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return AsgardeoHttpResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  @override
  Future<AsgardeoHttpResponse> delete(
    String url, {
    Map<String, String>? headers,
  }) async {

    final response = await _httpClient.delete(
      Uri.parse(url),
      headers: headers,
    );

    return AsgardeoHttpResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  @override
  Future<AsgardeoHttpResponse> patch(
    String url, {
    Map<String, String>? headers,
    String? body,
  }) async {

    final response = await _httpClient.patch(
      Uri.parse(url),
      headers: headers,
      body: body,
    );

    return AsgardeoHttpResponse(
      statusCode: response.statusCode,
      body: response.body,
    );
  }

  @override
  void dispose() {

    _client?.close();
    _client = null;
  }
}
