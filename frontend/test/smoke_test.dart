
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic Flutter widget test', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('StudyFlow'),
        ),
      ),
    );

    expect(find.text('StudyFlow'), findsOneWidget);
  });
}
