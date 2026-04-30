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

import 'package:asgardeo_push_auth/src/internal/account_store.dart';
import 'package:asgardeo_push_auth/src/models/push_auth_account.dart';
import 'package:asgardeo_push_auth/src/models/registration_payload.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/in_memory_storage_manager.dart';

void main() {
  late InMemoryStorageManager storage;
  late AccountStore store;

  setUp(() {
    storage = InMemoryStorageManager();
    store = AccountStore(storage);
  });

  group('AccountStore', () {
    // ── getAccounts ────────────────────────────────────────

    group('getAccounts', () {
      test('returns empty list when nothing is stored', () async {
        expect(await store.getAccounts(), isEmpty);
      });

      test('returns saved accounts after saveAccount', () async {
        await store.saveAccount(kValidAccount);
        final accounts = await store.getAccounts();
        expect(accounts, hasLength(1));
        expect(accounts.first.id, kAccountId);
      });
    });

    // ── findById ───────────────────────────────────────────

    group('findById', () {
      test('returns account when found', () async {
        await store.saveAccount(kValidAccount);
        final found = await store.findById(kAccountId);
        expect(found, isNotNull);
        expect(found!.id, kAccountId);
      });

      test('returns null when not found', () async {
        final found = await store.findById('nonexistent');
        expect(found, isNull);
      });
    });

    // ── findByDeviceId ─────────────────────────────────────

    group('findByDeviceId', () {
      test('returns account when found', () async {
        await store.saveAccount(kValidAccount);
        final found = await store.findByDeviceId(kDeviceId);
        expect(found, isNotNull);
        expect(found!.deviceId, kDeviceId);
      });

      test('returns null when not found', () async {
        final found = await store.findByDeviceId('nonexistent');
        expect(found, isNull);
      });
    });

    // ── saveAccount ────────────────────────────────────────

    group('saveAccount', () {
      test('appends new account to the list', () async {
        const other = PushAuthAccount(
          id: 'other-id',
          username: 'bob@example.com',
          displayName: 'bob@example.com',
          deviceId: 'device-002',
          host: kHost,
          tenantDomain: kTenantDomain,
        );
        await store.saveAccount(kValidAccount);
        await store.saveAccount(other);
        expect(await store.getAccounts(), hasLength(2));
      });

      test('replaces existing account with same id', () async {
        await store.saveAccount(kValidAccount);
        final updated = kValidAccount.copyWith(
          displayName: 'Updated Name',
        );
        await store.saveAccount(updated);
        final accounts = await store.getAccounts();
        expect(accounts, hasLength(1));
        expect(accounts.first.displayName, 'Updated Name');
      });
    });

    // ── removeAccount ──────────────────────────────────────

    group('removeAccount', () {
      test('removes the account by id', () async {
        await store.saveAccount(kValidAccount);
        await store.removeAccount(kAccountId);
        expect(await store.getAccounts(), isEmpty);
      });

      test('leaves other accounts intact', () async {
        const other = PushAuthAccount(
          id: 'other-id',
          username: 'bob@example.com',
          displayName: 'bob@example.com',
          deviceId: 'device-002',
          host: kHost,
          tenantDomain: kTenantDomain,
        );
        await store.saveAccount(kValidAccount);
        await store.saveAccount(other);
        await store.removeAccount(kAccountId);
        final accounts = await store.getAccounts();
        expect(accounts, hasLength(1));
        expect(accounts.first.id, 'other-id');
      });

      test('is a no-op when id not found', () async {
        await store.saveAccount(kValidAccount);
        await store.removeAccount('nonexistent');
        expect(await store.getAccounts(), hasLength(1));
      });
    });

    // ── upsertPushAccount ──────────────────────────────────

    group('upsertPushAccount', () {
      test('Tier 1: matches on username + tenantDomain', () async {
        await store.saveAccount(kValidAccount);
        const payload = RegistrationPayload(
          deviceId: 'device-new',
          challenge: 'challenge-new',
          username: kUsername,
          host: kHost,
          tenantDomain: kTenantDomain,
        );
        final id = await store.upsertPushAccount(payload, 'new-id');
        expect(id, kAccountId); // reuses existing account id
        final accounts = await store.getAccounts();
        expect(accounts, hasLength(1));
        expect(accounts.first.deviceId, 'device-new');
      });

      test('Tier 2: matches on username + organizationId', () async {
        const existing = PushAuthAccount(
          id: kAccountId,
          username: kUsername,
          displayName: kUsername,
          deviceId: kDeviceId,
          host: kHost,
          organizationId: kOrgId,
        );
        await store.saveAccount(existing);
        const payload = RegistrationPayload(
          deviceId: 'device-new',
          challenge: 'ch',
          username: kUsername,
          host: 'https://other.io',
          organizationId: kOrgId,
        );
        final id = await store.upsertPushAccount(payload, 'new-id');
        expect(id, kAccountId);
      });

      test('Tier 3: matches when host == account.tenantDomain', () async {
        const existing = PushAuthAccount(
          id: kAccountId,
          username: kUsername,
          displayName: kUsername,
          deviceId: kDeviceId,
          host: kHost,
          tenantDomain: 'some-host.io',
        );
        await store.saveAccount(existing);
        const payload = RegistrationPayload(
          deviceId: 'device-new',
          challenge: 'ch',
          username: kUsername,
          host: 'some-host.io',
        );
        final id = await store.upsertPushAccount(payload, 'new-id');
        expect(id, kAccountId);
      });

      test('Tier 4: matches when host == account.organizationId', () async {
        const existing = PushAuthAccount(
          id: kAccountId,
          username: kUsername,
          displayName: kUsername,
          deviceId: kDeviceId,
          host: kHost,
          organizationId: 'some-org-id',
        );
        await store.saveAccount(existing);
        const payload = RegistrationPayload(
          deviceId: 'device-new',
          challenge: 'ch',
          username: kUsername,
          host: 'some-org-id',
        );
        final id = await store.upsertPushAccount(payload, 'new-id');
        expect(id, kAccountId);
      });

      test('creates new account when no tier matches', () async {
        await store.saveAccount(kValidAccount);
        const payload = RegistrationPayload(
          deviceId: 'device-new',
          challenge: 'ch',
          username: 'bob@example.com', // different user
          host: kHost,
          tenantDomain: kTenantDomain,
        );
        final id = await store.upsertPushAccount(payload, 'new-id');
        expect(id, 'new-id');
        expect(await store.getAccounts(), hasLength(2));
      });

      test('Tier 1 wins over Tier 2 when both match', () async {
        // Account matches both tenantDomain AND organizationId.
        const existing = PushAuthAccount(
          id: kAccountId,
          username: kUsername,
          displayName: kUsername,
          deviceId: kDeviceId,
          host: kHost,
          tenantDomain: kTenantDomain,
          organizationId: kOrgId,
        );
        await store.saveAccount(existing);
        const payload = RegistrationPayload(
          deviceId: 'device-new',
          challenge: 'ch',
          username: kUsername,
          host: kHost,
          tenantDomain: kTenantDomain,
          organizationId: kOrgId,
        );
        final id = await store.upsertPushAccount(payload, 'new-id');
        expect(id, kAccountId);
        expect(await store.getAccounts(), hasLength(1));
      });
    });

    // ── findMatchingAccount ────────────────────────────────

    group('findMatchingAccount', () {
      test('returns matching account on username + tenantDomain', () async {
        await store.saveAccount(kValidAccount);
        const payload = RegistrationPayload(
          deviceId: 'device-new',
          challenge: 'ch',
          username: kUsername,
          host: kHost,
          tenantDomain: kTenantDomain,
        );
        final match = await store.findMatchingAccount(payload);
        expect(match, isNotNull);
        expect(match!.id, kAccountId);
      });

      test('returns null when no tier matches', () async {
        await store.saveAccount(kValidAccount);
        const payload = RegistrationPayload(
          deviceId: 'device-new',
          challenge: 'ch',
          username: 'bob@example.com',
          host: kHost,
          tenantDomain: kTenantDomain,
        );
        final match = await store.findMatchingAccount(payload);
        expect(match, isNull);
      });

      test('returns null when store is empty', () async {
        const payload = RegistrationPayload(
          deviceId: 'device-new',
          challenge: 'ch',
          username: kUsername,
          host: kHost,
          tenantDomain: kTenantDomain,
        );
        final match = await store.findMatchingAccount(payload);
        expect(match, isNull);
      });
    });
  });
}
