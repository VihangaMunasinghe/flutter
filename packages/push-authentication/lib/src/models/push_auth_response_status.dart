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

/// The user's response to a push authentication request.
enum PushAuthResponseStatus {
  /// The user approved the authentication request.
  approved('APPROVED'),

  /// The user denied the authentication request.
  denied('DENIED');

  const PushAuthResponseStatus(this.value);

  /// The string value sent to the Asgardeo server in the JWT response.
  final String value;
}
