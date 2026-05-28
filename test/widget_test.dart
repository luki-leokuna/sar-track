import 'package:flutter_test/flutter_test.dart';
import 'package:sar_track/main.dart';

void main() {
  testWidgets('SAR-Track smoke test', (WidgetTester tester) async {
    // Nama class sudah diupdate dari MyApp → SARTrackApp
    await tester.pumpWidget(const SARTrackApp());
  });
}
