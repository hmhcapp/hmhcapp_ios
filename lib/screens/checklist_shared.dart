import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/atmospheric_dark_background.dart';

const checklistAccentColor = Color(0xFFE9882A);
const checklistBackgroundColor = Colors.black;
const checklistTextColor = atmosphericPrimaryText;

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
            child: Text(
              step.title,
              style: GoogleFonts.raleway(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: checklistTextColor,
              ),
            ),
          );
        }
        final item = items[i - 1];
        return _ChecklistItemRow(
          item: item,
          onToggle: () => onToggle(item.id),
          onActionClick: item.actionRoute == null
              ? null
              : () => onNavigate?.call(item.actionRoute!),
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
      color: atmosphericSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.68),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: atmosphericBorder),
      ),
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
                  item.isChecked
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: item.isChecked
                      ? checklistAccentColor
                      : atmosphericSecondaryText,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.text,
                  style: GoogleFonts.raleway(
                    fontSize: 16,
                    color: checklistTextColor,
                  ),
                ),
              ),
              if (onActionClick != null) ...[
                const SizedBox(width: 8),
                const Icon(Icons.calculate, color: checklistAccentColor),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: checklistAccentColor,
                ),
              ],
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
            const Icon(
              Icons.check_circle,
              color: checklistAccentColor,
              size: 96,
            ),
            const SizedBox(height: 16),
            Text(
              'Installation Checklist Complete!',
              style: GoogleFonts.raleway(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: checklistTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'The final step is to register the product warranty.',
              style: GoogleFonts.raleway(
                fontSize: 16,
                color: checklistTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onRegisterWarranty,
                style: FilledButton.styleFrom(
                  backgroundColor: checklistAccentColor,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  'Register Warranty',
                  style: GoogleFonts.raleway(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onFinish,
              style: TextButton.styleFrom(
                foregroundColor: checklistAccentColor,
              ),
              child: const Text('Finish & Exit'),
            ),
          ],
        ),
      ),
    );
  }
}
