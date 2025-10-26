import 'package:flutter/material.dart';
import '../../../design/mind_tokens.dart';
import '../domain/block_models.dart';
import '../domain/faith_mode.dart';

class BlockEditorSheet extends StatefulWidget {
  final PlanBlock initial;
  final FaithTier faithTier;
  final bool lightConsentGiven;
  const BlockEditorSheet({super.key, required this.initial, required this.faithTier, this.lightConsentGiven=false});
  @override State<BlockEditorSheet> createState()=>_BlockEditorSheetState();
}

class _BlockEditorSheetState extends State<BlockEditorSheet>{
  late TextEditingController title, notes, cue, location, first;
  late bool faithEnabled;
  String? verseRef; String? prayerHint;

  @override void initState(){
    super.initState();
    title = TextEditingController(text: widget.initial.title);
    notes = TextEditingController(text: widget.initial.notes ?? '');
    cue = TextEditingController(text: widget.initial.impl.cue);
    location = TextEditingController(text: widget.initial.impl.location);
    first = TextEditingController(text: widget.initial.impl.firstStep);
    faithEnabled = widget.initial.faith.enabled;
    verseRef = widget.initial.faith.verseRef;
    prayerHint = widget.initial.faith.prayerHint ?? '30-second prayer before you begin';
  }

  bool get allowFaith {
    if (widget.faithTier.isOff) return false;
    if (widget.faithTier == FaithTier.light) return widget.lightConsentGiven;
    return true;
  }

  @override Widget build(BuildContext context){
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Edit Block', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
            const SizedBox(height:12),
            TextField(controller: title, decoration: const InputDecoration(labelText:'Title')),
            const SizedBox(height:8),
            TextField(controller: notes, decoration: const InputDecoration(labelText:'Notes (optional)')),
            const SizedBox(height:12),
            const Text('If–Then Plan', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height:6),
            TextField(controller: cue, decoration: const InputDecoration(labelText:'Cue (If …)')),
            const SizedBox(height:8),
            TextField(controller: location, decoration: const InputDecoration(labelText:'Location')),
            const SizedBox(height:8),
            TextField(controller: first, decoration: const InputDecoration(labelText:'First Action (then …)')),
            if (allowFaith) ...[
              const SizedBox(height:12),
              const Text('Faith Overlay', style: TextStyle(fontWeight: FontWeight.w700)),
              SwitchListTile(
                value: faithEnabled, onChanged: (v)=>setState(()=>faithEnabled=v),
                title: const Text('Enable verse/prayer for this block'),
              ),
              if (faithEnabled) ...[
                TextField(controller: TextEditingController(text: verseRef??''), onChanged:(v)=>verseRef=v, decoration: const InputDecoration(labelText:'Verse Ref (e.g., Matt 4:19)')),
                const SizedBox(height:8),
                TextField(controller: TextEditingController(text: prayerHint??''), onChanged:(v)=>prayerHint=v, decoration: const InputDecoration(labelText:'Prayer hint')),
              ]
            ],
            const SizedBox(height:16),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: (){
                final updated = widget.initial.copyWith(
                  title: title.text.trim().isEmpty ? widget.initial.title : title.text.trim(),
                  notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
                  impl: ImplementationIntent(cue: cue.text.trim(), location: location.text.trim(), firstStep: first.text.trim()),
                  faith: allowFaith ? FaithOverlay(verseRef: verseRef, prayerHint: prayerHint, enabled: faithEnabled) : const FaithOverlay(),
                );
                Navigator.pop(context, updated);
              },
              child: const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
            ))
          ]),
        ),
      ),
    );
  }
}
