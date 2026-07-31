import 'package:flutter_test/flutter_test.dart';
import 'package:meal_calculation_app/app.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MessMealApp());
    expect(find.byType(MessMealApp), findsOneWidget);
  });
}
