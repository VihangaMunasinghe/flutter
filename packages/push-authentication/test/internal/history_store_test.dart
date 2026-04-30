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
// software distributed under the LICENSE is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import 'package:asgardeo_push_auth/src/internal/history_store.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_record.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/in_memory_storage_manager.dart';

void main() {
  late InMemoryStorageManager storage;
  late HistoryStore store;

  setUp(() {
    storage = InMemoryStorageManager();
    store = HistoryStore(storage);
  });

  group('HistoryStore', () {
    // ── getHistory ─────────────────────────────────────────

    group('getHistory', () {
      test('returns empty list for unknown account', () async {
        expect(await store.getHistory(kAccountId), isEmpty);
      });

      test('returns records in stored order', () async {
        const first = kValidRecord;
        const second = PushAuthRecord(
          pushAuthId: 'push-002',
          applicationName: 'App',
          status: 'DENIED',
          respondedTime: 2000000,
          ipAddress: '1.2.3.4',
          deviceOS: 'Android',
          browser: 'Chrome',
          accountId: kAccountId,
        );
        await store.addRecord(kAccountId, first, maxItems: 10);
        await store.addRecord(kAccountId, second, maxItems: 10);
        final history = await store.getHistory(kAccountId);
        expect(history, hasLength(2));
        // Most-recent (second added) should be first.
        expect(history.first.pushAuthId, 'push-002');
        expect(history.last.pushAuthId, kPushId);
      });
    });

    // ── addRecord ──────────────────────────────────────────

    group('addRecord', () {
      test('new record is prepended (most-recent first)', () async {
        await store.addRecord(kAccountId, kValidRecord, maxItems: 10);
        const newer = PushAuthRecord(
          pushAuthId: 'push-newer',
          applicationName: 'App',
          status: 'DENIED',
          respondedTime: 9999999,
          ipAddress: '1.2.3.4',
          deviceOS: 'Android',
          browser: 'Chrome',
          accountId: kAccountId,
        );
        await store.addRecord(kAccountId, newer, maxItems: 10);
        final history = await store.getHistory(kAccountId);
        expect(history.first.pushAuthId, 'push-newer');
      });

      test('trims list to maxItems; oldest entry is dropped', () async {
        for (var i = 0; i < 5; i++) {
          await store.addRecord(
            kAccountId,
            PushAuthRecord(
              pushAuthId: 'push-$i',
              applicationName: 'App',
              status: 'APPROVED',
              respondedTime: i,
              ipAddress: '1.2.3.4',
              deviceOS: 'iOS',
              browser: 'Safari',
              accountId: kAccountId,
            ),
            maxItems: 3,
          );
        }
        final history = await store.getHistory(kAccountId);
        expect(history, hasLength(3));
        // Oldest entries (push-0, push-1) should have been dropped.
        expect(
          history.any((r) => r.pushAuthId == 'push-0'),
          isFalse,
        );
      });

      test('keeps exactly maxItems records at the limit', () async {
        for (var i = 0; i < 3; i++) {
          await store.addRecord(
            kAccountId,
            PushAuthRecord(
              pushAuthId: 'push-$i',
              applicationName: 'App',
              status: 'APPROVED',
              respondedTime: i,
              ipAddress: '1.2.3.4',
              deviceOS: 'iOS',
              browser: 'Safari',
              accountId: kAccountId,
            ),
            maxItems: 3,
          );
        }
        expect(await store.getHistory(kAccountId), hasLength(3));
      });
    });

    // ── clearHistory ───────────────────────────────────────

    group('clearHistory', () {
      test('subsequent getHistory returns empty list', () async {
        await store.addRecord(kAccountId, kValidRecord, maxItems: 10);
        await store.clearHistory(kAccountId);
        expect(await store.getHistory(kAccountId), isEmpty);
      });
    });
  });
}
