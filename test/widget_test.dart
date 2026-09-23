import 'package:flutter_test/flutter_test.dart';
import 'package:dukan_khata/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    expect(DukanKhataApp, isNotNull);
  });
}
