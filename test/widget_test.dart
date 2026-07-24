import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmhcapp_ios/screens/installer_tools.dart';

void main() {
  testWidgets('Installer Tools includes the Heating Mat Planner', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: InstallerToolsScreen()),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Heating Mat Planner'), findsOneWidget);
  });
}
