import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/account_section_widget.dart';
import './widgets/app_info_section_widget.dart';
import './widgets/equipment_section_widget.dart';
import './widgets/faith_mode_section_widget.dart';
import './widgets/notification_section_widget.dart';
import './widgets/privacy_section_widget.dart';
import './widgets/profile_section_widget.dart';
import './widgets/theme_section_widget.dart';

class SettingsProfileScreen extends StatefulWidget {
  const SettingsProfileScreen({super.key});

  @override
  State<SettingsProfileScreen> createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends State<SettingsProfileScreen> {
  // Profile settings
  String _fullName = 'Sarah Johnson';
  String _timezone = 'Eastern Time (ET)';

  // Equipment settings
  bool _hasBodyweight = true;
  bool _hasResistanceBands = false;
  bool _hasPullupBar = true;

  // Faith mode setting
  FaithMode _faithMode = FaithMode.light;

  // Notification settings
  bool _notificationsEnabled = true;
  TimeOfDay _notificationStartTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _notificationEndTime = const TimeOfDay(hour: 21, minute: 0);

  // Theme setting
  AppThemeMode _themeMode = AppThemeMode.system;

  // Account status
  bool _isDataSynced = true;
  DateTime _lastSyncTime = DateTime.now().subtract(const Duration(minutes: 15));

  // Privacy settings
  bool _dataCollectionEnabled = true;
  bool _analyticsEnabled = false;
  bool _crashReportingEnabled = true;

  // App info
  final String _appVersion = '1.2.3';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Settings & Profile',
        variant: CustomAppBarVariant.centered,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: AppSpace.x2),

              // Profile Information Section
              ProfileSectionWidget(
                fullName: _fullName,
                timezone: _timezone,
                onNameChanged: _updateFullName,
                onTimezoneChanged: _updateTimezone,
              ),

              // Equipment Configuration Section
              EquipmentSectionWidget(
                hasBodyweight: _hasBodyweight,
                hasResistanceBands: _hasResistanceBands,
                hasPullupBar: _hasPullupBar,
                onBodyweightChanged: _updateBodyweightEquipment,
                onResistanceBandsChanged: _updateResistanceBandsEquipment,
                onPullupBarChanged: _updatePullupBarEquipment,
              ),

              // Faith Mode Control Section
              FaithModeSectionWidget(
                faithMode: _faithMode,
                onFaithModeChanged: _updateFaithMode,
              ),

              // Notification Settings Section
              NotificationSectionWidget(
                notificationsEnabled: _notificationsEnabled,
                startTime: _notificationStartTime,
                endTime: _notificationEndTime,
                onNotificationsToggled: _toggleNotifications,
                onStartTimeChanged: _updateNotificationStartTime,
                onEndTimeChanged: _updateNotificationEndTime,
              ),

              // Theme Settings Section
              ThemeSectionWidget(
                themeMode: _themeMode,
                onThemeModeChanged: _updateThemeMode,
              ),

              // Account Management Section
              AccountSectionWidget(
                isDataSynced: _isDataSynced,
                lastSyncTime: _lastSyncTime,
                onLogout: _handleLogout,
                onExportData: _handleExportData,
              ),

              // Privacy Controls Section
              PrivacySectionWidget(
                dataCollectionEnabled: _dataCollectionEnabled,
                analyticsEnabled: _analyticsEnabled,
                crashReportingEnabled: _crashReportingEnabled,
                onDataCollectionChanged: _updateDataCollection,
                onAnalyticsChanged: _updateAnalytics,
                onCrashReportingChanged: _updateCrashReporting,
                onViewPrivacyPolicy: _viewPrivacyPolicy,
                onViewTerms: _viewTermsOfService,
              ),

              // App Information Section
              AppInfoSectionWidget(
                appVersion: _appVersion,
                onContactSupport: _contactSupport,
                onViewHelp: _viewHelp,
                onRateApp: _rateApp,
              ),

