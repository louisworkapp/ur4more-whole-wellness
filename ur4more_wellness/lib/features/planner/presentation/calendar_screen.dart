import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design/mind_tokens.dart';
import '../domain/plan_models.dart';
import '../data/plan_repository.dart';

class CalendarScreen extends StatefulWidget {
  final List<PlanBlock> suggestions;
  final TimeOfDay morningAlarmTime;
  final TimeOfDay pmCheckinTime;
  final bool morningAlarmEnabled;
  final bool pmCheckinAlarmEnabled;

  const CalendarScreen({
    super.key,
    required this.suggestions,
    required this.morningAlarmTime,
    required this.pmCheckinTime,
    required this.morningAlarmEnabled,
    required this.pmCheckinAlarmEnabled,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final PlanRepository _repository = PlanRepository();
  List<PlanBlock> _plan = [];

  @override
  void initState() {
    super.initState();
    _plan = List.from(widget.suggestions);
  }

  String _formatTime12Hour(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Color _getCategoryColor(CoachCategory category) {
    switch (category) {
      case CoachCategory.mind:
        return const Color(0xFF4CAF50); // Green
      case CoachCategory.body:
        return MindColors.brandBlue; // Blue
      case CoachCategory.spirit:
        return const Color(0xFFFFD700); // Gold
      case CoachCategory.work:
        return MindColors.textSub;
      case CoachCategory.errand:
        return MindColors.textSub;
    }
  }

  IconData _getCategoryIcon(CoachCategory category) {
    switch (category) {
      case CoachCategory.mind:
        return Icons.psychology;
      case CoachCategory.body:
        return Icons.fitness_center;
      case CoachCategory.spirit:
        return Icons.self_improvement;
      case CoachCategory.work:
        return Icons.work;
      case CoachCategory.errand:
        return Icons.shopping_cart;
    }
  }

  Widget _planTile(PlanBlock b) {
    final color = _getCategoryColor(b.category);
    final icon = _getCategoryIcon(b.category);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: Container(
          width: 10, 
          height: 36,
          decoration: BoxDecoration(
            color: color, 
            borderRadius: BorderRadius.circular(4)
          ),
        ),
        title: Text(
          b.title, 
          maxLines: 1, 
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_formatTime12Hour(b.start)} • ${b.duration.inMinutes} min',
          style: const TextStyle(color: MindColors.textSub),
        ),
        trailing: Icon(icon, color: color, size: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Today\'s Plan'),
          backgroundColor: MindColors.bg,
          surfaceTintColor: Colors.transparent,
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // Add custom block functionality
                HapticFeedback.lightImpact();
              },
            ),
          ],
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: MindColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: MindColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Daily Schedule',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: MindColors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_plan.length} activities planned for today',
                          style: const TextStyle(
                            color: MindColors.textSub,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_plan.isEmpty) 
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: MindColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: MindColors.outline),
                      ),
                      child: const Center(
                        child: Text(
                          'No activities planned yet.\nGo back to generate suggestions.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: MindColors.textSub),
                        ),
                      ),
                    ),
                  
                  for (final b in _plan) _planTile(b),
                  
                  if (_plan.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/planner/commit', arguments: {
                            'plan': _plan,
                            'morningAlarmTime': widget.morningAlarmTime,
                            'pmCheckinTime': widget.pmCheckinTime,
                            'morningAlarmEnabled': widget.morningAlarmEnabled,
                            'pmCheckinAlarmEnabled': widget.pmCheckinAlarmEnabled,
                          });
                        },
                        child: const Text('Commit & Save Plan', style: TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
