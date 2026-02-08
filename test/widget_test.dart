import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smallvendors/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SmallVendorsApp());
    
    // Verify the app launches
    expect(find.text('Small Vendors'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}