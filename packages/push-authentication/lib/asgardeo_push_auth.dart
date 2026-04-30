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

/// Push-notification-based authentication SDK for Asgardeo
/// (WSO2 Identity Server).
///
/// {@category Getting Started}
/// ```dart
/// import 'package:asgardeo_push_auth/asgardeo_push_auth.dart';
///
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   AsgardeoPushAuthBuilder().build();
///   // SDK is now ready to use via AsgardeoPushAuth.instance
/// }
/// ```
library;

// Facade and builder.
export 'src/asgardeo_push_auth.dart';
// Crypto.
export 'src/crypto/asgardeo_crypto_engine.dart';
export 'src/crypto/secure_crypto_engine.dart';
// Device info.
export 'src/device_info/asgardeo_device_info_provider.dart';
export 'src/device_info/platform_device_info_provider.dart';
// HTTP.
export 'src/http/asgardeo_http_manager.dart';
export 'src/http/http_client_manager.dart';
// Logging.
export 'src/logging/asgardeo_logger.dart';
export 'src/logging/default_logger.dart';
// Models.
export 'src/models/asgardeo_exception.dart';
export 'src/models/biometric_policy.dart';
export 'src/models/push_auth_account.dart';
export 'src/models/push_auth_record.dart';
export 'src/models/push_auth_request.dart';
export 'src/models/push_auth_response_status.dart';
export 'src/models/push_provider.dart';
export 'src/models/push_provider_impl/amazon_sns_push_provider.dart';
export 'src/models/push_provider_impl/fcm_push_provider.dart';
export 'src/models/registration_payload.dart';
// Storage.
export 'src/storage/asgardeo_storage_manager.dart';
export 'src/storage/shared_preferences_storage_manager.dart';
