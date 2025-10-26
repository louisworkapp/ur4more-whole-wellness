import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../../theme/tokens.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/discipleship_background.dart';
import '../../services/notification_service.dart';

class AlarmClockScreen extends StatefulWidget {
  const AlarmClockScreen({super.key});

  @override
  State<AlarmClockScreen> createState() => _AlarmClockScreenState();
}

class _AlarmClockScreenState extends State<AlarmClockScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  Timer? _timer;
  DateTime _currentTime = DateTime.now();
  TimeOfDay _morningAlarmTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _pmCheckinTime = const TimeOfDay(hour: 20, minute: 0);
  bool _morningAlarmEnabled = true;
  bool _pmCheckinAlarmEnabled = true;
  bool _isAlarmRinging = false;
  String _timezone = 'Local';

  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.linear,
    ));

    // Start animations
    _fadeController.forward();
    _pulseController.repeat(reverse: true);
    _sparkleController.repeat();

    // Initialize notifications
    _notificationService.initialize();
    
    // Start timer for clock updates
    _startTimer();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _sparkleController.dispose();
    _timer?.cancel();
    super.dispose();
  }


  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _currentTime = DateTime.now();
      });
      
      // Check if alarm should go off
      _checkAlarm();
    });
  }

  void _checkAlarm() {
    if (_isAlarmRinging) return;
    
    final now = DateTime.now();
    
    // Check morning alarm
    if (_morningAlarmEnabled) {
      final morningAlarmDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _morningAlarmTime.hour,
        _morningAlarmTime.minute,
      );
      
      if (now.isAfter(morningAlarmDateTime) && 
          now.difference(morningAlarmDateTime).inMinutes < 1) {
        _triggerMorningAlarm();
        return;
      }
    }
    
    // Check PM check-in alarm
    if (_pmCheckinAlarmEnabled) {
      final pmAlarmDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        _pmCheckinTime.hour,
        _pmCheckinTime.minute,
      );
      
      if (now.isAfter(pmAlarmDateTime) && 
          now.difference(pmAlarmDateTime).inMinutes < 1) {
        _triggerPMCheckinAlarm();
        return;
      }
    }
  }

  void _triggerMorningAlarm() {
    setState(() {
      _isAlarmRinging = true;
    });
    
    // Show morning alarm dialog
    _showMorningAlarmDialog();
    
    // Schedule notification
    _scheduleMorningAlarmNotification();
  }

  void _triggerPMCheckinAlarm() {
    setState(() {
      _isAlarmRinging = true;
    });
    
    // Show PM check-in alarm dialog
    _showPMCheckinAlarmDialog();
    
    // Schedule notification
    _schedulePMCheckinAlarmNotification();
  }

  void _showMorningAlarmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: T.gold, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.wb_sunny, color: T.gold, size: 28),
            const SizedBox(width: 12),
            Text(
              'Good Morning!',
              style: TextStyle(
                color: T.gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Time to start your morning routine',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Begin with prayer and set your daily intentions',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _dismissAlarm();
            },
            child: Text(
              'Snooze (5 min)',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _dismissAlarm();
              _startMorningRoutine();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: T.gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start Morning Routine'),
          ),
        ],
      ),
    );
  }

  void _showPMCheckinAlarmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: T.gold, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.nightlight_round, color: T.gold, size: 28),
            const SizedBox(width: 12),
            Text(
              'Evening Check-in',
              style: TextStyle(
                color: T.gold,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Time for your evening wellness check-in',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Reflect on your day and track your wellness',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _dismissAlarm();
            },
            child: Text(
              'Snooze (10 min)',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _dismissAlarm();
              _startPMCheckin();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: T.gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Start PM Check-in'),
          ),
        ],
      ),
    );
  }

  void _dismissAlarm() {
    setState(() {
      _isAlarmRinging = false;
    });
  }

  void _startMorningRoutine() {
    // Navigate to morning check-in
    Navigator.of(context).pushNamed('/morning-checkin');
  }

  void _startPMCheckin() {
    // Navigate to PM check-in
    Navigator.of(context).pushNamed('/pm-checkin');
  }

  Future<void> _scheduleMorningAlarmNotification() async {
    await _notificationService.scheduleMorningAlarm(
      hour: _morningAlarmTime.hour,
      minute: _morningAlarmTime.minute,
      customMessage: 'Time to start your morning routine',
    );
  }

  Future<void> _schedulePMCheckinAlarmNotification() async {
    await _notificationService.scheduleReminder(
      title: 'Evening Check-in',
      body: 'Time for your evening wellness check-in',
      scheduledTime: DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        _pmCheckinTime.hour,
        _pmCheckinTime.minute,
      ),
      payload: 'pm_checkin',
    );
  }

  Future<void> _selectMorningAlarmTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _morningAlarmTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: T.gold,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _morningAlarmTime) {
      setState(() {
        _morningAlarmTime = picked;
      });
      
      // Update the scheduled alarm
      if (_morningAlarmEnabled) {
        _notificationService.cancelMorningAlarm();
        _scheduleMorningAlarmNotification();
      }
    }
  }

  Future<void> _selectPMCheckinTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _pmCheckinTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: T.gold,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _pmCheckinTime) {
      setState(() {
        _pmCheckinTime = picked;
      });
      
      // Update the scheduled alarm
      if (_pmCheckinAlarmEnabled) {
        _schedulePMCheckinAlarmNotification();
      }
    }
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  String _formatDate(DateTime time) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    
    return '${days[time.weekday - 1]}, ${months[time.month - 1]} ${time.day}';
  }

  String _getTimezoneInfo() {
    final now = DateTime.now();
    final timezoneOffset = now.timeZoneOffset;
    final hours = timezoneOffset.inHours;
    final minutes = (timezoneOffset.inMinutes % 60).abs();
    
    String sign = hours >= 0 ? '+' : '-';
    String formattedOffset = '${sign}${hours.abs().toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    
    return 'UTC$formattedOffset';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Custom background gradient
          const DiscipleshipBackground(),
          
          // Content overlay
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top section with clock display
                  SizedBox(
                    height: 120,
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Main clock display
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: T.gold.withOpacity(0.5),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: T.gold.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _formatTime(_currentTime),
                                        style: theme.textTheme.headlineLarge?.copyWith(
                                          color: T.gold,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _formatDate(_currentTime),
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _getTimezoneInfo(),
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: T.gold,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Test button for morning check-in
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        color: T.gold,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => Navigator.of(context).pushNamed('/morning-checkin'),
                          child: const Center(
                            child: Text(
                              'TEST: Go to Morning Check-in',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Alarm settings section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        // Morning Alarm card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: T.gold.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _morningAlarmEnabled ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                                    color: _morningAlarmEnabled ? T.gold : Colors.white.withOpacity(0.5),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Morning Alarm',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: _morningAlarmEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _morningAlarmEnabled = value;
                                      });
                                      
                                      // Schedule or cancel alarm based on toggle
                                      if (value) {
                                        _scheduleMorningAlarmNotification();
                                      } else {
                                        _notificationService.cancelMorningAlarm();
                                      }
                                    },
                                    activeColor: T.gold,
                                    activeTrackColor: T.gold.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              
                              if (_morningAlarmEnabled) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Set for ${_morningAlarmTime.format(context)}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: T.gold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _selectMorningAlarmTime,
                                      icon: const CustomIconWidget(
                                        iconName: 'edit',
                                        color: T.gold,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // PM Check-in Alarm card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: T.gold.withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    _pmCheckinAlarmEnabled ? Icons.nightlight_round : Icons.nightlight_outlined,
                                    color: _pmCheckinAlarmEnabled ? T.gold : Colors.white.withOpacity(0.5),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'PM Check-in Alarm',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: _pmCheckinAlarmEnabled,
                                    onChanged: (value) {
                                      setState(() {
                                        _pmCheckinAlarmEnabled = value;
                                      });
                                      
                                      // Schedule or cancel alarm based on toggle
                                      if (value) {
                                        _schedulePMCheckinAlarmNotification();
                                      }
                                    },
                                    activeColor: T.gold,
                                    activeTrackColor: T.gold.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              
                              if (_pmCheckinAlarmEnabled) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Set for ${_pmCheckinTime.format(context)}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: T.gold,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: _selectPMCheckinTime,
                                      icon: const CustomIconWidget(
                                        iconName: 'edit',
                                        color: T.gold,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Quick actions
                        Row(
                          children: [
                            Expanded(
                              child: _buildActionButton(
                                'Morning Check-in',
                                Icons.wb_sunny,
                                () => Navigator.of(context).pushNamed('/morning-checkin'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                'PM Check-in',
                                Icons.nightlight_round,
                                () => Navigator.of(context).pushNamed('/pm-checkin'),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Current check-in status
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: T.gold.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Today\'s Progress',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildProgressItem('Morning', Icons.wb_sunny, false),
                                  _buildProgressItem('PM Check-in', Icons.nightlight_round, false),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, VoidCallback onTap) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: T.gold,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: T.gold.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(String title, IconData icon, bool completed) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: completed ? T.gold : Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check : icon,
            color: completed ? Colors.white : Colors.white.withOpacity(0.7),
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: completed ? T.gold : Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
