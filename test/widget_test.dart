import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:scoreduck/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // final store = ScoreStore(); // No longer needed directly
    await tester.pumpWidget(
      const ProviderScope(
        child: ScoreDuckApp(),
      ),
    );

    // Verify that we start with no games.
    expect(find.text('还没有比赛'), findsOneWidget);
    expect(find.byIcon(CupertinoIcons.add), findsOneWidget);
  });
}
