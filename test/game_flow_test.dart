import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_shooter/main.dart';
import 'package:bubble_shooter/features/bubble_shooter/presentation/pages/home_page.dart';
import 'package:bubble_shooter/features/bubble_shooter/presentation/pages/game_page.dart';
import 'package:bubble_shooter/features/bubble_shooter/presentation/widgets/game_canvas_widget.dart';
import 'package:bubble_shooter/features/bubble_shooter/presentation/widgets/steampunk_hud.dart';

void main() {
  testWidgets('App renders HomePage with Start Expedition button and high score',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BubbleShooterApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('CHRONO BUBBLE'), findsOneWidget);
    expect(find.text('START EXPEDITION'), findsOneWidget);
    expect(find.textContaining('BEST SCORE:'), findsOneWidget);
  });

  testWidgets('Tapping START EXPEDITION cleanly transitions to GamePage with HUD and Canvas',
      (WidgetTester tester) async {
    await tester.pumpWidget(const BubbleShooterApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Tap the Start Expedition button
    await tester.tap(find.text('START EXPEDITION'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify GamePage is mounted and displayed
    expect(find.byType(GamePage), findsOneWidget);
    expect(find.byType(SteampunkHud), findsOneWidget);
    expect(find.byType(GameCanvasWidget), findsOneWidget);

    // Verify Score is 0
    expect(find.text('0'), findsOneWidget);

    // Verify Pause, Sound, and Restart buttons exist on the HUD
    expect(find.byIcon(Icons.pause), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
    expect(find.byIcon(Icons.volume_up), findsOneWidget);
  });
}
