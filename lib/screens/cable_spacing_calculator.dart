import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CableInfo {
  final String productCode;
  final double length;
  CableInfo(this.productCode, this.length);
}

final pkc3Cables = <CableInfo>[
  CableInfo("PKC-3.0-0120", 9.4),
  CableInfo("PKC-3.0-0190", 15.3),
  CableInfo("PKC-3.0-0290", 22.8),
  CableInfo("PKC-3.0-0370", 29.7),
  CableInfo("PKC-3.0-0470", 37.5),
  CableInfo("PKC-3.0-0550", 43.8),
  CableInfo("PKC-3.0-0650", 52.5),
  CableInfo("PKC-3.0-0840", 67.0),
  CableInfo("PKC-3.0-0980", 79.0),
  CableInfo("PKC-3.0-1090", 87.0),
  CableInfo("PKC-3.0-1230", 98.0),
  CableInfo("PKC-3.0-1370", 110.0),
  CableInfo("PKC-3.0-1630", 130.0),
  CableInfo("PKC-3.0-1770", 142.0),
  CableInfo("PKC-3.0-1920", 153.0),
  CableInfo("PKC-3.0-2170", 174.0),
];

final hmhCabCables = <CableInfo>[
  CableInfo("HMHCAB3.5-130W", 8.4),
  CableInfo("HMHCAB3.5-230W", 14.9),
  CableInfo("HMHCAB3.5-300W", 19.5),
  CableInfo("HMHCAB3.5-450W", 29.5),
  CableInfo("HMHCAB3.5-730W", 49.0),
  CableInfo("HMHCAB3.5-880W", 59.0),
  CableInfo("HMHCAB3.5-1170W", 78.0),
  CableInfo("HMHCAB3.5-1470W", 98.0),
  CableInfo("HMHCAB3.5-2190W", 147.0),
];

final pkc5Cables = <CableInfo>[
  CableInfo("PKC-5.0-0200", 10.0),
  CableInfo("PKC-5.0-0300", 15.0),
  CableInfo("PKC-5.0-0400", 20.0),
  CableInfo("PKC-5.0-0500", 25.0),
  CableInfo("PKC-5.0-0600", 30.0),
  CableInfo("PKC-5.0-0700", 35.0),
  CableInfo("PKC-5.0-0800", 40.0),
  CableInfo("PKC-5.0-0900", 45.0),
  CableInfo("PKC-5.0-1000", 50.0),
  CableInfo("PKC-5.0-1200", 60.0),
  CableInfo("PKC-5.0-1400", 70.0),
  CableInfo("PKC-5.0-1600", 80.0),
  CableInfo("PKC-5.0-1800", 90.0),
  CableInfo("PKC-5.0-2000", 100.0),
  CableInfo("PKC-5.0-2400", 120.0),
  CableInfo("PKC-5.0-3000", 150.0),
];

final cableDataMap = <String, List<CableInfo>>{
  "PKC-3.0": pkc3Cables,
  "HMHCAB3.5": hmhCabCables,
  "PKC-5.0": pkc5Cables,
};

class CableSpacingCalculatorScreen extends StatefulWidget {
  const CableSpacingCalculatorScreen({super.key});

  @override
  State<CableSpacingCalculatorScreen> createState() => _CableSpacingCalculatorScreenState();
}

class _CableSpacingCalculatorScreenState extends State<CableSpacingCalculatorScreen> {
  String roomAreaInput = '';
  String selectedCableType = cableDataMap.keys.first;

  CableInfo? selectedCable1;
  CableInfo? selectedCable2;
  CableInfo? selectedCable3;
  int cableSelectorCount = 1;

  bool isManualEntry = false;
  String manualLengthInput = '';
  bool isCalculating = false;
  double? calculatedSpacing;

  bool showWarningMessage = false;
  String warningMessageText = '';

