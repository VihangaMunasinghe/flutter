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

import 'package:asgardeo_push_authenticator/config/app_config.dart';
import 'package:asgardeo_push_authenticator/constants/screens/home.dart';
import 'package:asgardeo_push_authenticator/providers/account_provider.dart';
import 'package:asgardeo_push_authenticator/screens/home/widgets/account_list.dart';
import 'package:asgardeo_push_authenticator/widgets/app_bar_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Home screen showing the account list.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accountsAsync = ref.watch(accountNotifierProvider);
    final colors = AppConfig.instance.theme;

    final filteredAccounts = accountsAsync.value
            ?.where(
              (a) =>
                  _searchQuery.isEmpty ||
                  a.username
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ||
                  a.displayName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()),
            )
            .toList() ??
        [];

    return Scaffold(
      backgroundColor: hexToColor(colors.screenBackground),
      appBar: AppBar(
        title: const AppBarTitleWidget(),
        centerTitle: false,
        backgroundColor: hexToColor(colors.headerBackground),
        automaticallyImplyLeading: false,
      ),
      body: accountsAsync.when(
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                color: hexToColor(colors.primaryText),
              ),
              const SizedBox(height: 16),
              Text(
                HomeConstants.loadingMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: hexToColor(colors.secondaryText),
                ),
              ),
            ],
          ),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (accounts) {
          if (accounts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: HomeConstants.emptyHorizontalPadding,
                ),
                child: Text(
                  HomeConstants.emptyMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                    color: hexToColor(colors.secondaryText),
                  ),
                ),
              ),
            );
          }
          return AccountList(
            accounts: filteredAccounts,
            controller: _searchController,
            onSearchChanged: (v) => setState(() => _searchQuery = v),
            onAccountTap: (id) => context.push('/account/$id'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/qr-scanner'),
        backgroundColor: hexToColor(colors.button.primary.background),
        child: Icon(Icons.add, color: hexToColor(colors.button.primary.text)),
      ),
    );
  }
}
