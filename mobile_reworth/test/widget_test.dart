import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_reworth/app/app.dart';

void main() {
  testWidgets('App opens welcome page', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ReworthApp()));
    await tester.pumpAndSettle();

    expect(find.text('REWORTH'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
