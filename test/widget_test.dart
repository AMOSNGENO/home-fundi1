import 'package:flutter_test/flutter_test.dart';
import 'package:home_fundi/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('shows FundiSmart splash screen', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));
    expect(find.text('FundiSmart'), findsWidgets);
  });
}
