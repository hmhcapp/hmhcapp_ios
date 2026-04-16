import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CableInfo {
  final String productCode;
  final double length;

  const CableInfo(this.productCode, this.length);
}

class CableSpacingRule {
  final double minSpacing;
  final double maxSpacing;

  const CableSpacingRule({
    required this.minSpacing,
    required this.maxSpacing,
  });
}

final pkc3Cables = <CableInfo>[
  CableInfo('PKC-3.0-0120', 9.4),
  CableInfo('PKC-3.0-0190', 15.3),
  CableInfo('PKC-3.0-0290', 22.8),
  CableInfo('PKC-3.0-0370', 29.7),
  CableInfo('PKC-3.0-0470', 37.5),
  CableInfo('PKC-3.0-0550', 43.8),
  CableInfo('PKC-3.0-0650', 52.5),
  CableInfo('PKC-3.0-0840', 67.0),
  CableInfo('PKC-3.0-0980', 79.0),
  CableInfo('PKC-3.0-1090', 87.0),
  CableInfo('PKC-3.0-1230', 98.0),
  CableInfo('PKC-3.0-1370', 110.0),
  CableInfo('PKC-3.0-1630', 130.0),
  CableInfo('PKC-3.0-1770', 142.0),
  CableInfo('PKC-3.0-1920', 153.0),
  CableInfo('PKC-3.0-2170', 174.0),
];

final hmhCabCables = <CableInfo>[
  CableInfo('HMHCAB3.5-130W', 8.4),
  CableInfo('HMHCAB3.5-230W', 14.9),
  CableInfo('HMHCAB3.5-300W', 19.5),
  CableInfo('HMHCAB3.5-450W', 29.5),
  CableInfo('HMHCAB3.5-730W', 49.0),
  CableInfo('HMHCAB3.5-880W', 59.0),
  CableInfo('HMHCAB3.5-1170W', 78.0),
  CableInfo('HMHCAB3.5-1470W', 98.0),
  CableInfo('HMHCAB3.5-2190W', 147.0),
];

final pkc5Cables = <CableInfo>[
  CableInfo('PKC-5.0-0200', 10.0),
  CableInfo('PKC-5.0-0300', 15.0),
  CableInfo('PKC-5.0-0400', 20.0),
  CableInfo('PKC-5.0-0500', 25.0),
  CableInfo('PKC-5.0-0600', 30.0),
  CableInfo('PKC-5.0-0700', 35.0),
  CableInfo('PKC-5.0-0800', 40.0),
  CableInfo('PKC-5.0-0900', 45.0),
  CableInfo('PKC-5.0-1000', 50.0),
  CableInfo('PKC-5.0-1200', 60.0),
  CableInfo('PKC-5.0-1400', 70.0),
  CableInfo('PKC-5.0-1600', 80.0),
  CableInfo('PKC-5.0-1800', 90.0),
  CableInfo('PKC-5.0-2000', 100.0),
  CableInfo('PKC-5.0-2400', 120.0),
  CableInfo('PKC-5.0-3000', 150.0),
];

final cableDataMap = <String, List<CableInfo>>{
  'PKC-3.0': pkc3Cables,
  'HMHCAB3.5': hmhCabCables,
  'PKC-5.0': pkc5Cables,
};

const cableSpacingRules = <String, CableSpacingRule>{
  'PKC-3.0': CableSpacingRule(minSpacing: 6.4, maxSpacing: 14.0),
  'PKC-5.0': CableSpacingRule(minSpacing: 6.4, maxSpacing: 18.0),
  'HMHCAB3.5': CableSpacingRule(minSpacing: 6.4, maxSpacing: 12.5),
};

class CableSpacingCalculatorScreen extends StatefulWidget {
  const CableSpacingCalculatorScreen({super.key});

  @override
  State<CableSpacingCalculatorScreen> createState() =>
      _CableSpacingCalculatorScreenState();
}

