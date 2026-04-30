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

import 'dart:convert';

import 'package:asgardeo_push_auth/src/models/push_auth_record.dart';
import 'package:asgardeo_push_auth/src/storage/asgardeo_storage_manager.dart';

/// Storage key prefix for per-account history.
const String kHistoryKeyPrefix = 'asgardeo_push_auth_history_';

/// Internal helper for CRUD operations on push auth history records.
///
/// History is stored per account as a JSON array, with the most
/// recent record prepended. The list is trimmed to `maxItems`
/// entries to prevent unbounded growth.
class HistoryStore {

  /// Creates a [HistoryStore] backed by the given storage manager.
  HistoryStore(this._storage);

  final AsgardeoStorageManager _storage;

  /// Returns the push auth history for the given [accountId].
  Future<List<PushAuthRecord>> getHistory(String accountId) async {

    final raw = await _storage.getString('$kHistoryKeyPrefix$accountId');
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(PushAuthRecord.fromJson)
        .toList();
  }

  /// Prepends a new [record] to the history for [accountId].
  ///
  /// Oldest entries are discarded if the list exceeds [maxItems].
  Future<void> addRecord(
    String accountId,
    PushAuthRecord record, {
    required int maxItems,
  }) async {

    final history = await getHistory(accountId);
    final updated = [record, ...history];
    final trimmed =
        updated.length > maxItems ? updated.sublist(0, maxItems) : updated;

    final json = trimmed.map((r) => r.toJson()).toList();
    await _storage.setString('$kHistoryKeyPrefix$accountId', jsonEncode(json));
  }

  /// Deletes all history records for the given [accountId].
  Future<void> clearHistory(String accountId) async {

    await _storage.remove('$kHistoryKeyPrefix$accountId');
  }
}
