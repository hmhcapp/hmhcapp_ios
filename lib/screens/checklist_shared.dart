import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ===== MODELS =====
class ChecklistItem {
  final int id;
  final String text;
  final String? actionRoute; // optional deep-link (e.g., calculator)
  bool isChecked;
  ChecklistItem(this.id, this.text, {this.isChecked = false, this.actionRoute});
}

class ChecklistStep {
  final String title;
  final List<ChecklistItem> items;
  ChecklistStep(this.title, this.items);
}

// ===== COMPONENTS =====

class ChecklistStepPage extends StatelessWidget {
  final ChecklistStep step;
  final ValueChanged<int> onToggle;
  final void Function(String route)? onNavigate;

  const ChecklistStepPage({
    super.key,
    required this.step,
    required this.onToggle,
    this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final items = step.items;
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        if (i == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(step.title,
                style: GoogleFonts.raleway(fontSize: 22, fontWeight: FontWeight.w400)),
          );
        }
        final item = items[i - 1];
        return _ChecklistItemRow(
          item: item,
          onToggle: () => onToggle(item.id),
          onActionClick: item.actionRoute == null ? null : () => onNavigate?.call(item.actionRoute!),
        );
      },
    );
  }
}

class _ChecklistItemRow extends StatelessWidget {
  final ChecklistItem item;
  final VoidCallback onToggle;
  final VoidCallback? onActionClick;

  const _ChecklistItemRow({
    required this.item,
    required this.onToggle,
    this.onActionClick,
  });

  @override
  Widget build(BuildContext context) {
    final mainTap = onActionClick ?? onToggle;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: mainTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  item.isChecked ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: item.isChecked ? const Color(0xFF4CAF50) : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(item.text, style: GoogleFonts.raleway(fontSize: 16)),
              ),
              if (onActionClick != null) ...[
                const SizedBox(width: 8),
                Icon(Icons.calculate, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.primary),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class ChecklistCompletionPage extends StatelessWidget {
  final VoidCallback onRegisterWarranty;
  final VoidCallback onFinish;

  const ChecklistCompletionPage({
    super.key,
    required this.onRegisterWarranty,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 96),
            const SizedBox(height: 16),
            Text('Installation Checklist Complete!',
                style: GoogleFonts.raleway(fontSize: 22, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('The final step is to register the product warranty.',
                style: GoogleFonts.raleway(fontSize: 16),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRegisterWarranty,
                style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF4BE25)),
                child: Text('Register Warranty', style: GoogleFonts.raleway(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(onPressed: onFinish, child: const Text('Finish & Exit')),
          ],
        ),
      ),
    );
  }
}