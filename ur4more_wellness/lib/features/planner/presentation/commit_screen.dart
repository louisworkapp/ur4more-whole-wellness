import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design/mind_tokens.dart';
import '../domain/plan_models.dart';
import '../data/plan_repository.dart';
import '../../../services/notification_service.dart';

class CommitScreen extends StatefulWidget {
  final List<PlanBlock> plan;
  final TimeOfDay morningAlarmTime;
  final TimeOfDay pmCheckinTime;
  final bool morningAlarmEnabled;
  final bool pmCheckinAlarmEnabled;

  const CommitScreen({
    super.key,
    required this.plan,
    required this.morningAlarmTime,
    required this.pmCheckinTime,
    required this.morningAlarmEnabled,
    required this.pmCheckinAlarmEnabled,
  });

  @override
  State<CommitScreen> createState() => _CommitScreenState();
}

class _CommitScreenState extends State<CommitScreen> {
  final PlanRepository _repository = PlanRepository();
  final NotificationService _notificationService = NotificationService();
  bool _isSaving = false;

  String _formatTime12Hour(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    
    try {
      await _repository.saveAll(widget.plan);
      
      // Schedule notifications if alarms are enabled
      if (widget.morningAlarmEnabled) {
        await _scheduleMorningAlarm();
      }
      if (widget.pmCheckinAlarmEnabled) {
        await _schedulePMCheckinReminder();
      }
      
      if (!mounted) return;
      
      HapticFeedback.lightImpact();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Plan saved successfully! You\'ve got this.'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        backgroundColor: MindColors.lime,
      ));
      
      // Navigate back to home or daily calendar
      Navigator.pushReplacementNamed(context, '/daily-calendar');
      
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error saving plan: $e'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _scheduleMorningAlarm() async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.morningAlarmTime.hour,
      widget.morningAlarmTime.minute,
    );
    
    // If the time has already passed today, schedule for tomorrow
    final alarmTime = scheduledTime.isBefore(now) 
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;
    
    await _notificationService.scheduleMorningAlarm(
      hour: alarmTime.hour,
      minute: alarmTime.minute,
      customMessage: 'Good morning! Time for your daily check-in and planning.',
    );
  }

  Future<void> _schedulePMCheckinReminder() async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      widget.pmCheckinTime.hour,
      widget.pmCheckinTime.minute,
    );
    
    // If the time has already passed today, schedule for tomorrow
    final reminderTime = scheduledTime.isBefore(now) 
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;
    
    await _notificationService.scheduleReminder(
      title: 'Evening Review',
      body: 'Evening review time! How did your day go?',
      scheduledTime: reminderTime,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Commit & Save'),
          backgroundColor: MindColors.bg,
          surfaceTintColor: Colors.transparent,
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
                          'Ready to Commit?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: MindColors.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You\'re set for the day. We\'ll nudge you before each block.',
                          style: const TextStyle(
                            color: MindColors.textSub,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Plan summary
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
                          'Your Plan Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: MindColors.text,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.plan.length} activities planned',
                          style: const TextStyle(
                            color: MindColors.textSub,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total duration: ${_getTotalDuration()}',
                          style: const TextStyle(
                            color: MindColors.textSub,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Alarm settings summary
                  if (widget.morningAlarmEnabled || widget.pmCheckinAlarmEnabled) ...[
                    const SizedBox(height: 16),
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
                            'Alarm Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: MindColors.text,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (widget.morningAlarmEnabled)
                            Row(children: [
                              const Icon(Icons.alarm, color: MindColors.lime, size: 20),
                              const SizedBox(width: 12),
                              Text('Morning: ${_formatTime12Hour(widget.morningAlarmTime)}'),
                            ]),
                          if (widget.morningAlarmEnabled && widget.pmCheckinAlarmEnabled) const SizedBox(height: 8),
                          if (widget.pmCheckinAlarmEnabled)
                            Row(children: [
                              const Icon(Icons.schedule, color: MindColors.brandBlue, size: 20),
                              const SizedBox(width: 12),
                              Text('Evening: ${_formatTime12Hour(widget.pmCheckinTime)}'),
                            ]),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving 
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Saving...', style: TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          )
                        : const Text('Save & Start My Day', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getTotalDuration() {
    final totalMinutes = widget.plan.fold<int>(0, (sum, block) => sum + block.duration.inMinutes);
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    
    if (hours == 0) {
      return '${minutes}m';
    } else if (minutes == 0) {
      return '${hours}h';
    } else {
      return '${hours}h ${minutes}m';
    }
  }
}
