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

import 'dart:developer' as developer;

import 'package:asgardeo_push_auth/src/logging/asgardeo_logger.dart';

/// [AsgardeoLogger] implementation using `dart:developer` `log()`.
///
/// Messages are filtered by [level]. Set to [LogLevel.none]
/// to suppress all output.
class DefaultLogger implements AsgardeoLogger {

  /// Creates a [DefaultLogger] with the given [level].
  const DefaultLogger({this.level = LogLevel.none});

  /// The minimum log level for messages to be emitted.
  final LogLevel level;

  @override
  void error(String message, [Object? error, StackTrace? stackTrace]) {

    if (level.index >= LogLevel.error.index) {
      developer.log(
        message,
        name: 'AsgardeoPushAuth',
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  void info(String message) {

    if (level.index >= LogLevel.info.index) {
      developer.log(
        message,
        name: 'AsgardeoPushAuth',
        level: 800,
      );
    }
  }

  @override
  void debug(String message) {

    if (level.index >= LogLevel.debug.index) {
      developer.log(
        message,
        name: 'AsgardeoPushAuth',
        level: 500,
      );
    }
  }
}
