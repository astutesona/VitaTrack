import 'package:flutter_test/flutter_test.dart';
import 'package:vitatrack/main.dart';

void main() {
  testWidgets('VitaTrack app launches and renders splash screen smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const VitaTrackApp());
    expect(find.text('VitaTrack'), findsOneWidget);
    expect(find.text('Personal Health & Wellness Tracker'), findsOneWidget);

    // Settle pending bootstrap timers
    await tester.pump(const Duration(seconds: 3));
  });
}