  final appBarColor = const Color(0xFFEFA528);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cable Spacing Calculator', style: GoogleFonts.raleway(color: Colors.white)),
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
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Room Area (m²)',
                    labelStyle: GoogleFonts.raleway(),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) => setState(() => roomAreaInput = v),
                ),

                const SizedBox(height: 16),

                if (!isManualEntry) ...[
                  FormDropDown(
                    label: 'Select Cable Type',
                    options: cableDataMap.keys.toList(),
                    selectedOption: selectedCableType,
                    onOptionSelected: (v) {
                      setState(() {
                        selectedCableType = v;
                        selectedCable1 = null;
                        selectedCable2 = null;
                        selectedCable3 = null;
                        cableSelectorCount = 1;
                        calculatedSpacing = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Enter total length manually', style: GoogleFonts.raleway()),
                    Switch(
                      value: isManualEntry,
                      onChanged: (val) {
                        setState(() {
                          isManualEntry = val;
                          calculatedSpacing = null;
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (!isManualEntry) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: AdditionalCableSelector(
                      label: 'Product Code 1',
                      cableOptions: cableDataMap[selectedCableType] ?? const [],
                      selectedCable: selectedCable1,
                      onCableSelected: (v) => setState(() => selectedCable1 = v),
                      onClear: () => setState(() => selectedCable1 = null),
                    ),
                  ),
                  if (cableSelectorCount >= 2)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AdditionalCableSelector(
                        label: 'Product Code 2',
                        cableOptions: cableDataMap[selectedCableType] ?? const [],
                        selectedCable: selectedCable2,
                        onCableSelected: (v) => setState(() => selectedCable2 = v),
                        onClear: () => setState(() {
                          selectedCable2 = null;
                          selectedCable3 = null;
                          cableSelectorCount = 1;
                        }),
                      ),
                    ),
                  if (cableSelectorCount >= 3)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: AdditionalCableSelector(
                        label: 'Product Code 3',
                        cableOptions: cableDataMap[selectedCableType] ?? const [],
                        selectedCable: selectedCable3,
                        onCableSelected: (v) => setState(() => selectedCable3 = v),
                        onClear: () => setState(() {
                          selectedCable3 = null;
                          cableSelectorCount = 2;
                        }),
                      ),
                    ),

                  if (cableSelectorCount == 1 && selectedCable1 != null)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => cableSelectorCount = 2),
                      icon: const Icon(Icons.add),
                      label: Text('Add a second cable', style: GoogleFonts.raleway()),
                    )
                  else if (cableSelectorCount == 2 && selectedCable2 != null)
                    OutlinedButton.icon(
                      onPressed: () => setState(() => cableSelectorCount = 3),
                      icon: const Icon(Icons.add),
                      label: Text('Add a third cable', style: GoogleFonts.raleway()),
                    ),
                ],

                if (isManualEntry)
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Total Cable Length (m)',
                      labelStyle: GoogleFonts.raleway(),
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) => setState(() => manualLengthInput = v),
                  ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isCalculating ? null : _calculate,
                    style: FilledButton.styleFrom(
                      backgroundColor: appBarColor,   // ✅ match AppBar colour
                      foregroundColor: Colors.white,   // text & icon colour
                    ),
                    icon: isCalculating
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.calculate),
                    label: Text(
                      isCalculating ? 'Calculating…' : 'Calculate Spacing',
                      style: GoogleFonts.raleway(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                if (calculatedSpacing != null)
                  _ResultCard(appBarColor: appBarColor, value: calculatedSpacing!),

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
              padding: const EdgeInsets.all(16.0),
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
        : ((selectedCable1?.length ?? 0) + (selectedCable2?.length ?? 0) + (selectedCable3?.length ?? 0));

    if (area == null || area <= 0) {
      setState(() {
        warningMessageText = 'Please enter a valid room area.';
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
      calculatedSpacing = (area * 100) / length;
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

  const AdditionalCableSelector({
    super.key,
    required this.label,
    required this.cableOptions,
    required this.selectedCable,
    required this.onCableSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FormDropDown(
            label: label,
            options: cableOptions.map((e) => '${e.productCode} (${e.length} m)').toList(),
            selectedOption: selectedCable != null ? '${selectedCable!.productCode} (${selectedCable!.length} m)' : 'Please select...',
            onOptionSelected: (display) {
              final found = cableOptions.firstWhere(
                (e) => '${e.productCode} (${e.length} m)' == display,
                orElse: () => CableInfo('', 0),
              );
              onCableSelected(found.productCode.isEmpty ? null : found);
            },
          ),
        ),
        if (label != 'Product Code 1')
          IconButton(
            onPressed: onClear,
            icon: const Icon(Icons.clear),
            tooltip: 'Remove Cable',
          ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final double value;
  final Color appBarColor;
  const _ResultCard({required this.value, required this.appBarColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox( // ensure full width
      width: double.infinity,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('Required Cable Spacing:', style: GoogleFonts.raleway(color: Colors.black.withOpacity(0.7))),
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
  const _Visual({required this.value, required this.appBarColor, required this.type});

  @override
  Widget build(BuildContext context) {
    final String assetPath = switch (type) {
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
            width: double.infinity, // ensure it uses full width of the column
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
  const _WarningBanner({required this.text, required this.color, required this.onDismissed});

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
            Expanded(child: Text(text, style: GoogleFonts.raleway(color: Colors.white))),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: onDismissed,
            )
          ],
        ),
      ),
    );
  }
}

/// Simple Dropdown – replace with your shared component if you have one
class FormDropDown extends StatelessWidget {
  final String label;
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;

  const FormDropDown({
    super.key,
    required this.label,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: options.contains(selectedOption) ? selectedOption : null,
      items: options.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: (v) {
        if (v != null) onOptionSelected(v);
      },
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
