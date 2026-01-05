import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import '../../services/faith_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import '../../routes/app_routes.dart';
import '../../core/settings/settings_scope.dart';
import '../../core/settings/settings_model.dart';
import './widgets/theme_section_widget.dart';
import './widgets/account_section_widget.dart';
import './widgets/app_info_section_widget.dart';
import './widgets/equipment_section_widget.dart';
import './widgets/faith_mode_section_widget.dart';
import './widgets/notification_section_widget.dart';
import './widgets/privacy_section_widget.dart';
import './widgets/profile_section_widget.dart';
import './widgets/theme_section_widget.dart';
import './widgets/safety_monitoring_section_widget.dart';

class SettingsProfileScreen extends StatefulWidget {
  const SettingsProfileScreen({super.key});

  @override
  State<SettingsProfileScreen> createState() => _SettingsProfileScreenState();
}

class _SettingsProfileScreenState extends State<SettingsProfileScreen> {
  // Scroll controller for section focus
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _faithSectionKey = GlobalKey();
  
  // Profile settings
  String _fullName = 'Sarah Johnson';

  // Notification settings
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
  void initState() {
    super.initState();
    // Check if we should focus on faith section
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args?['section'] == 'faith') {
        _scrollToFaithSection();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFaithSection() {
    if (_faithSectionKey.currentContext != null) {
      Scrollable.ensureVisible(
        _faithSectionKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showFaithCongratulations() {
    // Navigate to faith congratulations screen
    Navigator.of(context).pushNamed('/faith-congratulations');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get current settings from SettingsController
    final settingsCtl = SettingsScope.of(context);
    final settings = settingsCtl.value;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(
        title: 'Settings & Profile',
        variant: CustomAppBarVariant.centered,
        showBackButton: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: AppSpace.x2),

              // Profile Information Section
              ProfileSectionWidget(
                fullName: _fullName,
                timezone: settings.timezone,
                onNameChanged: _updateFullName,
                onTimezoneChanged: _updateTimezone,
              ),

              // Equipment Configuration Section
              EquipmentSectionWidget(
                hasBodyweight: settings.equipmentBodyweight,
                hasResistanceBands: settings.equipmentBands,
                hasPullupBar: settings.equipmentPullup,
                onBodyweightChanged: _updateBodyweightEquipment,
                onResistanceBandsChanged: _updateResistanceBandsEquipment,
                onPullupBarChanged: _updatePullupBarEquipment,
              ),

              // Faith Mode Control Section
              Container(
                key: _faithSectionKey,
                child: FaithModeSectionWidget(
                  faithMode: settings.faithTier,
                  onFaithModeChanged: _updateFaithMode,
                  onFaithModeEnabled: _showFaithCongratulations,
                ),
              ),

              // Notification Settings Section
              NotificationSectionWidget(
                notificationsEnabled: settings.notificationsEnabled,
                startTime: _notificationStartTime,
                endTime: _notificationEndTime,
                onNotificationsToggled: _toggleNotifications,
                onStartTimeChanged: _updateNotificationStartTime,
                onEndTimeChanged: _updateNotificationEndTime,
              ),

              // Theme Settings Section
              ThemeSectionWidget(
                themeMode: settings.themeMode,
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

              // Safety Monitoring Section
              const SafetyMonitoringSectionWidget(),

              // App Information Section
              AppInfoSectionWidget(
                appVersion: _appVersion,
                onContactSupport: _contactSupport,
                onViewHelp: _viewHelp,
                onRateApp: _rateApp,
              ),

              SizedBox(height: AppSpace.x12), // Bottom padding for navigation bar
            ],
          ),
        ),
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

  void _updateTimezone(String timezone) async {
    final settingsCtl = SettingsScope.of(context);
    await settingsCtl.updateTimezone(timezone);
    _showSuccessToast('Timezone updated');
  }

  // Equipment update methods
  void _updateBodyweightEquipment(bool enabled) async {
    final settingsCtl = SettingsScope.of(context);
    await settingsCtl.updateEquipment(bodyweight: enabled);
    _showSuccessToast(enabled
        ? 'Bodyweight exercises enabled'
        : 'Bodyweight exercises disabled');
  }

  void _updateResistanceBandsEquipment(bool enabled) async {
    final settingsCtl = SettingsScope.of(context);
    await settingsCtl.updateEquipment(bands: enabled);
    _showSuccessToast(
        enabled ? 'Resistance bands enabled' : 'Resistance bands disabled');
  }

  void _updatePullupBarEquipment(bool enabled) async {
    final settingsCtl = SettingsScope.of(context);
    await settingsCtl.updateEquipment(pullup: enabled);
    _showSuccessToast(enabled ? 'Pullup bar enabled' : 'Pullup bar disabled');
  }

  // Faith mode update method
  void _updateFaithMode(FaithTier? tier) async {
    if (tier == null) return;
    
    final settingsCtl = SettingsScope.of(context);
    await settingsCtl.updateFaith(tier);

    String modeText = '';
    switch (tier) {
      case FaithTier.off:
        modeText = 'Secular mode activated';
        break;
      case FaithTier.light:
        modeText = 'Light faith mode activated';
        break;
      case FaithTier.disciple:
        modeText = 'Disciple faith mode activated';
        break;
      case FaithTier.kingdom:
        modeText = 'Kingdom Builder faith mode activated';
        break;
    }

    _showSuccessToast(modeText);
  }

  // Notification update methods
  void _toggleNotifications(bool enabled) async {
    final settingsCtl = SettingsScope.of(context);
    await settingsCtl.updateNotifications(enabled);
    _showSuccessToast(
        enabled ? 'Notifications enabled' : 'Notifications disabled');
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
  void _updateThemeMode(AppThemeMode mode) async {
    final settingsCtl = SettingsScope.of(context);
    await settingsCtl.updateThemeMode(mode);

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
      AppRoutes.authentication,
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
    final settingsCtl = SettingsScope.of(context);
    final settings = settingsCtl.value;
    final availableEquipment = <String>[];
    if (settings.equipmentBodyweight) availableEquipment.add('bodyweight');
    if (settings.equipmentBands) availableEquipment.add('bands');
    if (settings.equipmentPullup) availableEquipment.add('pullup_bar');

    // Store equipment preferences
    // Equipment preferences updated
  }

  void _updateNotificationSchedule() {
    final settingsCtl = SettingsScope.of(context);
    final settings = settingsCtl.value;
    if (settings.notificationsEnabled) {
      // Schedule notifications between start and end time
      // Notifications scheduled
    } else {
      // Cancel all notifications
    }
  }

  String _generateUserDataExport() {
    final settingsCtl = SettingsScope.of(context);
    final settings = settingsCtl.value;
    final exportData = {
      'profile': {
        'fullName': _fullName,
        'timezone': settings.timezone,
        'exportDate': DateTime.now().toIso8601String(),
      },
      'equipment': {
        'bodyweight': settings.equipmentBodyweight,
        'resistanceBands': settings.equipmentBands,
        'pullupBar': settings.equipmentPullup,
      },
      'preferences': {
        'faithMode': settings.faithTier.name,
        'themeMode': _themeMode.toString(),
        'notificationsEnabled': settings.notificationsEnabled,
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
    // File download initiated
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
      backgroundColor: const Color(0xFFF5C542),
      textColor: Colors.black,
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
