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

import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
import 'package:asgardeo_push_authenticator/screens/account_detail/widgets/empty_card.dart';
import 'package:asgardeo_push_authenticator/screens/account_detail/widgets/history_card.dart';
import 'package:asgardeo_push_authenticator/utils/time_from_now.dart';
import 'package:flutter/material.dart';

/// Loads and displays the push authentication history for an account.
class PushAuthHistoryList extends StatefulWidget {
  const PushAuthHistoryList({required this.accountId, super.key});

  final String accountId;

  @override
  State<PushAuthHistoryList> createState() => _PushAuthHistoryListState();
}

class _PushAuthHistoryListState extends State<PushAuthHistoryList> {
  late Future<List<PushAuthRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture =
        AsgardeoPushAuth.instance.getAuthHistory(widget.accountId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PushAuthRecord>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final records = snapshot.data ?? [];
        if (records.isEmpty) return const EmptyCard();
        return Column(
          children: [
            for (final record in records)
              HistoryCard(
                record: record,
                timeAgo: timeFromNow(record.respondedTime),
              ),
          ],
        );
      },
    );
  }
}
