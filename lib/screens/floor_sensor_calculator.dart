import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show NumberFormat;

const sensorLookupTemperatures = <int>[
  -10,
  -5,
  0,
  5,
  10,
  15,
  20,
  25,
  30,
  35,
  40,
];

const _sensorBetaConstant = 3745.0;
const _kelvinOffset = 273.0;

@immutable
class SensorResistanceReading {
  final int temperatureC;
  final int resistanceOhms;

  const SensorResistanceReading({
    required this.temperatureC,
    required this.resistanceOhms,
  });
}

double calculateSensorResistance({
  required double targetTemperatureC,
  required double measuredResistanceOhms,
  required double measuredTemperatureC,
}) {
  final measuredKelvin = measuredTemperatureC + _kelvinOffset;
  final targetKelvin = targetTemperatureC + _kelvinOffset;

  return measuredResistanceOhms *
      math.exp(
        _sensorBetaConstant *
            (measuredTemperatureC - targetTemperatureC) /
            (measuredKelvin * targetKelvin),
      );
}

List<SensorResistanceReading> buildSensorResistanceLookup({
  required double measuredResistanceOhms,
  required double measuredTemperatureC,
}) {
  return sensorLookupTemperatures
      .map(
        (temperature) => SensorResistanceReading(
          temperatureC: temperature,
          resistanceOhms: calculateSensorResistance(
            targetTemperatureC: temperature.toDouble(),
            measuredResistanceOhms: measuredResistanceOhms,
            measuredTemperatureC: measuredTemperatureC,
          ).round(),
        ),
      )
      .toList(growable: false);
}

class FloorSensorCalculatorScreen extends StatefulWidget {
  const FloorSensorCalculatorScreen({super.key});

  @override
  State<FloorSensorCalculatorScreen> createState() =>
      _FloorSensorCalculatorScreenState();
}

