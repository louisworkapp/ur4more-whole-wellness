import 'package:flutter/material.dart';
import '../../../design/mind_tokens.dart';
import '../domain/plan_models.dart';
import '../data/plan_repository.dart';
import 'morning_checkin_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});
  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final repo = PlanRepository();
  List<PlanBlock> today = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await repo.loadForDay(DateTime.now());
    setState(()=>today = list..sort((a,b)=>a.start.compareTo(b.start)));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Planner')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final b in today) _tile(b),
                if (today.isEmpty) const Text('No blocks yet. Create your morning plan.'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const MorningCheckInScreen()));
                      if (ok == true) _load();
                    },
                    child: const Text('Create Morning Plan', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tile(PlanBlock b) => ListTile(
    leading: const Icon(Icons.schedule, color: MindColors.brandBlue),
    title: Text(b.title),
    subtitle: Text('${_hhmm(b.start)} • ${b.duration.inMinutes} min'),
  );

  String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';
}
