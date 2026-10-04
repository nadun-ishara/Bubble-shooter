import 'package:flutter_test/flutter_test.dart';
import 'package:bubble_shooter/main.dart';

void main() {
  testWidgets('App renders Home Screen with Start Expedition button', (WidgetTester tester) async {
    await tester.pumpWidget(const BubbleShooterApp());

    // Verify Title and Start Expedition button appear
    expect(find.text('CHRONO BUBBLE'), findsOneWidget);
    expect(find.text('START EXPEDITION'), findsOneWidget);
  });
}
