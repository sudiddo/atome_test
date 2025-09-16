// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:atome_test/app.dart';

void main() {
  testWidgets('App loads pets list page', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: App()));

    // Verify that the pets list page loads with basic UI elements.
    expect(find.text('Pets'), findsAtLeastNWidgets(1));
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(DropdownButton<String>), findsOneWidget);
  });
}
