import 'package:flutter/material.dart';
import '../../../design/mind_tokens.dart';
import '../../../core/settings/settings_model.dart' show FaithTier;

class WeeklyReviewScreen extends StatefulWidget {
  final FaithTier faithTier;
  const WeeklyReviewScreen({super.key, required this.faithTier});

  @override
  State<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends State<WeeklyReviewScreen> {
  final Map<String, bool> _completedItems = {};

  List<Widget> _items(){
    final base = [
      'Clear inboxes (email/messages)',
      'What moved the mission? Schedule next steps',
      'Time-block next week with buffers'
    ];
    if (widget.faithTier.isActivated) {
      base.addAll([
        'Gratitude: name 3 mercies this week',
        'Confession: where did I drift? Receive grace',
        'Mission: who can I serve this week?'
      ]);
    }
    return base.map((t)=>CheckboxListTile(
      title: Text(t),
      value: _completedItems[t] ?? false,
      onChanged: (value) {
        setState(() {
          _completedItems[t] = value ?? false;
        });
      },
      activeColor: MindColors.lime,
    )).toList();
  }

  @override
  Widget build(BuildContext context){
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weekly Review'),
          backgroundColor: MindColors.bg,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Weekly Review Checklist', 
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('Take 15 minutes to reflect on the week and plan ahead.',
                  style: TextStyle(color: MindColors.textSub)),
                const SizedBox(height: 16),
                ..._items(),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final completedCount = _completedItems.values.where((v) => v).length;
                      final totalCount = _completedItems.length;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Review saved! $completedCount/$totalCount items completed.'))
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Complete Review', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
