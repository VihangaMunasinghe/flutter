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

import 'package:asgardeo_push_auth/src/storage/asgardeo_storage_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [AsgardeoStorageManager] implementation using `shared_preferences`.
class SharedPreferencesStorageManager implements AsgardeoStorageManager {

  /// Creates a [SharedPreferencesStorageManager].
  ///
  /// An optional [sharedPreferences] instance can be provided for testing.
  SharedPreferencesStorageManager({SharedPreferences? sharedPreferences})
      : _prefs = sharedPreferences;

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<void> setString(String key, String value) async {
    final prefs = await _instance;
    await prefs.setString(key, value);
  }

  @override
  Future<String?> getString(String key) async {
    final prefs = await _instance;
    return prefs.getString(key);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _instance;
    await prefs.remove(key);
  }
}