              SizedBox(height: AppSpace.x10), // Bottom padding for navigation bar
            ],
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomBar(
        currentIndex:
            4, // Settings is not in bottom nav, but we'll use profile index
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  // Profile update methods
  void _updateFullName(String name) {
    setState(() {
      _fullName = name;
    });
    _showSuccessToast('Name updated successfully');
    _syncUserData();
  }

  void _updateTimezone(String timezone) {
    setState(() {
      _timezone = timezone;
    });
    _showSuccessToast('Timezone updated');
    _syncUserData();
  }

  // Equipment update methods
  void _updateBodyweightEquipment(bool enabled) {
    setState(() {
      _hasBodyweight = enabled;
    });
    _showSuccessToast(enabled
        ? 'Bodyweight exercises enabled'
        : 'Bodyweight exercises disabled');
    _updateWorkoutPlans();
  }

  void _updateResistanceBandsEquipment(bool enabled) {
    setState(() {
      _hasResistanceBands = enabled;
    });
    _showSuccessToast(
        enabled ? 'Resistance bands enabled' : 'Resistance bands disabled');
    _updateWorkoutPlans();
  }

  void _updatePullupBarEquipment(bool enabled) {
    setState(() {
      _hasPullupBar = enabled;
    });
    _showSuccessToast(enabled ? 'Pullup bar enabled' : 'Pullup bar disabled');
    _updateWorkoutPlans();
  }

  // Faith mode update method
  void _updateFaithMode(FaithMode mode) {
    setState(() {
      _faithMode = mode;
    });

    String modeText;
    switch (mode) {
      case FaithMode.off:
        modeText = 'Secular mode activated';
        break;
      case FaithMode.light:
        modeText = 'Light faith mode activated';
        break;
      case FaithMode.full:
        modeText = 'Full faith mode activated';
        break;
    }

    _showSuccessToast(modeText);
    _syncUserData();
  }

  // Notification update methods
  void _toggleNotifications(bool enabled) {
    setState(() {
      _notificationsEnabled = enabled;
    });
    _showSuccessToast(
        enabled ? 'Notifications enabled' : 'Notifications disabled');
    _updateNotificationSchedule();
  }

  void _updateNotificationStartTime(TimeOfDay time) {
    setState(() {
      _notificationStartTime = time;
    });
    _showSuccessToast('Notification start time updated');
    _updateNotificationSchedule();
  }

  void _updateNotificationEndTime(TimeOfDay time) {
    setState(() {
      _notificationEndTime = time;
    });
    _showSuccessToast('Notification end time updated');
    _updateNotificationSchedule();
  }

  // Theme update method
  void _updateThemeMode(AppThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });

    String modeText;
    switch (mode) {
      case AppThemeMode.light:
        modeText = 'Light theme applied';
        break;
      case AppThemeMode.dark:
        modeText = 'Dark theme applied';
        break;
      case AppThemeMode.system:
        modeText = 'System theme applied';
        break;
    }

    _showSuccessToast(modeText);
    _syncUserData();
  }

  // Privacy update methods
  void _updateDataCollection(bool enabled) {
    setState(() {
      _dataCollectionEnabled = enabled;
    });
    _showSuccessToast(
        enabled ? 'Data collection enabled' : 'Data collection disabled');
    _syncUserData();
  }

  void _updateAnalytics(bool enabled) {
    setState(() {
      _analyticsEnabled = enabled;
    });
    _showSuccessToast(enabled ? 'Analytics enabled' : 'Analytics disabled');
    _syncUserData();
  }

  void _updateCrashReporting(bool enabled) {
    setState(() {
      _crashReportingEnabled = enabled;
    });
    _showSuccessToast(
        enabled ? 'Crash reporting enabled' : 'Crash reporting disabled');
    _syncUserData();
  }

  // Account management methods
  void _handleLogout() {
    // Clear user session and navigate to authentication
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/authentication-screen',
      (route) => false,
    );
    _showSuccessToast('Signed out successfully');
  }

  void _handleExportData() {
    // Generate and download user data export
    final userData = _generateUserDataExport();
    _downloadFile(userData, 'ur4more_wellness_data.json');
    _showSuccessToast('Data export started');
  }

  // Privacy and support methods
  void _viewPrivacyPolicy() {
    _showInfoDialog(
      'Privacy Policy',
      'Our privacy policy outlines how we collect, use, and protect your wellness data. We are committed to maintaining your privacy and providing transparency about our data practices.',
    );
  }

  void _viewTermsOfService() {
    _showInfoDialog(
      'Terms of Service',
      'By using UR4MORE Wellness, you agree to our terms of service. These terms govern your use of our faith-based wellness platform and outline your rights and responsibilities.',
    );
  }

  void _contactSupport() {
    _showInfoDialog(
      'Contact Support',
      'Need help? Our support team is here for you!\n\nEmail: support@ur4more.com\nPhone: 1-800-UR4MORE\n\nWe typically respond within 24 hours.',
    );
  }

  void _viewHelp() {
    _showInfoDialog(
      'Help & FAQ',
      'Common Questions:\n\n• How do I sync my data?\n• How do faith modes work?\n• How do I track my progress?\n• How do I earn points?\n\nFor more help, visit our support center or contact us directly.',
    );
  }

  void _rateApp() {
    _showInfoDialog(
      'Rate UR4MORE',
      'Love using UR4MORE Wellness? Please consider rating us in the app store! Your feedback helps us improve and reach more people on their wellness journey.',
    );
  }

  // Helper methods
  void _syncUserData() {
    // Simulate data sync
    setState(() {
      _isDataSynced = true;
      _lastSyncTime = DateTime.now();
    });
  }

  void _updateWorkoutPlans() {
    // Update workout plans based on available equipment
    final availableEquipment = <String>[];
    if (_hasBodyweight) availableEquipment.add('bodyweight');
    if (_hasResistanceBands) availableEquipment.add('bands');
    if (_hasPullupBar) availableEquipment.add('pullup_bar');

    // Store equipment preferences
    print('Equipment updated: $availableEquipment');
  }

  void _updateNotificationSchedule() {
    if (_notificationsEnabled) {
      // Schedule notifications between start and end time
      print(
          'Notifications scheduled: ${_formatTime(_notificationStartTime)} - ${_formatTime(_notificationEndTime)}');
    } else {
      // Cancel all notifications
      print('All notifications cancelled');
    }
  }

  String _generateUserDataExport() {
    final exportData = {
      'profile': {
        'fullName': _fullName,
        'timezone': _timezone,
        'exportDate': DateTime.now().toIso8601String(),
      },
      'equipment': {
        'bodyweight': _hasBodyweight,
        'resistanceBands': _hasResistanceBands,
        'pullupBar': _hasPullupBar,
      },
      'preferences': {
        'faithMode': _faithMode.toString(),
        'themeMode': _themeMode.toString(),
        'notificationsEnabled': _notificationsEnabled,
      },
      'privacy': {
        'dataCollection': _dataCollectionEnabled,
        'analytics': _analyticsEnabled,
        'crashReporting': _crashReportingEnabled,
      },
    };

    return exportData.toString();
  }

  void _downloadFile(String content, String filename) {
    // Simulate file download
    print('Downloading file: $filename');
    print('Content: $content');
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      textColor: AppTheme.lightTheme.colorScheme.onTertiary,
      fontSize: 14.0,
    );
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Got it',
                style: TextStyle(color: colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}
