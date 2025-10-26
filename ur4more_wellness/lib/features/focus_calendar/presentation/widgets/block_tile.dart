import 'package:flutter/material.dart';
import '../../../../design/mind_tokens.dart';
import '../../domain/block_models.dart';

class BlockTile extends StatelessWidget {
  final PlanBlock b; final VoidCallback? onEdit; final VoidCallback? onDelete;
  const BlockTile({super.key, required this.b, this.onEdit, this.onDelete});

  Color _colorFor(CoachCategory c){
    switch(c){
      case CoachCategory.mind: return MindColors.brandBlue;
      case CoachCategory.body: return MindColors.blue200;
      case CoachCategory.spirit: return MindColors.lime;
      default: return MindColors.textSub;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colorFor(b.category);
    String hhmm(DateTime t)=>'${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal:8),
      leading: Container(width:10, height:38, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(4))),
      title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${hhmm(b.start)} • ${b.duration.inMinutes} min'
        '${b.impl.cue.isNotEmpty ? '  —  ${b.impl.cue}' : ''}',
        style: const TextStyle(color: MindColors.textSub)),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        if (onEdit!=null) IconButton(icon: const Icon(Icons.edit, size:18), onPressed:onEdit),
        if (onDelete!=null) IconButton(icon: const Icon(Icons.delete, size:18), onPressed:onDelete),
      ]),
    );
  }
}