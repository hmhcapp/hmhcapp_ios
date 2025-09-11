import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';
import 'checklist_shared.dart';

class HeatingCableChecklistScreen extends StatefulWidget {
  const HeatingCableChecklistScreen({super.key});

  @override
  State<HeatingCableChecklistScreen> createState() => _HeatingCableChecklistScreenState();
}

class _HeatingCableChecklistScreenState extends State<HeatingCableChecklistScreen> {
  late final PageController _page;
  int _index = 0;

  // === Steps ported from your Kotlin ViewModel ===
  late List<ChecklistStep> steps = [
    ChecklistStep('1. Pre-Installation Checks', [
      ChecklistItem(1, 'Ensure sub-floor is clean, dry, rigid and suitable for tiling.'),
      ChecklistItem(2, 'Confirm the correct length heating cable has been supplied.'),
      ChecklistItem(3, 'Plan the cable layout, ensuring the correct spacing for the required output.'),
      ChecklistItem(4, 'Perform initial resistance tests (Continuity & Insulation) and record on the warranty card.'),
      ChecklistItem(5, 'Install floor sensor conduit from the thermostat location into the floor.'),
    ]),
    ChecklistStep('2. Laying the Cable', [
      ChecklistItem(6, 'Install insulation boards if required.'),
      ChecklistItem(7, 'Lay the double-sided tape in rows approx 500mm apart.'),
      // Deep-link to Cable Spacing Calculator
      ChecklistItem(
        8,
        'Measure and mark out your chosen cable to cable spacing.',
        actionRoute: Routes.cableSpacingCalculator,
      ),
      ChecklistItem(9, 'Lay out your cable to your chosen spacing, across the tape and press cable to tape.'),
      ChecklistItem(10, 'Position the factory joint on the floor and ensure the cold tail can reach the thermostat.'),
      ChecklistItem(11, 'Install the floor sensor between two runs, at least 500mm into the heated area.'),
      ChecklistItem(12, 'Perform a second round of resistance tests and record the results.'),
    ]),
    ChecklistStep('3. Electrical Connections', [
      ChecklistItem(13, 'Ensure all electrical work is by a qualified electrician and Part P compliant.'),
      ChecklistItem(14, 'Connect the system to a dedicated, RCD-protected circuit.'),
      ChecklistItem(15, 'Connect the heating cable power leads (“cold tail”) to the thermostat.'),
      ChecklistItem(16, 'Connect the floor sensor wires to the correct thermostat terminals.'),
    ]),
    ChecklistStep('4. Final Checks & Handover', [
      ChecklistItem(17, 'Take a photograph of the complete installation before covering.'),
      ChecklistItem(18, 'Cover the cables with suitable tile adhesive or levelling compound.'),
      ChecklistItem(19, 'Final resistance tests after covering, record the results.'),
      ChecklistItem(20, 'Advise homeowner not to switch on until floor covering is fully cured.'),
      ChecklistItem(21, 'Tap Finish and use our warranty section to register the warranty.'),
    ]),
  ];

  @override
  void initState() {
    super.initState();
    _page = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _toggle(int id) {
    setState(() {
      for (final s in steps) {
        for (final i in s.items) {
          if (i.id == id) i.isChecked = !i.isChecked;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor = const Color(0xFF333333);

    return Scaffold(
      appBar: AppBar(
        title: Text('Heating Cables Checklist', style: GoogleFonts.raleway(color: Colors.white)),
        backgroundColor: appBarColor,
        leading: const BackButton(color: Colors.white),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.playlist_add_check, color: Colors.white),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              _index < steps.length
                  ? 'Step ${_index + 1} of ${steps.length}'
                  : 'Complete',
              style: GoogleFonts.raleway(fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _page,
              onPageChanged: (i) => setState(() => _index = i),
              itemCount: steps.length + 1, // +1 for completion page
              itemBuilder: (_, i) {
                if (i < steps.length) {
                  return ChecklistStepPage(
                    step: steps[i],
                    onToggle: _toggle,
                    onNavigate: (route) => Navigator.pushNamed(context, route),
                  );
                }
                return ChecklistCompletionPage(
                  onRegisterWarranty: () => Navigator.pushNamed(context, Routes.registerWarranty),
                  onFinish: () => Navigator.popUntil(
                    context,
                    (r) => r.settings.name == Routes.installerTools || r.isFirst,
                  ),
                );
              },
            ),
          ),
          _BottomNav(
            canBack: _index > 0,
            isLast: _index == steps.length,
            onBack: () => _page.previousPage(duration: const Duration(milliseconds: 200), curve: Curves.easeOut),
            onNext: () {
              if (_index < steps.length) {
                _page.nextPage(duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final bool canBack;
  final bool isLast;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _BottomNav({
    required this.canBack,
    required this.isLast,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Row(
          children: [
            Expanded(child: OutlinedButton(onPressed: canBack ? onBack : null, child: const Text('Back'))),
            const SizedBox(width: 12),
            Expanded(child: FilledButton(onPressed: isLast ? null : onNext, child: Text(isLast ? 'Done' : 'Next'))),
          ],
        ),
      ),
    );
  }
}