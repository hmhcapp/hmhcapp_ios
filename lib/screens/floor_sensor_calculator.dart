import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show NumberFormat;
import '../widgets/atmospheric_dark_background.dart';

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
        toolbarHeight: 78,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Floor Sensor Calculator',
              style: GoogleFonts.raleway(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'Identify an existing NTC floor sensor',
              style: GoogleFonts.raleway(
                color: atmosphericSecondaryText,
                fontSize: 12.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF101111),
        foregroundColor: _accentColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 64,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _accentColor,
            size: 30,
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.device_thermostat_outlined, color: _accentColor),
          ),
        ],
      ),
      body: Theme(
        data: atmosphericDarkTheme(context, accent: _accentColor),
        child: AtmosphericDarkBackground(
          accentColor: _accentColor,
          child: SafeArea(
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
                  color: atmosphericPrimaryText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Measure the floor sensor resistance and note the floor '
                'temperature at the same time.',
                style: GoogleFonts.raleway(height: 1.4),
              ),
              const SizedBox(height: 8),
              Text(
                "An NTC sensor's kΩ rating is its resistance at 25°C.",
                style: GoogleFonts.raleway(
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: atmosphericSecondaryText,
                ),
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
            color: atmosphericRaisedSurface,
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
              border: TableBorder.all(color: atmosphericBorder),
              columnWidths: const {
                0: FlexColumnWidth(0.8),
                1: FlexColumnWidth(1.2),
              },
              children: [
                _tableRow(
                  temperature: 'Temperature',
                  resistance: 'Resistance',
                  color: atmosphericRaisedSurface,
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
      color: color != null && !isHeader
          ? const Color(0xFF17120D)
          : atmosphericPrimaryText,
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
      5 => const Color(0xFFFFD596),
      10 => const Color(0xFFF9B85F),
      15 => const Color(0xFFF29835),
      20 => const Color(0xFFE97822),
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
                    color: atmosphericPrimaryText,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Use one resistance reading and its measured temperature to '
                  'calculate the sensor values needed when replacing a '
                  'non-Heat Mat thermostat.',
                  style: GoogleFonts.raleway(
                    height: 1.4,
                    color: atmosphericSecondaryText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const _chartLeft = 48.0;
const _chartRight = 12.0;
const _chartTop = 10.0;
const _chartBottom = 30.0;

class _ResistanceChartCard extends StatefulWidget {
  final List<SensorResistanceReading> readings;
  final Color accentColor;

  const _ResistanceChartCard({
    required this.readings,
    required this.accentColor,
  });

  @override
  State<_ResistanceChartCard> createState() => _ResistanceChartCardState();
}

class _ResistanceChartCardState extends State<_ResistanceChartCard> {
  final _numberFormat = NumberFormat.decimalPattern('en_GB');
  int? _selectedIndex;

  @override
  void didUpdateWidget(covariant _ResistanceChartCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.readings, widget.readings)) {
      _selectedIndex = null;
    }
  }

  void _selectReading(TapDownDetails details, double width) {
    final chartWidth = width - _chartLeft - _chartRight;
    if (chartWidth <= 0 || widget.readings.isEmpty) return;

    final relativeX = (details.localPosition.dx - _chartLeft).clamp(
      0.0,
      chartWidth,
    );
    final index = (relativeX / chartWidth * (widget.readings.length - 1))
        .round();
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final selectedReading = _selectedIndex == null
        ? null
        : widget.readings[_selectedIndex!];

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
                color: atmosphericPrimaryText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Calculated resistance across the lookup temperature range.',
              style: GoogleFonts.raleway(fontSize: 12.5),
            ),
            const SizedBox(height: 14),
            LayoutBuilder(
              builder: (context, constraints) {
                return Semantics(
                  label:
                      'Interactive line chart of sensor resistance from minus '
                      '10 to 40 degrees Celsius. Tap a point to show its exact value.',
                  button: true,
                  child: GestureDetector(
                    key: const Key('sensorResistanceChart'),
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (details) =>
                        _selectReading(details, constraints.maxWidth),
                    child: SizedBox(
                      height: 220,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: _ResistanceChartPainter(
                          readings: widget.readings,
                          accentColor: widget.accentColor,
                          selectedIndex: _selectedIndex,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: selectedReading == null
                  ? Row(
                      key: const ValueKey('chartHint'),
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 17,
                          color: widget.accentColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tap a dot to view its exact value.',
                            style: GoogleFonts.raleway(fontSize: 12.5),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      key: const Key('selectedSensorChartValue'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: widget.accentColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        '${selectedReading.temperatureC}°C  •  '
                        '${_numberFormat.format(selectedReading.resistanceOhms)} Ω',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.raleway(
                          fontWeight: FontWeight.w700,
                          color: atmosphericPrimaryText,
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
  final int? selectedIndex;

  const _ResistanceChartPainter({
    required this.readings,
    required this.accentColor,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (readings.isEmpty) return;

    final chartWidth = size.width - _chartLeft - _chartRight;
    final chartHeight = size.height - _chartTop - _chartBottom;
    if (chartWidth <= 0 || chartHeight <= 0) return;

    final maximumResistance = readings
        .map((reading) => reading.resistanceOhms)
        .reduce(math.max)
        .toDouble();
    final verticalMaximum = maximumResistance * 1.08;

    final gridPaint = Paint()
      ..color = const Color(0xFF3C3E3E)
      ..strokeWidth = 1;
    final axisPaint = Paint()
      ..color = const Color(0xFF9A9C9C)
      ..strokeWidth = 1.2;

    for (var index = 0; index <= 4; index++) {
      final y = _chartTop + chartHeight * index / 4;
      canvas.drawLine(
        Offset(_chartLeft, y),
        Offset(size.width - _chartRight, y),
        gridPaint,
      );
      final value = verticalMaximum * (1 - index / 4);
      _paintLabel(
        canvas,
        _compactNumber(value),
        Offset(_chartLeft - 6, y),
        alignRight: true,
        centerVertically: true,
      );
    }

    canvas.drawLine(
      const Offset(_chartLeft, _chartTop),
      Offset(_chartLeft, _chartTop + chartHeight),
      axisPaint,
    );
    canvas.drawLine(
      Offset(_chartLeft, _chartTop + chartHeight),
      Offset(size.width - _chartRight, _chartTop + chartHeight),
      axisPaint,
    );

    final points = <Offset>[];
    for (var index = 0; index < readings.length; index++) {
      final reading = readings[index];
      final x = _chartLeft + chartWidth * index / (readings.length - 1);
      final y =
          _chartTop +
          chartHeight * (1 - reading.resistanceOhms / verticalMaximum);
      points.add(Offset(x, y));

      if (index.isEven) {
        _paintLabel(
          canvas,
          '${reading.temperatureC}°',
          Offset(x, _chartTop + chartHeight + 8),
          centerHorizontally: true,
        );
      }
    }

    final fillPath = Path()
      ..moveTo(points.first.dx, _chartTop + chartHeight)
      ..lineTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath
      ..lineTo(points.last.dx, _chartTop + chartHeight)
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

    final pointPaint = Paint()..color = atmosphericPrimaryText;
    for (final point in points) {
      canvas.drawCircle(point, 2.6, pointPaint);
    }

    final selected = selectedIndex;
    if (selected != null && selected >= 0 && selected < points.length) {
      final point = points[selected];
      canvas.drawLine(
        Offset(point.dx, point.dy + 7),
        Offset(point.dx, _chartTop + chartHeight),
        Paint()
          ..color = accentColor.withValues(alpha: 0.5)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(point, 6.5, Paint()..color = accentColor);
      canvas.drawCircle(point, 2.5, Paint()..color = Colors.white);
      _paintValueCallout(canvas, size, point, readings[selected]);
    }
  }

  void _paintValueCallout(
    Canvas canvas,
    Size size,
    Offset point,
    SensorResistanceReading reading,
  ) {
    final value = NumberFormat.decimalPattern(
      'en_GB',
    ).format(reading.resistanceOhms);
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${reading.temperatureC}°C  $value Ω',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    const horizontalPadding = 7.0;
    const verticalPadding = 5.0;
    final width = textPainter.width + horizontalPadding * 2;
    final height = textPainter.height + verticalPadding * 2;
    final left = (point.dx - width / 2).clamp(2.0, size.width - width - 2);
    final top = (point.dy - height - 9).clamp(2.0, size.height - height - 2);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(left, top, width, height),
      const Radius.circular(6),
    );
    canvas.drawRRect(rect, Paint()..color = const Color(0xFF333333));
    textPainter.paint(
      canvas,
      Offset(left + horizontalPadding, top + verticalPadding),
    );
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
        style: const TextStyle(fontSize: 10, color: atmosphericSecondaryText),
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
        oldDelegate.accentColor != accentColor ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}
