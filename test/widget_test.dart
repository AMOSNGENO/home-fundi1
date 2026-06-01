import 'package:flutter_test/flutter_test.dart';
import 'package:home_fundi/main.dart';

void main() {
  testWidgets('shows Home Fundi while loading session', (tester) async {
    await tester.pumpWidget(const HomeFundiApp());
    expect(find.text('Home Fundi'), findsWidgets);
  });
}
