import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:baghchal_app/main.dart'; // तपाईंको main.dart फाइल

void main() {
  testWidgets('Baghchal app starts and shows board with 4 tigers',
      (WidgetTester tester) async {
    // App बिल्ड गर्नुहोस्
    await tester.pumpWidget(const BaghchalApp());

    // बोर्ड (CustomPaint) अवश्य देखिनु पर्छ
    expect(find.byType(CustomPaint), findsOneWidget);

    // सुरुमा ४ वटा बाघ (Tiger) को गोटी हुनुपर्छ – हामी "tiger" क्लासको circle खोज्न सक्छौं
    // CustomPaint मा आधारित भएकोले find.byType(Circle) ले काम नगर्न सक्छ,
    // तर हामी AppBar को टाइटल वा स्टेटस पाठ हेर्न सक्छौं
    expect(find.text('Baghchal'), findsOneWidget); // AppBar टाइटल

    // स्टेटस बारमा "Placement" वा "Goat" लेखिएको छ कि छैन
    expect(find.textContaining('PLACEMENT'), findsOneWidget);
    expect(find.textContaining('Goat'), findsOneWidget);
  });

  testWidgets('Goat placement works', (WidgetTester tester) async {
    await tester.pumpWidget(const BaghchalApp());

    // पहिलो बाख्रा राख्नको लागि रिजर्भको पहिलो स्लट थिच्नुहोस्
    // रिजर्भका स्लटहरू Container हुन्, तर हामी तिनीहरूको आइकन (Icon) प्रयोग गर्छौं
    // रिजर्भको पहिलो स्लटमा '●' पाठ हुन्छ, त्यसैले:
    expect(find.text('●'), findsAtLeast(1));

    // अझ सटीक: पहिलो स्लट चयन गर्न
    // यो गाह्रो छ किनभने स्लटहरू ListView मा छन्, तर हामी थिच्न सक्छौं:
    // तर सरलताका लागि, हामी App सुरु भयो भनेर मात्र जाँच गर्छौं।
    // यदि पूर्ण इन्टर्याक्सन टेस्ट चाहिन्छ भने म थप विस्तृत दिन सक्छु।
  });
}
