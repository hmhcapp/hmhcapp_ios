import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../routes.dart';
import 'checklist_shared.dart';

class HeatingMatChecklistScreen extends StatefulWidget {
  const HeatingMatChecklistScreen({super.key});

  @override
  State<HeatingMatChecklistScreen> createState() => _HeatingMatChecklistScreenState();
}

class _HeatingMatChecklistScreenState extends State<HeatingMatChecklistScreen> {
  late final PageController _page;
  int _index = 0;

  // Steps identical to your Kotlin content
  late List<ChecklistStep> steps = [
    ChecklistStep('1. Pre-Installation Checks', [
      ChecklistItem(1, 'Ensure sub-floor is clean, dry, and rigid.'),
      ChecklistItem(2, 'Plan mat layout, staying 50–100mm from walls and fixtures.'),
      ChecklistItem(3, 'Confirm correct product output.'),
      ChecklistItem(4, 'Perform initial resistance tests (Continuity & Insulation) and record results.'),
      ChecklistItem(5, 'Install floor sensor conduit from thermostat location to a central point in the heated area.'),
    ]),
    ChecklistStep('2. Laying the Mat', [
      ChecklistItem(6, 'Lay insulation boards if required for the floor type.'),
      ChecklistItem(7, 'Roll out the first run of the heating mat.'),
      ChecklistItem(8, 'To turn, cut the MESH ONLY. Never cut the heating cable.'),
      ChecklistItem(9, 'Position the mat so the cold tail can reach the thermostat/junction box.'),
      ChecklistItem(10, 'Secure the mat to the sub-floor using the built-in tape.'),
      ChecklistItem(11, 'Perform a second round of resistance tests and record results.'),
    ]),
    ChecklistStep('3. Electrical Connections', [
      ChecklistItem(12, 'Ensure all electrical work complies with local regulations.'),
      ChecklistItem(13, 'Connect the system to a dedicated, RCD-protected circuit.'),
      ChecklistItem(14, 'Connect the heating mat power leads to the thermostat.'),
      ChecklistItem(15, 'Connect the floor sensor wires to the thermostat.'),
    ]),
    ChecklistStep('4. Final Checks & Handover', [
      ChecklistItem(16, 'Take a photo of the completed installation before the floor covering is laid.'),
      ChecklistItem(17, 'Perform the final resistance tests after floor covering is laid and record.'),
      ChecklistItem(18, 'Advise the homeowner not to switch the system on until adhesive/levelling compound is fully cured.'),
      ChecklistItem(19, 'Tap Finish and use our warranty registration section to register the warranty.'),
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
        title: Text('Heating Mats Checklist', style: GoogleFonts.raleway(color: Colors.white)),
        backgroundColor: appBarColor,
        leading: const BackButton(color: Colors.white),
        actions: const [Padding(padding: EdgeInsets.only(right: 8), child: Icon(Icons.playlist_add_check, color: Colors.white))],
      ),
      body: Column(
        children: [
          // Step indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text('Step ${_index + 1} of ${steps.length}',
                style: GoogleFonts.raleway(fontWeight: FontWeight.w600, color: Colors.black54)),
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
                // Completion page
                return ChecklistCompletionPage(
                  onRegisterWarranty: () => Navigator.pushNamed(context, Routes.registerWarranty),
                  onFinish: () => Navigator.popUntil(context, (r) => r.settings.name == Routes.installerTools || r.isFirst),
                );
              },
            ),
          ),
          _BottomNav(
            canBack: _index > 0,
            isLast: _index == steps.length, // on completion page
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
            Expanded(
              child: OutlinedButton(
                onPressed: canBack ? onBack : null,
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: isLast ? null : onNext,
                child: Text(isLast ? 'Done' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}