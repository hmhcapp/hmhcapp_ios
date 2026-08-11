import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmhcapp_ios/screens/installer_tools.dart';
import 'package:hmhcapp_ios/screens/product_factsheets.dart';
import 'package:hmhcapp_ios/screens/product_instructions.dart' as instructions;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hmhcapp_ios/screens/case_studies.dart';
import 'package:hmhcapp_ios/screens/case_study_detail.dart';
import 'package:hmhcapp_ios/screens/floor_diagrams.dart';
import 'package:hmhcapp_ios/widgets/classic_share_icon.dart';
import 'package:hmhcapp_ios/auth/auth_dark_shell.dart';
import 'package:hmhcapp_ios/auth/login_screen.dart';
import 'package:hmhcapp_ios/auth/register_screen.dart';
import 'package:hmhcapp_ios/auth/reset_password_screen.dart';

void main() {
  testWidgets('Installer Tools displays a two-column tool grid', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: InstallerToolsScreen()));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Heating Mat Planner'), findsOneWidget);
    expect(find.text('Floor Sensor Calculator'), findsOneWidget);
    expect(find.byType(CustomScrollView), findsOneWidget);

    final toolTiles = find.byWidgetPredicate(
      (widget) =>
          widget.key is ValueKey<String> &&
          (widget.key! as ValueKey<String>).value.startsWith('installer_tool_'),
    );
    expect(toolTiles, findsNWidgets(7));

    final firstCard = find.byKey(const ValueKey('installer_tool_0'));
    final secondCard = find.byKey(const ValueKey('installer_tool_1'));
    final thirdCard = find.byKey(const ValueKey('installer_tool_2'));
    final plannerCard = find.byKey(const ValueKey('installer_tool_6'));

    final firstTile = tester.getTopLeft(firstCard);
    final secondTile = tester.getTopLeft(secondCard);
    final thirdTile = tester.getTopLeft(thirdCard);

    expect((firstTile.dy - secondTile.dy).abs(), lessThan(2));
    expect(secondTile.dx, greaterThan(firstTile.dx));
    expect(thirdTile.dy, greaterThan(firstTile.dy));

    final firstTileWidth = tester.getSize(firstCard).width;
    final finalTileWidth = tester.getSize(plannerCard).width;
    expect(finalTileWidth, greaterThan(firstTileWidth * 1.8));
    expect(
      find.descendant(
        of: plannerCard,
        matching: find.text('Heating Mat Planner'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('Factsheets display a searchable dark product catalogue', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final data = [
      CategoryData('Heating Mats', [
        SubCategoryItem('Heat Mat Pro', [
          const PdfInfo('PKM-160 factsheet', 'assets/example.pdf'),
        ]),
      ]),
      CategoryData('Thermostats', [
        PdfItem(const PdfInfo('HMT5 factsheet', 'assets/example.pdf')),
      ]),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ProductFactsheetsScreen(
          categoryTitle: 'Underfloor Heating Factsheets',
          appBarColor: const Color(0xFFDD4F2E),
          factsheetData: data,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Browse technical product information'), findsOneWidget);
    expect(find.text('Heating Mats'), findsOneWidget);
    expect(find.text('PKM-160 factsheet'), findsNothing);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    await tester.tap(find.text('Heating Mats'));
    await tester.pump();

    expect(find.text('PKM-160 factsheet'), findsOneWidget);
    final factsheetPdfIcon = tester.widget<Icon>(
      find.byIcon(Icons.picture_as_pdf_rounded),
    );
    expect(factsheetPdfIcon.color, Colors.white);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Instructions display a searchable dark document catalogue', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final data = [
      instructions.CategoryData('Heating Mats', [
        instructions.SubCategoryItem('Heat Mat Pro', [
          const instructions.PdfInfo(
            'PKM Heating Mat Instructions',
            'assets/example.pdf',
          ),
        ]),
      ]),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: instructions.ProductInstructionsScreen(
          categoryTitle: 'Underfloor Heating Instructions',
          appBarColor: const Color(0xFFE26A2D),
          instructionData: data,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Browse installation guides and manuals'), findsOneWidget);
    expect(find.text('Heating Mats'), findsOneWidget);
    expect(find.text('PKM Heating Mat Instructions'), findsNothing);

    await tester.tap(find.text('Heating Mats'));
    await tester.pump();

    expect(find.text('PKM Heating Mat Instructions'), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(2));
    expect(find.byType(ClassicShareIcon), findsOneWidget);
    final instructionPdfIcon = tester.widget<Icon>(
      find.byIcon(Icons.picture_as_pdf_rounded),
    );
    expect(instructionPdfIcon.color, Colors.white);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Case studies display a searchable dark project catalogue', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: CaseStudiesScreen()));
    await tester.pump();

    expect(
      find.text('Explore real projects and proven solutions'),
      findsOneWidget,
    );
    expect(find.text('Homewood Grove Retirement Village'), findsOneWidget);
    expect(find.text('Underfloor Heating'), findsWidgets);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Floor diagrams display a searchable dark catalogue', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: FloorDiagramsScreen()));
    await tester.pump();

    expect(
      find.text('Explore recommended floor constructions'),
      findsOneWidget,
    );
    expect(find.text('Heating Mats'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    expect(find.byType(ClassicShareIcon), findsNothing);

    await tester.tap(find.text('Heating Mats'));
    await tester.pump();

    expect(find.byType(ClassicShareIcon), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Case study details use dark project panels', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: CaseStudyDetailScreen(caseStudyId: '1')),
    );
    await tester.pump();

    expect(find.text('The Project'), findsOneWidget);
    expect(find.text('The Challenge'), findsOneWidget);
    expect(find.text('The Solution'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login uses the shared dark authentication shell', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pump();

    expect(find.byType(AuthDarkShell), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Sign in with Apple'), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Registration uses the shared dark authentication shell', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    await tester.pump();

    expect(find.byType(AuthDarkShell), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Password reset uses the shared dark authentication shell', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: ResetPasswordScreen()));
    await tester.pump();

    expect(find.byType(AuthDarkShell), findsOneWidget);
    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Send Reset Email'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
