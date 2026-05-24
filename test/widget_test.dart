import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuf_cashier/main.dart';

void main() {
  testWidgets('shows login screen then opens main layout after sign in', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Masuk ke Kasir'), findsOneWidget);

    final Finder textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'andi@mysuf.co.id');
    await tester.enterText(textFields.at(1), '123456');
    await tester.tap(find.text('Masuk ke Kasir'));
    await tester.pumpAndSettle();

    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
  });
}