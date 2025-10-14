import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class NotificationSectionWidget extends StatelessWidget {
  final bool notificationsEnabled;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final Function(bool) onNotificationsToggled;
  final Function(TimeOfDay) onStartTimeChanged;
  final Function(TimeOfDay) onEndTimeChanged;

  const NotificationSectionWidget({
    super.key,
    required this.notificationsEnabled,
    required this.startTime,
    required this.endTime,
    required this.onNotificationsToggled,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'notifications',
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    'Notification Settings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Switch(
                  value: notificationsEnabled,
                  onChanged: onNotificationsToggled,
                  activeColor: colorScheme.primary,
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Receive daily reminders for check-ins and wellness activities',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (notificationsEnabled) ...[
              SizedBox(height: 3.h),
              _buildTimeRangeSelector(context, theme, colorScheme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRangeSelector(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Hours',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2.h),
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                context,
                theme,
                colorScheme,
                'Start Time',
                startTime,
                onStartTimeChanged,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildTimeSelector(
                context,
                theme,
                colorScheme,
                'End Time',
                endTime,
                onEndTimeChanged,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              CustomIconWidget(
                iconName: 'info_outline',
                color: colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Text(
                  'Notifications will only be sent between ${_formatTime(startTime)} and ${_formatTime(endTime)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onTimeChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 1.h),
        GestureDetector(
          onTap: () async {
            final TimeOfDay? selectedTime = await showTimePicker(
              context: context,
              initialTime: time,
              builder: (context, child) {
                return Theme(
                  data: theme.copyWith(
                    timePickerTheme: TimePickerThemeData(
                      backgroundColor: colorScheme.surface,
                      hourMinuteTextColor: colorScheme.onSurface,
                      dialHandColor: colorScheme.primary,
                      dialBackgroundColor: colorScheme.surfaceContainer,
                      hourMinuteColor: colorScheme.surfaceContainer,
                      dayPeriodTextColor: colorScheme.onSurface,
                      dayPeriodColor: colorScheme.surfaceContainer,
                      entryModeIconColor: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  child: child!,
                );
              },
            );

            if (selectedTime != null) {
              onTimeChanged(selectedTime);
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            decoration: BoxDecoration(
              border:
                  Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatTime(time),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                CustomIconWidget(
                  iconName: 'access_time',
                  color: colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
