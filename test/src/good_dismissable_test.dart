import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:good_dismissable/good_dismissable.dart';

void main() {
  group('GoodDismissable', () {
    testWidgets('renders child content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoodDismissable(
              child: Text('Hello dismissable'),
            ),
          ),
        ),
      );

      expect(find.text('Hello dismissable'), findsOneWidget);
    });

    testWidgets('renders reveal action content', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GoodDismissable(
              swipeBehavior: GoodDismissableSwipeBehavior.reveal,
              actionContent: Text('Delete'),
              child: Text('Email tile'),
            ),
          ),
        ),
      );

      expect(find.text('Email tile'), findsOneWidget);
    });
  });
}
