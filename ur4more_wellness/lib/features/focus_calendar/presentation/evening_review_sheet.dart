import 'package:flutter/material.dart';
import '../../../design/mind_tokens.dart';

class EveningReviewSheet extends StatefulWidget {
  final VoidCallback onSave;
  const EveningReviewSheet({super.key, required this.onSave});
  @override State<EveningReviewSheet> createState() => _EveningReviewSheetState();
}

class _EveningReviewSheetState extends State<EveningReviewSheet> {
  final TextEditingController _reflectionController = TextEditingController();
  final List<String> _completedBlocks = [];
  final List<String> _availableBlocks = [
    'Mind: Box Breathing',
    'Body: 10-min Walk', 
    'Spirit: 60-sec Verse & Prayer',
    'Body: Mobility Snack',
    'Spirit: Walk in the Light',
  ];

  @override
  Widget build(BuildContext context){
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Evening Review (2-min)', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
            const SizedBox(height:8),
            const Text('What did you complete? What\'s the next faithful step for tomorrow?',
              style: TextStyle(color: MindColors.textSub)),
            const SizedBox(height:16),
            
            // Completed blocks
            const Text('Completed Today:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height:8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableBlocks.map((block) {
                final isCompleted = _completedBlocks.contains(block);
                return FilterChip(
                  label: Text(block),
                  selected: isCompleted,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _completedBlocks.add(block);
                      } else {
                        _completedBlocks.remove(block);
                      }
                    });
                  },
                  selectedColor: MindColors.lime.withOpacity(0.3),
                  checkmarkColor: MindColors.lime,
                );
              }).toList(),
            ),
            
            const SizedBox(height:16),
            
            // Reflection
            const Text('Quick Reflection:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height:8),
            TextField(
              controller: _reflectionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'How did today go? What\'s one thing you\'re grateful for?',
                border: OutlineInputBorder(),
              ),
            ),
            
            const SizedBox(height:16),
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save review data
                  widget.onSave();
                  Navigator.pop(context);
                }, 
                child: const Text('Save & Close', style: TextStyle(fontWeight: FontWeight.w700))
              )
            ),
          ]),
        ),
      ),
    );
  }
}