class _CableSpacingCalculatorScreenState
    extends State<CableSpacingCalculatorScreen> {
  static const _maxSupportedArea = 50.0;

  String roomAreaInput = '';
  String selectedCableType = cableDataMap.keys.first;

  CableInfo? selectedCable1;

  bool isManualEntry = false;
  String manualLengthInput = '';
  bool isCalculating = false;
  double? calculatedSpacing;

  bool showWarningMessage = false;
  String warningMessageText = '';

  final appBarColor = const Color(0xFFEFA528);

  double? get _roomArea => double.tryParse(roomAreaInput);
  bool get _hasValidRoomArea =>
      _roomArea != null && _roomArea! > 0 && _roomArea! <= _maxSupportedArea;

  List<CableInfo> _cablesForType(String type) => cableDataMap[type] ?? const [];

  double _spacingFor(double area, double length) => (area * 100) / length;

  double _minTotalLength(String cableType, double area) {
    final rule = cableSpacingRules[cableType]!;
    return (area * 100) / rule.maxSpacing;
  }

  double _maxTotalLength(String cableType, double area) {
    final rule = cableSpacingRules[cableType]!;
    return (area * 100) / rule.minSpacing;
  }

  double _maxSingleCableArea(String cableType) {
    final cables = _cablesForType(cableType);
    if (cables.isEmpty) return 0;
    final longestLength = cables
        .map((cable) => cable.length)
        .reduce((current, next) => current > next ? current : next);
    final rule = cableSpacingRules[cableType]!;
    return (longestLength * rule.maxSpacing) / 100;
  }

  List<CableInfo> _filteredCableOptions(String cableType) {
    final area = _roomArea;
    final rule = cableSpacingRules[cableType];
    final cables = _cablesForType(cableType);
    if (area == null || area <= 0 || area > _maxSupportedArea || rule == null) {
      return const [];
    }

    return cables.where((cable) {
      final spacing = _spacingFor(area, cable.length);
      return spacing >= rule.minSpacing && spacing <= rule.maxSpacing;
    }).toList();
  }

  void _resetCableSelections() {
    selectedCable1 = null;
    calculatedSpacing = null;
  }

  void _syncSingleCableSelection() {
    if (!_hasValidRoomArea || isManualEntry) {
      _resetCableSelections();
      return;
    }
    final options = _filteredCableOptions(selectedCableType);
    final stillValid = selectedCable1 != null &&
        options.any((cable) => cable.productCode == selectedCable1!.productCode);
    if (!stillValid) {
      selectedCable1 = null;
    }
    calculatedSpacing = null;
  }

  String _areaHint() {
    final area = _roomArea;
    if (roomAreaInput.trim().isEmpty) {
      return 'Enter the room area first to unlock the calculator.';
    }
    if (area == null || area <= 0) {
      return 'Please enter a valid room area.';
    }
    if (area > _maxSupportedArea) {
      return 'This calculator currently supports rooms up to ${_maxSupportedArea.toStringAsFixed(0)} m².';
    }
    return 'Only single cables are shown, filtered to the valid spacing range for the selected cable type.';
  }

  String? _coverageWarning() {
    if (!_hasValidRoomArea || isManualEntry) return null;
    if (_filteredCableOptions(selectedCableType).isNotEmpty) return null;
    return 'No single cable matches this room area within the spacing rules for $selectedCableType.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cable Spacing Calculator',
          style: GoogleFonts.raleway(color: Colors.white),
        ),
        backgroundColor: appBarColor,
        leading: const BackButton(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.calculate, color: Colors.white),
          ),
        ],
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Room Area (m²)',
                    labelStyle: GoogleFonts.raleway(),
                    border: const OutlineInputBorder(),
                    helperText: _areaHint(),
                    helperStyle: GoogleFonts.raleway(fontSize: 12),
                  ),
                  onChanged: (value) => setState(() {
                    roomAreaInput = value;
                    _syncSingleCableSelection();
                  }),
                ),
                const SizedBox(height: 16),
                if (!isManualEntry) ...[
                  _CoverageGuideCard(
                    cableType: selectedCableType,
                    singleCableArea: _maxSingleCableArea(selectedCableType),
                    roomArea: _roomArea,
                  ),
                  const SizedBox(height: 12),
                  FormDropDown(
                    label: 'Select Cable Type',
                    options: cableDataMap.keys.toList(),
                    selectedOption: selectedCableType,
                    enabled: _hasValidRoomArea,
                    onOptionSelected: (value) {
                      setState(() {
                        selectedCableType = value;
                        _syncSingleCableSelection();
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],
                Opacity(
                  opacity: _hasValidRoomArea ? 1 : 0.55,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Enter total length manually',
                          style: GoogleFonts.raleway(),
                        ),
                      ),
                      Switch(
                        value: isManualEntry,
                        onChanged: !_hasValidRoomArea
                            ? null
                            : (value) {
                                setState(() {
                                  isManualEntry = value;
                                  calculatedSpacing = null;
                                  if (!value) {
                                    _syncSingleCableSelection();
                                  } else {
                                    _resetCableSelections();
                                  }
                                });
                              },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                if (!isManualEntry) ...[
                  if (_coverageWarning() != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _coverageWarning()!,
                          style: GoogleFonts.raleway(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AdditionalCableSelector(
                        label: 'Product Code 1',
                        cableOptions: _filteredCableOptions(selectedCableType),
                        selectedCable: selectedCable1,
                        enabled: _hasValidRoomArea,
                        onCableSelected: (value) => setState(() {
                          selectedCable1 = value;
                          calculatedSpacing = null;
                      }),
                      onClear: () => setState(() {
                        selectedCable1 = null;
                        calculatedSpacing = null;
                      }),
                    ),
                  ),
                ],
                if (isManualEntry)
                  TextField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    enabled: _hasValidRoomArea,
                    decoration: InputDecoration(
                      labelText: 'Total Cable Length (m)',
                      labelStyle: GoogleFonts.raleway(),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (value) =>
                        setState(() => manualLengthInput = value),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        isCalculating || !_hasValidRoomArea ? null : _calculate,
                    style: FilledButton.styleFrom(
                      backgroundColor: appBarColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: isCalculating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.calculate),
                    label: Text(
                      isCalculating ? 'Calculating...' : 'Calculate Spacing',
                      style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (calculatedSpacing != null)
                  _ResultCard(
                    appBarColor: appBarColor,
                    value: calculatedSpacing!,
                  ),
                if (calculatedSpacing != null)
                  _Visual(
                    appBarColor: appBarColor,
                    value: calculatedSpacing!,
                    type: isManualEntry ? 'manual' : selectedCableType,
                  ),
              ],
            ),
          ),
          if (showWarningMessage)
            Padding(
              padding: const EdgeInsets.all(16),
              child: _WarningBanner(
                text: warningMessageText,
                color: appBarColor,
                onDismissed: () => setState(() => showWarningMessage = false),
              ),
            ),
        ],
      ),
    );
  }

  void _calculate() async {
    setState(() {
      isCalculating = true;
      calculatedSpacing = null;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    final area = double.tryParse(roomAreaInput);
    final length = isManualEntry
        ? double.tryParse(manualLengthInput)
        : (selectedCable1?.length ?? 0);

    if (area == null || area <= 0) {
      setState(() {
        warningMessageText = 'Please enter a valid room area.';
        showWarningMessage = true;
        isCalculating = false;
      });
      return;
    }

    if (area > _maxSupportedArea) {
      setState(() {
        warningMessageText =
            'This calculator currently supports rooms up to ${_maxSupportedArea.toStringAsFixed(0)} m².';
        showWarningMessage = true;
        isCalculating = false;
      });
      return;
    }

    if (length == null || length <= 0) {
      setState(() {
        warningMessageText = 'Please select or enter a valid cable length.';
        showWarningMessage = true;
        isCalculating = false;
      });
      return;
    }

    setState(() {
      calculatedSpacing = _spacingFor(area, length);
      isCalculating = false;
    });
  }
}

class AdditionalCableSelector extends StatelessWidget {
  final String label;
  final List<CableInfo> cableOptions;
  final CableInfo? selectedCable;
  final ValueChanged<CableInfo?> onCableSelected;
  final VoidCallback onClear;
  final bool enabled;

  const AdditionalCableSelector({
    super.key,
    required this.label,
    required this.cableOptions,
    required this.selectedCable,
    required this.onCableSelected,
    required this.onClear,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final dropdownItems = cableOptions
        .map(
          (cable) => DropdownMenuItem<String>(
            value: '${cable.productCode} (${cable.length} m)',
            child: Text(
              '${cable.productCode} (${cable.length} m)',
              style: GoogleFonts.raleway(color: Colors.black87),
            ),
          ),
        )
        .toList();

    return Row(
      children: [
        Expanded(
          child: FormDropDown(
            label: label,
            items: dropdownItems,
            selectedOption: selectedCable != null
                ? '${selectedCable!.productCode} (${selectedCable!.length} m)'
                : 'Please select...',
            enabled: enabled,
            onOptionSelected: (display) {
              final found = cableOptions.firstWhere(
                (cable) => '${cable.productCode} (${cable.length} m)' == display,
                orElse: () => const CableInfo('', 0),
              );
              onCableSelected(found.productCode.isEmpty ? null : found);
            },
          ),
        ),
        if (label != 'Product Code 1')
          IconButton(
            onPressed: enabled ? onClear : null,
            icon: const Icon(Icons.clear),
            tooltip: 'Remove Cable',
          ),
      ],
    );
  }
}

class _CoverageGuideCard extends StatelessWidget {
  final String cableType;
  final double singleCableArea;
  final double? roomArea;

  const _CoverageGuideCard({
    required this.cableType,
    required this.singleCableArea,
    required this.roomArea,
  });

  @override
  Widget build(BuildContext context) {
    final area = roomArea;
    final needsMultiple = area != null && area > singleCableArea;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: needsMultiple ? const Color(0xFFFFF4E4) : const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: needsMultiple ? const Color(0xFFEFA528) : const Color(0xFFD9D9D9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: needsMultiple ? const Color(0xFFEFA528) : const Color(0xFF555555),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              needsMultiple ? Icons.auto_awesome : Icons.info_outline,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  needsMultiple
                      ? 'This room is likely to need more than one cable'
                      : 'Single-cable coverage guide',
                  style: GoogleFonts.raleway(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'With one $cableType cable, the largest practical area is about '
                  '${singleCableArea.toStringAsFixed(1)} m². Larger rooms may need a second or third cable.',
                  style: GoogleFonts.raleway(
                    color: Colors.black87,
                    height: 1.35,
                  ),
                ),
                if (area != null && area > 0) ...[
                  const SizedBox(height: 8),
                  Text(
                    needsMultiple
                        ? 'Current room area: ${area.toStringAsFixed(area % 1 == 0 ? 0 : 1)} m². This is beyond the practical single-cable area for $cableType.'
                        : 'Current room area: ${area.toStringAsFixed(area % 1 == 0 ? 0 : 1)} m².',
                    style: GoogleFonts.raleway(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double value;
  final Color appBarColor;

  const _ResultCard({required this.value, required this.appBarColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Required Cable Spacing:',
                style: GoogleFonts.raleway(
                  color: Colors.black.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${value.toStringAsFixed(1)} cm',
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: appBarColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Visual extends StatelessWidget {
  final double value;
  final Color appBarColor;
  final String type;

  const _Visual({
    required this.value,
    required this.appBarColor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = switch (type) {
      'PKC-3.0' => 'assets/images/pkc3spacing.png',
      'PKC-5.0' => 'assets/images/pkc5spacing.png',
      'HMHCAB3.5' => 'assets/images/hmhspacing.png',
      _ => 'assets/images/cablespacing.png',
    };

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            width: double.infinity,
          ),
        ),
        Positioned(
          right: 125,
          top: 100,
          child: Text(
            '${value.toStringAsFixed(1)} cm',
            style: GoogleFonts.raleway(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: appBarColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _WarningBanner extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onDismissed;

  const _WarningBanner({
    required this.text,
    required this.color,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black87,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.raleway(color: Colors.white),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onDismissed,
            ),
          ],
        ),
      ),
    );
  }
}

class FormDropDown extends StatelessWidget {
  final String label;
  final List<String>? options;
  final List<DropdownMenuItem<String>>? items;
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;
  final bool enabled;

  const FormDropDown({
    super.key,
    required this.label,
    this.options,
    this.items,
    required this.selectedOption,
    required this.onOptionSelected,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedItems = items ??
        (options ?? [])
            .map(
              (option) => DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              ),
            )
            .toList();
    final values =
        resolvedItems.map((item) => item.value).whereType<String>().toList();

    return DropdownButtonFormField<String>(
      value: values.contains(selectedOption) ? selectedOption : null,
      items: resolvedItems,
      onChanged: enabled
          ? (value) {
              if (value != null) onOptionSelected(value);
            }
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: !enabled,
        fillColor: enabled ? null : Colors.grey.shade200,
      ),
    );
  }
}
