// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:note_app/app/app.dart'; // Import NoteApp
import 'package:note_app/app/provider/app_provider.dart'; // Import AppProviders
import 'package:note_app/main.dart'; // Import main for di.init()

import 'package:note_app/app/di/get_it.dart' as di; // Import get_it

void main() {
  // Khởi tạo các dependency trước khi chạy test
  setUpAll(() async {
    await di.init();
  });

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Cần bọc NoteApp trong AppProviders để các Bloc/Cubit được cung cấp
    await tester.pumpWidget(const AppProviders(child: NoteApp()));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
