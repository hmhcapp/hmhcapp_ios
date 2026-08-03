import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hmhcapp_ios/screens/floor_sensor_calculator.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  test('lookup matches the website NTC resistance calculation', () {
    final readings = buildSensorResistanceLookup(
      measuredResistanceOhms: 10000,
      measuredTemperatureC: 25,
    );

    expect(
      readings.map((reading) => reading.temperatureC),
      sensorLookupTemperatures,
    );
    expect(readings.map((reading) => reading.resistanceOhms), <int>[
      53251,
      40827,
      31608,
      24697,
      19466,
      15471,
      12392,
      10000,
      8127,
      6650,
      5476,
    ]);
  });

  test('calculation preserves the measured point', () {
    final result = calculateSensorResistance(
      targetTemperatureC: 17.5,
      measuredResistanceOhms: 12650,
      measuredTemperatureC: 17.5,
    );

    expect(result, closeTo(12650, 0.001));
  });

  testWidgets('calculator displays a mobile resistance lookup table', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: FloorSensorCalculatorScreen()),
    );

    await tester.enterText(
      find.byKey(const Key('sensorResistanceField')),
      '10000',
    );
    await tester.enterText(
      find.byKey(const Key('sensorTemperatureField')),
      '25',
    );

    final calculateButton = find.byKey(
      const Key('calculateSensorLookupButton'),
    );
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    expect(find.text('Sensor resistance lookup'), findsOneWidget);
    expect(find.text('-10°C'), findsOneWidget);
    expect(find.text('53,251 Ω'), findsOneWidget);
    expect(find.text('5°C'), findsOneWidget);
    expect(find.text('24,697 Ω'), findsOneWidget);
    expect(find.text('40°C'), findsOneWidget);
    expect(find.text('5,476 Ω'), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('Resistance curve'), findsOneWidget);
    expect(find.text('Tap a dot to view its exact value.'), findsOneWidget);

    final chart = find.byKey(const Key('sensorResistanceChart'));
    await tester.tapAt(tester.getCenter(chart));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('selectedSensorChartValue')), findsOneWidget);
  });

  testWidgets('a second calculation replaces the existing lookup values', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: FloorSensorCalculatorScreen()),
    );

    final resistanceField = find.byKey(const Key('sensorResistanceField'));
    final temperatureField = find.byKey(const Key('sensorTemperatureField'));
    final calculateButton = find.byKey(
      const Key('calculateSensorLookupButton'),
    );

    await tester.enterText(resistanceField, '10000');
    await tester.enterText(temperatureField, '25');
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();
    expect(find.text('24,697 Ω'), findsOneWidget);

    await tester.ensureVisible(resistanceField);
    await tester.enterText(resistanceField, '12000');
    await tester.enterText(temperatureField, '25');
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    expect(find.text('24,697 Ω'), findsNothing);
    expect(find.text('29,637 Ω'), findsOneWidget);
  });

  testWidgets('calculator validates missing measurements', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: FloorSensorCalculatorScreen()),
    );

    final calculateButton = find.byKey(
      const Key('calculateSensorLookupButton'),
    );
    await tester.ensureVisible(calculateButton);
    await tester.tap(calculateButton);
    await tester.pumpAndSettle();

    expect(
      find.text('Enter a resistance greater than 0 ohms.'),
      findsOneWidget,
    );
    expect(
      find.text('Enter the temperature at the time of testing.'),
      findsOneWidget,
    );
  });
}
