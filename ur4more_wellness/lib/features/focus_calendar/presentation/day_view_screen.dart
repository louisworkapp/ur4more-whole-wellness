import 'package:flutter/material.dart';
import '../../../design/mind_tokens.dart';
import '../../shared/faith_mode.dart';
import '../../shared/inspiration_service.dart';
import '../../shared/nudge_service.dart';
import '../domain/block_models.dart';
import '../data/calendar_repository.dart';
import 'widgets/block_tile.dart';
import '../../shared/widgets/inspiration_banner.dart';

class DayViewScreen extends StatefulWidget {
  final FaithTier faithTier; final bool lightConsentGiven;
  const DayViewScreen({super.key, required this.faithTier, this.lightConsentGiven=false});

  @override State<DayViewScreen> createState()=>_DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen>{
  final repo = CalendarRepository();
  final insp = InspirationService();
  List<PlanBlock> today = [];
  Map<String,String>? banner; bool loaded=false;

  @override void initState(){ super.initState(); _init(); }
  Future<void> _init() async {
    await insp.load();
    await _load();
    setState(()=>loaded=true);
  }

  Future<void> _load() async {
    today = await repo.loadForDay(DateTime.now());
    banner = widget.faithTier.isActivated ? insp.scripture() : insp.secular();
    setState((){});
  }

  @override Widget build(BuildContext context){
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Today')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (NudgeService.isFreshStart(DateTime.now()))
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MindColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MindColors.outline),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Fresh Start', style: TextStyle(fontSize:18, fontWeight: FontWeight.w700)),
                      const SizedBox(height:6),
                      const Text('New week or month? Let\'s reset and schedule what matters first.',
                        style: TextStyle(color: MindColors.textSub)),
                      const SizedBox(height:12),
                      SizedBox(width: double.infinity, child:
                        ElevatedButton(onPressed: ()=>Navigator.pushNamed(context, '/planner/week'),
                          child: const Text('Plan this week'))),
                    ]),
                  ),
                const SizedBox(height:16),
                if (banner!=null)
                  InspirationBanner(title: banner!['ref'] ?? banner!['author'] ?? 'Today', body: banner!['text'] ?? ''),
                const SizedBox(height:16),
                for (final b in today) BlockTile(b: b),
                if (today.isEmpty && loaded)
                  const Text('No blocks for today. Create your morning plan.', style: TextStyle(color: MindColors.textSub)),
                const SizedBox(height:16),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(onPressed: ()=>Navigator.pushNamed(context, '/checkin'),
                    child: const Text('Create Morning Plan'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}