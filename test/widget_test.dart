import 'package:baghchal_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Baghchal app starts in goat placement state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const BaghchalApp());

    expect(find.byType(CustomPaint), findsOneWidget);
    expect(find.text('Bagh'), findsOneWidget);
    expect(find.text('chal'), findsOneWidget);
    expect(find.textContaining('PLACEMENT'), findsOneWidget);
    expect(find.textContaining('Goat'), findsOneWidget);
  });
}
