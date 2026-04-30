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

import 'package:asgardeo_push_auth/src/models/push_auth_account.dart';
import 'package:asgardeo_push_auth/src/models/registration_payload.dart';
import 'package:asgardeo_push_auth/src/storage/asgardeo_storage_manager.dart';

/// Storage key for the accounts JSON array.
const String kAccountsStorageKey = 'asgardeo_push_auth_accounts';

/// Internal helper for CRUD operations on push auth accounts.
///
/// Accounts are stored as a JSON array under a single storage key,
/// namespaced to avoid collisions with the consumer application.
class AccountStore {

  /// Creates an [AccountStore] backed by the given storage manager.
  AccountStore(this._storage);

  final AsgardeoStorageManager _storage;

  /// Returns all stored push auth accounts.
  Future<List<PushAuthAccount>> getAccounts() async {

    final raw = await _storage.getString(kAccountsStorageKey);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .cast<Map<String, dynamic>>()
        .map(PushAuthAccount.fromJson)
        .toList();
  }

  /// Finds an account by its [id], or returns `null` if not found.
  Future<PushAuthAccount?> findById(String id) async {

    final accounts = await getAccounts();
    for (final account in accounts) {
      if (account.id == id) return account;
    }
    return null;
  }

  /// Finds an account by its [deviceId], or returns `null` if not found.
  Future<PushAuthAccount?> findByDeviceId(String deviceId) async {

    final accounts = await getAccounts();
    for (final account in accounts) {
      if (account.deviceId == deviceId) return account;
    }
    return null;
  }

  /// Persists a new or updated account.
  ///
  /// If an account with the same [PushAuthAccount.id] exists, it is
  /// replaced. Otherwise the account is appended.
  Future<void> saveAccount(PushAuthAccount account) async {

    final accounts = await getAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);

    if (index >= 0) {
      accounts[index] = account;
    } else {
      accounts.add(account);
    }

    await _saveAll(accounts);
  }

  /// Removes the account with the given [id].
  Future<void> removeAccount(String id) async {

    final accounts = await getAccounts();
    accounts.removeWhere((a) => a.id == id);
    await _saveAll(accounts);
  }

  /// Returns the existing account that matches [payload] via the 4-tier
  /// cascade, or `null` if no match is found.
  Future<PushAuthAccount?> findMatchingAccount(
    RegistrationPayload payload,
  ) async {

    final accounts = await getAccounts();
    final matchIndex = _findMatchIndex(accounts, payload);
    return matchIndex >= 0 ? accounts[matchIndex] : null;
  }

  /// Finds or creates a push auth account from QR registration data.
  ///
  /// Uses a 4-tier cascade to match the payload to an existing account:
  /// 1. username + tenantDomain
  /// 2. username + organizationId
  /// 3. username + host matches tenantDomain
  /// 4. username + host matches organizationId
  ///
  /// If matched, the account is updated with new push fields.
  /// Otherwise a new account is created with [accountId].
  Future<String> upsertPushAccount(
    RegistrationPayload payload,
    String accountId,
  ) async {

    final accounts = await getAccounts();
    final matchIndex = _findMatchIndex(accounts, payload);

    if (matchIndex >= 0) {
      // Update the existing account with new push registration fields.
      final existing = accounts[matchIndex];
      accounts[matchIndex] = existing.copyWith(
        deviceId: payload.deviceId,
        host: payload.host,
        tenantDomain: payload.tenantDomain,
        organizationId: payload.organizationId,
        organizationName: payload.organizationName,
        userStoreDomain: payload.userStoreDomain,
      );
      await _saveAll(accounts);
      return existing.id;
    }

    // No match — create a new push-only account.
    final newAccount = PushAuthAccount(
      id: accountId,
      username: payload.username,
      displayName: payload.username,
      deviceId: payload.deviceId,
      host: payload.host,
      tenantDomain: payload.tenantDomain,
      organizationId: payload.organizationId,
      organizationName: payload.organizationName,
      userStoreDomain: payload.userStoreDomain,
    );
    accounts.add(newAccount);
    await _saveAll(accounts);
    return accountId;
  }

  /// 4-tier cascade matching to link QR data to an existing account.
  int _findMatchIndex(
    List<PushAuthAccount> accounts,
    RegistrationPayload payload,
  ) {

    // Tier 1: username + tenantDomain
    if (payload.tenantDomain != null && payload.tenantDomain!.isNotEmpty) {
      final idx = accounts.indexWhere(
        (a) =>
            a.username == payload.username &&
            a.tenantDomain == payload.tenantDomain,
      );
      if (idx >= 0) return idx;
    }

    // Tier 2: username + organizationId
    if (payload.organizationId != null && payload.organizationId!.isNotEmpty) {
      final idx = accounts.indexWhere(
        (a) =>
            a.username == payload.username &&
            a.organizationId == payload.organizationId,
      );
      if (idx >= 0) return idx;
    }

    // Tier 3: username + host matches an account's tenantDomain
    final idx3 = accounts.indexWhere(
      (a) =>
          a.username == payload.username &&
          a.tenantDomain == payload.host,
    );
    if (idx3 >= 0) return idx3;

    // Tier 4: username + host matches an account's organizationId
    final idx4 = accounts.indexWhere(
      (a) =>
          a.username == payload.username &&
          a.organizationId == payload.host,
    );
    if (idx4 >= 0) return idx4;

    return -1;
  }

  Future<void> _saveAll(List<PushAuthAccount> accounts) async {

    final json = accounts.map((a) => a.toJson()).toList();
    await _storage.setString(kAccountsStorageKey, jsonEncode(json));
  }
}
