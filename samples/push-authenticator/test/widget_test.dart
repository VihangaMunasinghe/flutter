import 'package:asgardeo_push_authenticator/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App launches smoke test', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: AsgardeoApp()));
  });
}
