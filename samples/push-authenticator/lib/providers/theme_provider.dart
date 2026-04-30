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

import 'dart:async';

import 'package:asgardeo_push_authenticator/constants/storage_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the app theme mode (light / dark), persisted to SharedPreferences.
class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    unawaited(_loadTheme());
    return ThemeMode.light;
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(StorageKeys.themeMode);
    if (saved == 'dark') {
      state = ThemeMode.dark;
    }
  }

  /// Toggles between light and dark theme and persists the choice.
  Future<void> toggle() async {
    final next =
        state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    state = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      StorageKeys.themeMode,
      next == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}

/// Riverpod provider for [ThemeNotifier].
final themeNotifierProvider =
    NotifierProvider<ThemeNotifier, ThemeMode>(ThemeNotifier.new);
