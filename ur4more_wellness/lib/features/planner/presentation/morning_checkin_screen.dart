import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../design/mind_tokens.dart';
import '../../../services/notification_service.dart';
import '../../../services/faith_service.dart';
import '../../../core/settings/settings_model.dart';
import '../domain/plan_models.dart';
import '../data/plan_repository.dart';
import '../data/suggestion_service.dart';
import 'widgets/badge_chip.dart';
import 'widgets/slider_row.dart';

class MorningCheckInScreen extends StatefulWidget {
  const MorningCheckInScreen({super.key});
  @override
  State<MorningCheckInScreen> createState() => _MorningCheckInScreenState();
}

class _MorningCheckInScreenState extends State<MorningCheckInScreen> {
  int mood = 6, energy = 5, urge = 3, faith = 5;
  bool focusMind = true, focusBody = true, focusSpirit = false;
  bool faithActivated = false;       // Will be loaded from FaithService
  bool showFaithOverlay = false;     // Will be determined by faith mode
  final repo = PlanRepository();
  final sugg = SuggestionService();
  final notificationService = NotificationService();
  final List<PlanBlock> plan = [];
  
          // Collapsible card states
          bool pulseCardExpanded = true;
          bool focusCardExpanded = false;
  
  // Alarm settings
  TimeOfDay morningAlarmTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay pmCheckinTime = const TimeOfDay(hour: 20, minute: 0);
  bool morningAlarmEnabled = true;
  bool pmCheckinAlarmEnabled = true;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadFaithSettings();
  }

  Future<void> _initializeNotifications() async {
    await notificationService.initialize();
  }

  Future<void> _loadFaithSettings() async {
    final faithMode = await FaithService.getFaithMode();
    setState(() {
      faithActivated = faithMode != FaithTier.off;
      showFaithOverlay = faithMode == FaithTier.disciple || faithMode == FaithTier.kingdom;
      
      // Auto-select Spirit if faith mode is already enabled
      if (faithActivated) {
        focusSpirit = true;
      }
    });
  }

  Future<void> _toggleFaithTier(bool enabled) async {
    final newMode = enabled ? FaithTier.light : FaithTier.off;
    await FaithService.setFaithMode(newMode);
    
    setState(() {
      faithActivated = enabled;
      showFaithOverlay = enabled; // Light mode shows overlays by default
      
      // Auto-select Spirit when faith mode is enabled
      if (enabled) {
        focusSpirit = true;
      }
    });
    
    HapticFeedback.lightImpact();
    
    if (enabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Faith mode enabled! Spirit focus auto-selected.'),
        backgroundColor: MindColors.lime,
        duration: Duration(seconds: 2),
      ));
    }
  }

  void _generateSuggestions() {
    final now = DateTime.now().add(const Duration(minutes: 5));
    final items = sugg.suggest(
      startAt: now,
      focusMind: focusMind,
      focusBody: focusBody,
      focusSpirit: focusSpirit,
      faithActivated: faithActivated,
      showFaithOverlay: showFaithOverlay,
    );
    setState((){ plan.addAll(items); });
  }

  Future<void> _save() async {
    await repo.saveAll(plan);
    
    // Schedule notifications if alarms are enabled
    if (morningAlarmEnabled) {
      await _scheduleMorningAlarm();
    }
    if (pmCheckinAlarmEnabled) {
      await _schedulePMCheckinReminder();
    }
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Plan saved. You\'ve got this.'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
      backgroundColor: MindColors.lime,
    ));
    
            // Navigate to daily calendar
            Navigator.pushReplacementNamed(context, '/daily-calendar');
  }

  Future<void> _scheduleMorningAlarm() async {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      morningAlarmTime.hour,
      morningAlarmTime.minute,
    );
    
    // If the time has already passed today, schedule for tomorrow
    final alarmTime = scheduledTime.isBefore(now) 
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;
    
    await notificationService.scheduleMorningAlarm(
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
      pmCheckinTime.hour,
      pmCheckinTime.minute,
    );
    
    // If the time has already passed today, schedule for tomorrow
    final reminderTime = scheduledTime.isBefore(now) 
        ? scheduledTime.add(const Duration(days: 1))
        : scheduledTime;
    
    await notificationService.scheduleReminder(
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
          title: const Text('Morning Check-In'),
          backgroundColor: MindColors.bg,
          surfaceTintColor: Colors.transparent,
        ),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                        children: [
                          _buildCollapsibleCard(
                            title: 'Alarm Settings',
                            isExpanded: pulseCardExpanded,
                            onToggle: () => setState(() => pulseCardExpanded = !pulseCardExpanded),
                            child: _cardAlarmContent(),
                          ),
                          const SizedBox(height: 16),
                          _buildCollapsibleCard(
                            title: 'Your Pulse & Focus',
                            isExpanded: focusCardExpanded,
                            onToggle: () => setState(() => focusCardExpanded = !focusCardExpanded),
                            child: _cardPulseAndFocusContent(),
                          ),
                        ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCollapsibleCard({
    required String title,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: MindColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MindColors.outline),
        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0,4))],
      ),
      child: Column(
        children: [
          // Header with title and expand/collapse button
          InkWell(
            onTap: onToggle,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: MindColors.text,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: MindColors.textSub,
                  ),
                ],
              ),
            ),
          ),
          // Content (only shown when expanded)
          if (isExpanded) ...[
            const Divider(color: MindColors.outline, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ],
      ),
    );
  }

  Widget _wrapCard(String title, Widget child, {List<Widget>? chips, Widget? footer}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: MindColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MindColors.outline),
          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0,4))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          if (chips!=null) Wrap(spacing: 8, runSpacing: 8, children: chips),
          if (chips!=null) const SizedBox(height: 12),
          child,
          if (footer!=null) ...[const SizedBox(height: 16), footer],
        ]),
      ),
    );
  }

  Widget _nextBtn(String label, VoidCallback onTap) => SizedBox(
    width: double.infinity,
    child: ElevatedButton(onPressed: onTap, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
  );

  // Content methods for collapsible cards
  Widget _cardAlarmContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Morning Alarm
        Container(
          decoration: BoxDecoration(
            color: MindColors.surfaceHover,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MindColors.outline),
          ),
          child: SwitchListTile(
            title: const Text('Morning Check-in Alarm', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(_formatTime12Hour(morningAlarmTime)),
            value: morningAlarmEnabled,
            onChanged: (value) => setState(() => morningAlarmEnabled = value),
            secondary: const Icon(Icons.alarm, color: MindColors.lime),
          ),
        ),
        
        if (morningAlarmEnabled) ...[
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Set Morning Time'),
            trailing: TextButton(
              onPressed: _selectMorningAlarmTime,
              child: Text(_formatTime12Hour(morningAlarmTime)),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // PM Check-in Alarm
        Container(
          decoration: BoxDecoration(
            color: MindColors.surfaceHover,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MindColors.outline),
          ),
          child: SwitchListTile(
            title: const Text('Evening Review Reminder', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(_formatTime12Hour(pmCheckinTime)),
            value: pmCheckinAlarmEnabled,
            onChanged: (value) => setState(() => pmCheckinAlarmEnabled = value),
            secondary: const Icon(Icons.schedule, color: MindColors.brandBlue),
          ),
        ),
        
        if (pmCheckinAlarmEnabled) ...[
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Set Evening Time'),
            trailing: TextButton(
              onPressed: _selectPMCheckinTime,
              child: Text(_formatTime12Hour(pmCheckinTime)),
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => focusCardExpanded = true),
            child: const Text('Next: Your Pulse & Focus', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _cardPulseAndFocusContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pulse sliders
        Text(
          'Your Pulse for Today',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MindColors.text,
          ),
        ),
        const SizedBox(height: 12),
        SliderRow(label: 'Mood', value: mood, onChanged: (v)=>setState(()=>mood=v)),
        SliderRow(label: 'Energy', value: energy, onChanged: (v)=>setState(()=>energy=v)),
        SliderRow(label: 'Urge/Stress', value: urge, onChanged: (v)=>setState(()=>urge=v)),
        SliderRow(label: 'Faith', value: faith, onChanged: (v)=>setState(()=>faith=v)),
        
        const SizedBox(height: 24),
        const Divider(color: MindColors.outline),
        const SizedBox(height: 16),
        
        // Focus selection
        Text(
          'Choose Your Focus',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: MindColors.text,
          ),
        ),
        const SizedBox(height: 12),
        _focusTile('Mind', focusMind, (v)=>setState(()=>focusMind=v)),
        const SizedBox(height: 8),
        _focusTile('Body', focusBody, (v)=>setState(()=>focusBody=v)),
        const SizedBox(height: 8),
        _focusTile('Spirit', focusSpirit, (v)=>setState(()=>focusSpirit=v)),
        
        const SizedBox(height: 16),
        const Divider(color: MindColors.outline),
        const SizedBox(height: 8),
        
        // Faith Mode Toggle
        Container(
          decoration: BoxDecoration(
            color: MindColors.surfaceHover,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: MindColors.outline),
          ),
          child: SwitchListTile(
            title: const Text('Faith Mode', style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(faithActivated ? 'Spiritual content enabled' : 'Secular mode only'),
            value: faithActivated,
            onChanged: _toggleFaithTier,
            secondary: Icon(
              faithActivated ? Icons.auto_awesome : Icons.visibility_off,
              color: faithActivated ? MindColors.lime : MindColors.textSub,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              _generateSuggestions();
              Navigator.pushNamed(context, '/planner/suggestions', arguments: {
                'suggestions': plan,
                'focusMind': focusMind,
                'focusBody': focusBody,
                'focusSpirit': focusSpirit,
                'faithActivated': faithActivated,
                'showFaithOverlay': showFaithOverlay,
                'morningAlarmTime': morningAlarmTime,
                'pmCheckinTime': pmCheckinTime,
                'morningAlarmEnabled': morningAlarmEnabled,
                'pmCheckinAlarmEnabled': pmCheckinAlarmEnabled,
              });
            },
            child: const Text('View Coach Suggestions', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }


  // Card 1: Pulse
  Widget _cardPulse({required VoidCallback onNext}) {
    return _wrapCard('Your pulse for today', Column(children: [
      SliderRow(label: 'Mood', value: mood, onChanged: (v)=>setState(()=>mood=v)),
      SliderRow(label: 'Energy', value: energy, onChanged: (v)=>setState(()=>energy=v)),
      SliderRow(label: 'Urge/Stress', value: urge, onChanged: (v)=>setState(()=>urge=v)),
      SliderRow(label: 'Faith', value: faith, onChanged: (v)=>setState(()=>faith=v)),
    ]),
      chips: const [ BadgeChip(label: 'Takes 10s', color: MindColors.blue200) ],
      footer: _nextBtn('Next', onNext),
    );
  }

  // Card 2: Alarm Settings
  Widget _cardAlarmSettings({required VoidCallback onNext}) {
    return _wrapCard('Alarm & Reminder Settings', Column(children: [
      const SizedBox(height: 8),
      
      // Morning Alarm
      Container(
        decoration: BoxDecoration(
          color: MindColors.surfaceHover,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MindColors.outline),
        ),
        child: SwitchListTile(
          title: const Text('Morning Check-in Alarm', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(_formatTime12Hour(morningAlarmTime)),
          value: morningAlarmEnabled,
          onChanged: (value) => setState(() => morningAlarmEnabled = value),
          secondary: const Icon(Icons.alarm, color: MindColors.lime),
        ),
      ),
      
      if (morningAlarmEnabled) ...[
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Set Morning Time'),
          trailing: TextButton(
            onPressed: _selectMorningAlarmTime,
            child: Text(_formatTime12Hour(morningAlarmTime)),
          ),
        ),
      ],
      
      const SizedBox(height: 16),
      
      // PM Check-in Alarm
      Container(
        decoration: BoxDecoration(
          color: MindColors.surfaceHover,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MindColors.outline),
        ),
        child: SwitchListTile(
          title: const Text('Evening Review Reminder', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(_formatTime12Hour(pmCheckinTime)),
          value: pmCheckinAlarmEnabled,
          onChanged: (value) => setState(() => pmCheckinAlarmEnabled = value),
          secondary: const Icon(Icons.schedule, color: MindColors.brandBlue),
        ),
      ),
      
      if (pmCheckinAlarmEnabled) ...[
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Set Evening Time'),
          trailing: TextButton(
            onPressed: _selectPMCheckinTime,
            child: Text(_formatTime12Hour(pmCheckinTime)),
          ),
        ),
      ],
    ]),
      chips: const [ BadgeChip(label: 'Optional', color: MindColors.blue200) ],
      footer: _nextBtn('Continue', onNext),
    );
  }

  // Card 3: Focus (Mind/Body/Spirit)
  Widget _cardFocus({required VoidCallback onNext}) {
    return _wrapCard('Choose today\'s focus', Column(children: [
      const SizedBox(height: 4),
      _focusTile('Mind', focusMind, (v)=>setState(()=>focusMind=v)),
      const SizedBox(height: 8),
      _focusTile('Body', focusBody, (v)=>setState(()=>focusBody=v)),
      const SizedBox(height: 8),
      _focusTile('Spirit', focusSpirit, (v)=>setState(()=>focusSpirit=v)),
      
      const SizedBox(height: 16),
      const Divider(color: MindColors.outline),
      const SizedBox(height: 8),
      
      // Faith Mode Toggle
      Container(
        decoration: BoxDecoration(
          color: MindColors.surfaceHover,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: MindColors.outline),
        ),
        child: SwitchListTile(
          title: const Text('Faith Mode', style: TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Text(faithActivated ? 'Spiritual content enabled' : 'Secular mode only'),
          value: faithActivated,
          onChanged: _toggleFaithTier,
          secondary: Icon(
            faithActivated ? Icons.auto_awesome : Icons.visibility_off,
            color: faithActivated ? MindColors.lime : MindColors.textSub,
          ),
        ),
      ),
    ]),
      chips: [
        const BadgeChip(label: 'Blue = info', color: MindColors.brandBlue),
        const BadgeChip(label: 'Lime = action', color: MindColors.lime),
      ],
      footer: _nextBtn('Next', onNext),
    );
  }

  Widget _focusTile(String label, bool value, ValueChanged<bool> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: value ? MindColors.surfaceHover : MindColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value ? MindColors.brandBlue : MindColors.outline),
      ),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  // Card 3: Suggestions
  Widget _cardSuggestions({required VoidCallback onNext}) {
    return _wrapCard('Coach suggestions', Column(
      children: [
        if (plan.isEmpty) const Text('No suggestions yet. Go back and pick a focus.'),
        for (final b in plan) _planTile(b, removable: true),
      ],
    ),
      chips: const [ BadgeChip(label: 'Tap to remove', color: MindColors.blue200) ],
      footer: _nextBtn('Looks good', onNext),
    );
  }

  // Card 4: Calendar preview
  Widget _cardCalendar({required VoidCallback onNext}) {
    return _wrapCard('Today\'s plan', Column(
      children: [
        for (final b in plan) _planTile(b),
      ],
    ),
      chips: const [ BadgeChip(label: 'Drag to reorder (v2)', color: MindColors.blue200) ],
      footer: _nextBtn('Save plan', onNext),
    );
  }

  // Card 6: Commit
  Widget _cardCommit({required Future<void> Function() onSave}) {
    return _wrapCard('Commit & go', Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('You\'re set for the day. We\'ll nudge you before each block.'),
        const SizedBox(height: 16),
        
        // Alarm settings summary
        if (morningAlarmEnabled || pmCheckinAlarmEnabled) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MindColors.surfaceHover,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: MindColors.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Alarm Settings:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                if (morningAlarmEnabled)
                  Row(children: [
                    const Icon(Icons.alarm, color: MindColors.lime, size: 16),
                    const SizedBox(width: 8),
                            Text('Morning: ${_formatTime12Hour(morningAlarmTime)}'),
                  ]),
                if (morningAlarmEnabled && pmCheckinAlarmEnabled) const SizedBox(height: 4),
                if (pmCheckinAlarmEnabled)
                  Row(children: [
                    const Icon(Icons.schedule, color: MindColors.brandBlue, size: 16),
                    const SizedBox(width: 8),
                            Text('Evening: ${_formatTime12Hour(pmCheckinTime)}'),
                  ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        
        _nextBtn('Save & Exit', () async { await onSave(); }),
      ],
    ),
      chips: [
        BadgeChip(label: 'Streak: 0', color: MindColors.lime),
        if (morningAlarmEnabled || pmCheckinAlarmEnabled)
          const BadgeChip(label: 'Alarms set', color: MindColors.blue200),
      ],
    );
  }

  Widget _planTile(PlanBlock b, {bool removable=false}) {
    final color = switch (b.category) {
      CoachCategory.mind => const Color(0xFF4CAF50), // Green for Mind
      CoachCategory.body => MindColors.brandBlue, // Brand blue for Body
      CoachCategory.spirit => const Color(0xFFFFD700), // Gold for Spirit
      CoachCategory.work => MindColors.textSub,
      CoachCategory.errand => MindColors.textSub,
    };
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Container(
        width: 10, height: 36,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
      ),
      title: Text(b.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${_hhmm(b.start)} • ${b.duration.inMinutes} min',
        style: const TextStyle(color: MindColors.textSub)),
      trailing: removable ? IconButton(
        icon: const Icon(Icons.close, color: MindColors.textSub),
        onPressed: ()=>setState(()=>plan.removeWhere((x)=>x.id==b.id)),
      ) : null,
    );
  }

  String _hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2,'0')}:${t.minute.toString().padLeft(2,'0')}';

  String _formatTime12Hour(TimeOfDay time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour}:${time.minute.toString().padLeft(2, '0')} $period';
  }

  Future<void> _selectMorningAlarmTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: morningAlarmTime,
      builder: (context, child) {
        return Theme(
          data: buildMindTheme(Theme.of(context)),
          child: child!,
        );
      },
    );
    if (picked != null && picked != morningAlarmTime) {
      setState(() {
        morningAlarmTime = picked;
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _selectPMCheckinTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: pmCheckinTime,
      builder: (context, child) {
        return Theme(
          data: buildMindTheme(Theme.of(context)),
          child: child!,
        );
      },
    );
    if (picked != null && picked != pmCheckinTime) {
      setState(() {
        pmCheckinTime = picked;
      });
      HapticFeedback.lightImpact();
    }
  }
}
