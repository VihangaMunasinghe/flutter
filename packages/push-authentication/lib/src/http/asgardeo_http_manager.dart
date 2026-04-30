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

/// Interface for HTTP operations used by the SDK.
abstract class AsgardeoHttpManager {

  /// Sends an HTTP GET request to the given [url].
  Future<AsgardeoHttpResponse> get(
    String url, {
    Map<String, String>? headers,
  });

  /// Sends an HTTP POST request to the given [url].
  Future<AsgardeoHttpResponse> post(
    String url, {
    Map<String, String>? headers,
    String? body,
  });

  /// Sends an HTTP PUT request to the given [url].
  Future<AsgardeoHttpResponse> put(
    String url, {
    Map<String, String>? headers,
    String? body,
  });

  /// Sends an HTTP DELETE request to the given [url].
  Future<AsgardeoHttpResponse> delete(
    String url, {
    Map<String, String>? headers,
  });

  /// Sends an HTTP PATCH request to the given [url].
  Future<AsgardeoHttpResponse> patch(
    String url, {
    Map<String, String>? headers,
    String? body,
  });

  /// Releases resources held by this HTTP manager.
  void dispose();
}

/// A simple HTTP response wrapper.
class AsgardeoHttpResponse {

  /// Creates an [AsgardeoHttpResponse].
  const AsgardeoHttpResponse({
    required this.statusCode,
    required this.body,
  });

  /// The HTTP status code returned by the server.
  final int statusCode;

  /// The response body as a string.
  final String body;
}
