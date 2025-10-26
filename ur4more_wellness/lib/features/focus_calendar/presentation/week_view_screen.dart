import 'package:flutter/material.dart';
import '../../../design/mind_tokens.dart';

class WeekViewScreen extends StatelessWidget {
  const WeekViewScreen({super.key});
  @override Widget build(BuildContext context){
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Week Planner')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Anchors & Templates', style: TextStyle(fontSize:16, fontWeight: FontWeight.w700)),
                const SizedBox(height:8),
                ElevatedButton(onPressed: ()=>ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('TODO: add Monday Deep Focus anchor'))
                ), child: const Text('Add Monday Deep Focus')),
                const SizedBox(height:12),
                ElevatedButton(onPressed: ()=>Navigator.pop(context), child: const Text('Back to Today')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}