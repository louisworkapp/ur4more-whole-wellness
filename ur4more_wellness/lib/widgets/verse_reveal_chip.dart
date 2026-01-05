import 'package:flutter/material.dart';
import '../core/services/settings_service.dart';
import '../services/faith_service.dart';
import '../core/settings/settings_model.dart';

class VerseRevealChip extends StatefulWidget {
  final FaithTier mode;
  final String ref;
  final String text; // ≤ 2 sentences (KJV)
  final bool askConsentLight; // true = ask once per session in Light

  const VerseRevealChip({
    super.key,
    required this.mode,
    required this.ref,
    required this.text,
    this.askConsentLight = true,
  });

  @override
  State<VerseRevealChip> createState() => _VerseRevealChipState();
}

class _VerseRevealChipState extends State<VerseRevealChip> {
  bool _revealed = false;
  bool _consentedThisSession = false;

  Future<void> _reveal() async {
    if (widget.mode == FaithTier.light && widget.askConsentLight && !_consentedThisSession) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Show verse?'),
          content: const Text('Would you like to see a short KJV verse for this moment?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Not now'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Show verse'),
            ),
          ],
        ),
      );
      if (ok != true) return;
      _consentedThisSession = true;
    }
    setState(() => _revealed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_revealed) {
      return ActionChip(
        label: const Text('Show verse'),
        onPressed: widget.mode.isActivated ? _reveal : null, // OFF never reveals scripture
      );
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '${widget.ref} — ${widget.text}',
        style: const TextStyle(height: 1.3),
      ),
    );
  }
}
