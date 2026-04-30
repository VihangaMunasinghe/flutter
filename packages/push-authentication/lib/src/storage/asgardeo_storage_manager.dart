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

/// Interface for general-purpose key/value storage used by the SDK
/// to persist accounts and authentication history.
abstract class AsgardeoStorageManager {

  /// Stores a [value] associated with the given [key].
  Future<void> setString(String key, String value);

  /// Retrieves the value for [key], or `null` if not found.
  Future<String?> getString(String key);

  /// Removes the value associated with the given [key].
  Future<void> remove(String key);
}
