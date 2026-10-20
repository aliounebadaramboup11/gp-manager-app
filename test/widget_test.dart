import 'package:flutter_test/flutter_test.dart';
import 'package:gp_manager/main.dart';

void main() {
  testWidgets('GP Manager démarre correctement', (WidgetTester tester) async {
    await tester.pumpWidget(const GPManagerApp());

    expect(find.byType(GPManagerApp), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
  });
}