class _FloorSensorCalculatorScreenState
    extends State<FloorSensorCalculatorScreen> {
  static const _accentColor = Color(0xFFE9882A);

  final _formKey = GlobalKey<FormState>();
  final _resistanceController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _numberFormat = NumberFormat.decimalPattern('en_GB');

  List<SensorResistanceReading>? _readings;
  double? _measuredResistance;
  double? _measuredTemperature;

  @override
  void dispose() {
    _resistanceController.dispose();
    _temperatureController.dispose();
    super.dispose();
  }

  double? _parseNumber(String value) {
    return double.tryParse(value.trim().replaceAll(',', ''));
  }

  String? _validateResistance(String? value) {
    final resistance = _parseNumber(value ?? '');
    if (resistance == null || resistance <= 0) {
      return 'Enter a resistance greater than 0 ohms.';
    }
    return null;
  }

  String? _validateTemperature(String? value) {
    final temperature = _parseNumber(value ?? '');
    if (temperature == null) {
      return 'Enter the temperature at the time of testing.';
    }
    if (temperature < -50 || temperature > 100) {
      return 'Enter a temperature between -50°C and 100°C.';
    }
    return null;
  }

  void _calculate() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final resistance = _parseNumber(_resistanceController.text)!;
    final temperature = _parseNumber(_temperatureController.text)!;

    setState(() {
      _measuredResistance = resistance;
      _measuredTemperature = temperature;
      _readings = buildSensorResistanceLookup(
        measuredResistanceOhms: resistance,
        measuredTemperatureC: temperature,
      );
    });
  }

  void _reset() {
    FocusScope.of(context).unfocus();
    _formKey.currentState?.reset();
    _resistanceController.clear();
    _temperatureController.clear();
    setState(() {
      _readings = null;
      _measuredResistance = null;
      _measuredTemperature = null;
    });
  }

  String _formatResistance(num value) => '${_numberFormat.format(value)} Ω';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Floor Sensor Calculator',
          style: GoogleFonts.raleway(color: Colors.white),
        ),
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.device_thermostat_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _IntroCard(accentColor: _accentColor),
            const SizedBox(height: 16),
            _buildInputCard(),
            if (_readings case final readings?) ...[
              const SizedBox(height: 20),
              _buildResultsCard(readings),
              const SizedBox(height: 16),
              _ResistanceChartCard(
                readings: readings,
                accentColor: _accentColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard() {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter the measured sensor values',
                style: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Measure the floor sensor resistance and note the floor '
                'temperature at the same time.',
                style: GoogleFonts.raleway(height: 1.4),
              ),
              const SizedBox(height: 18),
              TextFormField(
                key: const Key('sensorResistanceField'),
                controller: _resistanceController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Measured resistance',
                  hintText: 'For example, 10,000',
                  suffixText: 'Ω',
                  prefixIcon: Icon(Icons.electrical_services_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _validateResistance,
                onFieldSubmitted: (_) => FocusScope.of(context).nextFocus(),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('sensorTemperatureField'),
                controller: _temperatureController,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Measured temperature',
                  hintText: 'For example, 20',
                  suffixText: '°C',
                  prefixIcon: Icon(Icons.thermostat_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _validateTemperature,
                onFieldSubmitted: (_) => _calculate(),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const Key('calculateSensorLookupButton'),
                onPressed: _calculate,
                style: FilledButton.styleFrom(
                  backgroundColor: _accentColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.calculate_outlined),
                label: Text(
                  'Calculate',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultsCard(List<SensorResistanceReading> readings) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: const Color(0xFF333333),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sensor resistance lookup',
                  style: GoogleFonts.raleway(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatResistance(_measuredResistance!)} measured at '
                  '${_measuredTemperature!.toStringAsFixed(_measuredTemperature! % 1 == 0 ? 0 : 1)}°C',
                  style: GoogleFonts.raleway(color: Colors.white70),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Table(
              border: TableBorder.all(color: const Color(0xFFD5D5D5)),
              columnWidths: const {
                0: FlexColumnWidth(0.8),
                1: FlexColumnWidth(1.2),
              },
              children: [
                _tableRow(
                  temperature: 'Temperature',
                  resistance: 'Resistance',
                  color: const Color(0xFFF2F2F2),
                  isHeader: true,
                ),
                for (final reading in readings)
                  _tableRow(
                    temperature: '${reading.temperatureC}°C',
                    resistance: _formatResistance(reading.resistanceOhms),
                    color: _highlightColor(reading.temperatureC),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, size: 18, color: _accentColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'The highlighted 5°C, 10°C, 15°C and 20°C values are '
                    'normally required when configuring a Heat Mat thermostat '
                    'for an existing floor sensor.',
                    style: GoogleFonts.raleway(fontSize: 12.5, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh),
              label: const Text('Start again'),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _tableRow({
    required String temperature,
    required String resistance,
    Color? color,
    bool isHeader = false,
  }) {
    final style = GoogleFonts.raleway(
      fontWeight: isHeader ? FontWeight.w700 : FontWeight.w600,
      color: const Color(0xFF333333),
    );

    return TableRow(
      decoration: BoxDecoration(color: color),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          child: Text(temperature, textAlign: TextAlign.center, style: style),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
          child: Text(resistance, textAlign: TextAlign.center, style: style),
        ),
      ],
    );
  }

  Color? _highlightColor(int temperature) {
    return switch (temperature) {
      5 => const Color(0xFFFCE4D6),
      10 => const Color(0xFFF8CBAD),
      15 => const Color(0xFFF4B084),
      20 => const Color(0xFFFA9350),
      _ => null,
    };
  }
}

class _IntroCard extends StatelessWidget {
  final Color accentColor;

  const _IntroCard({required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.1),
        border: Border.all(color: accentColor.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.sensors_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Identify an existing NTC floor sensor',
                  style: GoogleFonts.raleway(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Use one resistance reading and its measured temperature to '
                  'calculate the sensor values needed when replacing a '
                  'non-Heat Mat thermostat.',
                  style: GoogleFonts.raleway(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResistanceChartCard extends StatelessWidget {
  final List<SensorResistanceReading> readings;
  final Color accentColor;

  const _ResistanceChartCard({
    required this.readings,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resistance curve',
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Calculated resistance across the lookup temperature range.',
              style: GoogleFonts.raleway(fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            Semantics(
              label:
                  'Line chart of sensor resistance from minus 10 to 40 degrees Celsius',
              image: true,
              child: SizedBox(
                height: 220,
                width: double.infinity,
                child: CustomPaint(
                  painter: _ResistanceChartPainter(
                    readings: readings,
                    accentColor: accentColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResistanceChartPainter extends CustomPainter {
  final List<SensorResistanceReading> readings;
  final Color accentColor;

  const _ResistanceChartPainter({
    required this.readings,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    const left = 48.0;
    const right = 12.0;
    const top = 10.0;
    const bottom = 30.0;
    final chartWidth = size.width - left - right;
    final chartHeight = size.height - top - bottom;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final maximumResistance = readings
        .map((reading) => reading.resistanceOhms)
        .reduce(math.max)
        .toDouble();
    final verticalMaximum = maximumResistance * 1.08;

    final gridPaint = Paint()
      ..color = const Color(0xFFDADADA)
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = const Color(0xFF555555)
      ..strokeWidth = 1.2;

    for (var index = 0; index <= 4; index++) {
      final y = top + chartHeight * index / 4;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
      final value = verticalMaximum * (1 - index / 4);
      _paintLabel(
        canvas,
        _compactNumber(value),
        Offset(left - 6, y),
        alignRight: true,
        centerVertically: true,
      );
    }

    canvas.drawLine(
      const Offset(left, top),
      Offset(left, top + chartHeight),
      axisPaint,
    );
    canvas.drawLine(
      Offset(left, top + chartHeight),
      Offset(size.width - right, top + chartHeight),
      axisPaint,
    );

    final points = <Offset>[];
    for (var index = 0; index < readings.length; index++) {
      final reading = readings[index];
      final x = left + chartWidth * index / (readings.length - 1);
      final y =
          top + chartHeight * (1 - reading.resistanceOhms / verticalMaximum);
      points.add(Offset(x, y));

      if (index.isEven) {
        _paintLabel(
          canvas,
          '${reading.temperatureC}°',
          Offset(x, top + chartHeight + 8),
          centerHorizontally: true,
        );
      }
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, top + chartHeight)
      ..lineTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, top + chartHeight)
      ..close();
    canvas.drawPath(
      fillPath,
      Paint()..color = accentColor.withValues(alpha: 0.16),
    );

    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      linePath.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = accentColor
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );

    final pointPaint = Paint()..color = const Color(0xFF333333);
    for (final point in points) {
      canvas.drawCircle(point, 2.6, pointPaint);
    }
  }

  void _paintLabel(
    Canvas canvas,
    String text,
    Offset position, {
    bool alignRight = false,
    bool centerHorizontally = false,
    bool centerVertically = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 10, color: Color(0xFF555555)),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    var dx = position.dx;
    var dy = position.dy;
    if (alignRight) dx -= painter.width;
    if (centerHorizontally) dx -= painter.width / 2;
    if (centerVertically) dy -= painter.height / 2;
    painter.paint(canvas, Offset(dx, dy));
  }

  String _compactNumber(double value) {
    if (value >= 1000) {
      final thousands = value / 1000;
      return '${thousands.toStringAsFixed(thousands >= 10 ? 0 : 1)}k';
    }
    return value.round().toString();
  }

  @override
  bool shouldRepaint(covariant _ResistanceChartPainter oldDelegate) {
    return oldDelegate.readings != readings ||
        oldDelegate.accentColor != accentColor;
  }
}
